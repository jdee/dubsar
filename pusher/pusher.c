/*
 *  Dubsar Dictionary Project
 *  Copyright (C) 2010-15 Jimmy Dee
 *
 *  This program is free software; you can redistribute it and/or
 *  modify it under the terms of the GNU General Public License
 *  as published by the Free Software Foundation; either version 2
 *  of the License, or (at your option) any later version.
 *
 *  This program is distributed in the hope that it will be useful,
 *  but WITHOUT ANY WARRANTY; without even the implied warranty of
 *  MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
 *  GNU General Public License for more details.
 *
 *  You should have received a copy of the GNU General Public License
 *  along with this program; if not, write to the Free Software
 *  Foundation, Inc., 51 Franklin Street, Fifth Floor, Boston, MA  02110-1301, USA.
 */

#include <errno.h>
#include <signal.h>
#include <stdint.h>
#include <stdlib.h>
#include <string.h>
#include <sys/stat.h>
#include <unistd.h>

#include <openssl/err.h>

#include "notification.h"
#include "socket_connect.h"
#include "timestamp.h"
#include "tls_connection.h"

extern char* optarg;

static int production = 0, wotd = 0, broadcast = 0, noSend = 0;
static char certPath[256];
static char cacertPath[256];
static char passphraseFilePath[256];
static char passphrase[256];
static char databasePath[256];
static char host[256];
static unsigned short port = 0;
static char message[256];
static char deviceToken[128];
static char wotdExpiration[128];
static char url[256];

static int _shutdown = 0;

// returns 8, 16, 32, 64 (which add to 120), then 120 repeatedly
static int
backoff()
{
    static int _backoff = 4;

    _backoff *= 2;
    if (_backoff > 120) _backoff = 120;

    return _backoff;
}

static void
signalHandler(int sig)
{
    switch (sig)
    {
    case SIGINT:
    case SIGTERM:
        _shutdown = 1;
        break;
    default:
        break;
    }

    signal(sig, signalHandler);
}

static int
hasLongArgument(int c)
{
    if (strlen(optarg) > 255)
    {
        fprintf(stderr, "argument %s to -%c too long (limit 255 chars.)", optarg, c);
        return 1;
    }
    return 0;
}

static int
loadPassphrase()
{
    struct stat sb;
    if (stat(passphraseFilePath, &sb))
    {
        perror(passphraseFilePath);
        return -1;
    }

    if (sb.st_uid != getuid())
    {
        fprintf(stderr, "passphrase file owner (%d) must be the current user (%d)\n",
            sb.st_uid, getuid());
        return -1;
    }

    if (sb.st_mode & (S_IRWXG|S_IRWXO))
    {
        fprintf(stderr, "passphrase file must not be accessible by group or others (file mode is 0%o)\n",
            sb.st_mode);
        return -1;
    }

    FILE* fp = fopen(passphraseFilePath, "r");
    int len = 0;

    if (!fp)
    {
        perror(passphraseFilePath);
        return -1;
    }

    if (!fgets(passphrase, 255, fp))
    {
        perror(passphraseFilePath);
        fclose(fp);
        return -1;
    }

    fclose(fp);
    len = strlen(passphrase);

    /* strip off any trailing newline */
    if (len > 0 && passphrase[len-1] == '\n')
    {
        passphrase[--len] = '\0';
    }

    if (len == 0)
    {
        fprintf(stderr, "passphrase file %s is empty\n", passphraseFilePath);
        return -1;
    }

    return 0;
}

static int
setHostAndPort()
{
    char* colon = strchr(optarg, ':');
    if (!colon)
    {
        fprintf(stderr, "no colon; -p requires host:port");
        return -1;
    }

    strncpy(host, optarg, colon-optarg);
    host[colon-optarg] = '\0';

    char* endp = NULL;
    port = strtoul(++colon, &endp, 10);
    if (!port && *endp)
    {
        fprintf(stderr, "nonnumeric port; -p requires host:port");
        return -1;
    }

    return 0;
}

static int
parseArgs(int argc, char** argv)
{
    certPath[0] = '\0';
    cacertPath[0] = '\0';
    passphraseFilePath[0] = '\0';
    passphrase[0] = '\0';
    databasePath[0] = '\0';
    host[0] = '\0';
    message[0] = '\0';
    deviceToken[0] = '\0';
    url[0] = '\0';
    wotdExpiration[0] = '\0';

    const char * const opts = "a:b:c:d:hm:nP:p:t:u:wx:";
    int c = -1;

    while ((c=getopt(argc, argv, opts)) != -1)
    {
        switch (c)
        {
        case 'a':
            if (hasLongArgument(c)) return 1;
            strcpy(cacertPath, optarg);
            break;
        case 'b':
            production = strcasecmp("prod", optarg) == 0;
            broadcast = 1;
            break;
        case 'c':
            if (hasLongArgument(c)) return 1;
            strcpy(certPath, optarg);
            break;
        case 'd':
            if (hasLongArgument(c)) return 1;
            strcpy(databasePath, optarg);
            break;
        case 'm':
            if (hasLongArgument(c)) return 1;
            strcpy(message, optarg);
            break;
        case 'n':
            noSend = 1;
            break;
        case 'P':
            if (hasLongArgument(c)) return 1;
            strcpy(passphraseFilePath, optarg);
            if (loadPassphrase()) return 1;
            break;
        case 'p':
            if (setHostAndPort()) return 1;
            break;
        case 't':
            if (hasLongArgument(c)) return 1;
            strcpy(deviceToken, optarg);
            break;
        case 'u':
            if (hasLongArgument(c)) return 1;
            strcpy(url, optarg);
            break;
        case 'w':
            wotd = 1;
            break;
        case 'x':
            if (hasLongArgument(c)) return 1;
            strcpy(wotdExpiration, optarg);
            break;
        case 'h':
        default:
            return -1;
        }
    }

    int dtLength = strlen(deviceToken);
    int dtoken = dtLength > 0 ? 1 : 0;

    if (dtoken + broadcast != 1)
    {
        fprintf(stderr, "specify -b or -t, but not more than one\n");
        return -1;
    }

    if ((broadcast == 1 || wotd == 1) && strlen(databasePath) == 0)
    {
        fprintf(stderr, "specify -d with -b or -w\n");
        return -1;
    }

    if (noSend == 0 && (strlen(host) == 0 || port == 0 || strlen(certPath) == 0 || strlen(passphraseFilePath) == 0))
    {
        fprintf(stderr, "-P, -p and -c are required except with -n\n");
        return -1;
    }

    if (!wotd && (strlen(message) == 0 || strlen(url) == 0))
    {
        fprintf(stderr, "-m and -u required except with -w\n");
        return -1;
    }

    return 0;
}

static void
usage(const char* s)
{
    fprintf(stderr, "usage:\n");
    fprintf(stderr, "    %s [-a cacertfile] [-b environment] [-c cert_path] [-d database_path] [-h] [-m message] [-n]", s);
    fprintf(stderr, " [-P passphrase_file] [-p host:port] [-t device_token] [-u url] [-w] [-x expiration]\n");
    fprintf(stderr, "\n");
    fprintf(stderr, "examples:\n");
    fprintf(stderr, "    %s -b (dev|prod) -d database_path -p host:port -c cert_path -w\n", s);
    fprintf(stderr, "    %s -t device_token -p host:port -c cert_path -m hello -u https://m.dubsar-dictionary.com/m\n", s);
    fprintf(stderr, "\n");
    fprintf(stderr, "    -a use cacertfile (.pem) for CA certs\n");
    fprintf(stderr, "    -b broadcast to specified environment (dev or prod; incompatible with -t; requires -d)\n");
    fprintf(stderr, "    -c use certificate in file at cert_path (.p12, required)\n");
    fprintf(stderr, "    -d use database at database_path (only with -b or -w)\n");
    fprintf(stderr, "    -h print this message and exit\n");
    fprintf(stderr, "    -m user message for notification (required except with -w)\n");
    fprintf(stderr, "    -n do not send; just build payload and report\n");
    fprintf(stderr, "    -P read the passphrase from passphrase_file(required)\n");
    fprintf(stderr, "    -p connect to remote host:port (required)\n");
    fprintf(stderr, "    -t send to this device_token (incompatible with -b)\n");
    fprintf(stderr, "    -u url for notification (required except with -w)\n");
    fprintf(stderr, "    -w read new WOTD from the DB and send the notification\n");
    fprintf(stderr, "    -x use expiration in WOTD expiration field (not APNS expiry)\n");
}

int
main(int argc, char** argv)
{
    signal(SIGINT, signalHandler);
    signal(SIGTERM, signalHandler);

    int s = -1;
    int success = 0;
    SSL* tls = NULL;

    /*
     * Parse and validate args
     */
    if (parseArgs(argc, argv))
    {
        usage(argv[0]);
        return 1;
    }

    // make logs a little easier to read/more useful
    setvbuf(stderr, NULL, _IOLBF, 0);

    if (broadcast)
    {
        timestamp_f(stderr);
        fprintf(stderr, "broadcast environment: %s\n", (production ? "prod" : "dev"));
    }
    else if (noSend == 0)
    {
        timestamp_f(stderr);
        fprintf(stderr, "device token: %s\n", deviceToken);
    }
    else
    {
        timestamp_f(stderr);
        fprintf(stderr, "build and report only; no send\n");
    }

    timestamp_f(stderr);
    fprintf(stderr, "cert. file: %s. passphrase loaded\n", certPath);
    timestamp_f(stderr);
    fprintf(stderr, "database path: %s\n", databasePath);
    timestamp_f(stderr);
    fprintf(stderr, "message: \"%s\"\n", message);
    timestamp_f(stderr);
    fprintf(stderr, "host: %s, port: %d\n", host, port);
    timestamp_f(stderr);
    fprintf(stderr, "url: %s\n", url);
    timestamp_f(stderr);
    fprintf(stderr, "wotd: %d\n", wotd);

    time_t expiration = time(NULL) + 43200;
    
    void* notificationPayload = NULL;
    size_t notificationPayloadSize = 0;
    if (buildNotificationPayload(wotd, broadcast, production, deviceToken,
        databasePath, message, url, wotdExpiration, expiration,
        &notificationPayload, &notificationPayloadSize))
    {
        timestamp_f(stderr);
        fprintf(stderr, "failed to build notification payload\n");
        return -1;
    }
    timestamp_f(stderr);
    fprintf(stderr, "notification length is %ld\n", notificationPayloadSize);

    if (noSend)
    {
        free(notificationPayload);
        return 0;
    }

    /*
     * Connect to server
     */

    int nb = 0;
    int b = 0;
    while (!success && !_shutdown && time(NULL) < expiration)
    {
        while (!_shutdown && time(NULL) < expiration && s < 0)
        {
            timestamp_f(stderr);
            fprintf(stderr, "attempting connection to %s:%d\n", host, port);
            s = socketConnect(host, port);
            if (s < 0)
            {
                timestamp_f(stderr);
                fprintf(stderr, "connection to %s:%d failed\n", host, port);
                b = backoff();

                if (_shutdown || time(NULL) + b >= expiration)
                {
                    free(notificationPayload);
                    return 1;
                }

                timestamp_f(stderr);
                fprintf(stderr, "will try again in %d s\n", b);
                sleep(b);
                continue;
            }
        
            timestamp_f(stderr);
            fprintf(stderr, "successfully connected to %s:%d\n", host, port);
        }
    
        if (_shutdown || time(NULL) >= expiration)
        {
            free(notificationPayload);
            if (s >= 0) close(s);
            return 1;
        }

        tls = makeTlsConnection(s, certPath, passphrase, cacertPath);
        if (!tls)
        {
            timestamp_f(stderr);
            fprintf(stderr, "TLS handshake failed\n");
            close(s);
            s = -1;
            b = backoff();

            if (_shutdown || time(NULL) + b >= expiration)
            {
                free(notificationPayload);
                return 1;
            }

            timestamp_f(stderr);
            fprintf(stderr, "will reconnect in %d s\n", b);
            sleep(b);
            continue;
        }

        if (_shutdown)
        {
            free(notificationPayload);
            stopTlsConnection(tls);
            return 1;
        }
    
        nb = SSL_write(tls, notificationPayload, notificationPayloadSize);
        if (nb != notificationPayloadSize)
        {
            timestamp_f(stderr);
            fprintf(stderr, "SSL_write: %s", ERR_error_string(nb, NULL));
            stopTlsConnection(tls);
            s = -1;
            tls = NULL;
            b = backoff();

            if (_shutdown || time(NULL) + b >= expiration)
            {
                free(notificationPayload);
                return 1;
            }

            timestamp_f(stderr);
            fprintf(stderr, "will reconnect in %d s\n", b);
            sleep(b);
            continue;
        }
    
        timestamp_f(stderr);
        fprintf(stderr, "successfully wrote %d bytes\n", nb);
        free(notificationPayload);
        success = 1;
    }

    if (_shutdown || time(NULL) >= expiration)
    {
        if (tls) stopTlsConnection(tls);
        else if (s >= 0) close(s);
        return 1;
    }

    /*
     * Check for error response packet(s)
     */
    timestamp_f(stderr);
    fprintf(stderr, "checking for error responses (10 s)\n");
    char errorResponse[6];
    
    int numErrors;
    for (numErrors=0;
        (nb=SSL_read(tls, errorResponse, sizeof(errorResponse))) == sizeof(errorResponse);
        ++numErrors)
    {
        uint32_t identifier;
        memcpy(&identifier, errorResponse+2, sizeof(identifier));

        timestamp_f(stderr);
        fprintf(stderr, "APNS error response: command %d, status %d, identifier %u (network order)\n", errorResponse[0], errorResponse[1], identifier);
    }

    if (nb == 0 || (nb == -1 && errno == EAGAIN))
    {
        if (numErrors == 0)
        {
            timestamp_f(stderr);
            fprintf(stderr, "APNS push successfully sent\n");
        }
    }
    else if (nb == -1)
    {
        timestamp_f(stderr);
        perror("SSL_read");
    }
    else {
        timestamp_f(stderr);
        fprintf(stderr, "SSL_read error %d: %s", nb, ERR_error_string(nb, NULL));
    }

    stopTlsConnection(tls);
    
    return 0;
}
