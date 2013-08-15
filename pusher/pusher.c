/*
 *  Dubsar Dictionary Project
 *  Copyright (C) 2010-13 Jimmy Dee
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
#include <stdint.h>
#include <stdio.h>
#include <stdlib.h>
#include <string.h>
#include <unistd.h>

#include <openssl/err.h>

#include "notification.h"
#include "socket_connect.h"
#include "tls_connection.h"

extern char* optarg;

static int production = 0, wotd = 0, broadcast = 0;
static char certPath[256];
static char cacertPath[256];
static char passphraseFilePath[256];
static char passphrase[256];
static char databasePath[256];
static char host[256];
static unsigned short port = 0;
static char message[256];
static char deviceToken[128];
static char url[256];

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

    fclose(fp);
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

    const char * const opts = "a:b:c:d:hm:P:p:t:u:w";
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
        case 'h':
        default:
            return -1;
        }
    }

    int dtLength = strlen(deviceToken);

    if ((broadcast == 0 && dtLength == 0) || (broadcast == 1 && dtLength > 0))
    {
        fprintf(stderr, "specify -b or -t, but not both\n");
        return -1;
    }

    if ((broadcast == 1 || wotd == 1) && strlen(databasePath) == 0)
    {
        fprintf(stderr, "specify -d with -b or -w\n");
        return -1;
    }

    if (strlen(host) == 0 || port == 0 || strlen(certPath) == 0 || strlen(passphraseFilePath) == 0)
    {
        fprintf(stderr, "-P, -p and -c are required\n");
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
    fprintf(stderr, "    %s [-a cacertfile] [-b environment] [-c cert_path] [-d database_path] [-h] [-m message]", s);
    fprintf(stderr, " [-P passphrase_file] [-p host:port] [-t device_token] [-u url] [-w]\n");
    fprintf(stderr, "\n");
    fprintf(stderr, "examples:\n");
    fprintf(stderr, "    %s -b (dev|prod) -d database_path -p host:port -c cert_path -w\n", s);
    fprintf(stderr, "    %s -t device_token -p host:port -c cert_path -m hello -u https://m.dubsar-dictionary.com/m\n", s);
    fprintf(stderr, "\n");
    fprintf(stderr, "    -a use cacertfile (.pem) for CA certs\n");
    fprintf(stderr, "    -b broadcast to specified environment (dev or prod; incompatible with -t; requires -d)\n");
    fprintf(stderr, "    -c use certificate in file at cert_path (.p12, required)\n");
    fprintf(stderr, "    -d use database at database_path (only -b)\n");
    fprintf(stderr, "    -h print this message and exit\n");
    fprintf(stderr, "    -m user message for notification (required except with -w)\n");
    fprintf(stderr, "    -P read the passphrase from passphrase_file(required)\n");
    fprintf(stderr, "    -p connect to remote host:port (required)\n");
    fprintf(stderr, "    -t send to this device_token (incompatible with -b)\n");
    fprintf(stderr, "    -u url for notification (required except with -w)\n");
    fprintf(stderr, "    -w read new WOTD from the DB and send the notification\n");
}

int
main(int argc, char** argv)
{
    int s = -1;
    SSL* tls = NULL;

    /*
     * Parse and validate args
     */
    if (parseArgs(argc, argv))
    {
        usage(argv[0]);
        return 1;
    }

    if (broadcast)
    {
        fprintf(stderr, "broadcast environment: %s\n", (production ? "prod" : "dev"));
    }
    else
    {
        fprintf(stderr, "device token: %s\n", deviceToken);
    }

    fprintf(stderr, "cert. file: %s. passphrase loaded\n", certPath);
    fprintf(stderr, "database path: %s\n", databasePath);
    fprintf(stderr, "message: \"%s\"\n", message);
    fprintf(stderr, "host: %s, port: %d\n", host, port);
    fprintf(stderr, "url: %s\n", url);
    fprintf(stderr, "wotd: %d\n", wotd);

    /*
     * Connect to server
     */

    fprintf(stderr, "attempting connection to %s:%d\n", host, port);
    s = socketConnect(host, port);
    if (s < 0)
    {
        fprintf(stderr, "connection to %s:%d failed\n", host, port);
        return -1;
    }

    fprintf(stderr, "successfully connected to %s:%d\n", host, port);

    tls = makeTlsConnection(s, certPath, passphrase, cacertPath);
    if (!tls)
    {
        fprintf(stderr, "TLS handshake failed\n");
        return -1;
    }

    void* notificationPayload = NULL;
    size_t notificationPayloadSize = 0;
    if (buildNotificationPayload(wotd, broadcast, production, deviceToken,
        databasePath, message, url, &notificationPayload, &notificationPayloadSize))
    {
        fprintf(stderr, "failed to build notification payload");
        stopTlsConnection(tls);
        return -1;
    }
    fprintf(stderr, "notification length is %ld\n", notificationPayloadSize);

    int nb = SSL_write(tls, notificationPayload, notificationPayloadSize);
    free(notificationPayload);
    if (nb != notificationPayloadSize)
    {
        fprintf(stderr, "SSL_write: %s", ERR_error_string(nb, NULL));
        stopTlsConnection(tls);
        return -1;
    }

    fprintf(stderr, "successfully wrote %d bytes\n", nb);

    /*
     * Check for error response packet
     */
    fprintf(stderr, "checking for error response\n");
    char errorResponse[6];
    nb = SSL_read(tls, errorResponse, sizeof(errorResponse));

    if (nb == sizeof(errorResponse))
    {
        long identifier;
        memcpy(&identifier, errorResponse+2, sizeof(identifier));

        fprintf(stderr, "APNS error response: command %d, status %d, identifier %ld (network order)\n", errorResponse[0], errorResponse[1], identifier);
    }
    else if (nb == 0 || (nb == -1 && errno == EAGAIN))
    {
        fprintf(stderr, "APNS push successfully sent\n");
    }
    else if (nb == -1)
    {
        perror("SSL_read");
    }
    else {
        fprintf(stderr, "SSL_read error %d: %s", nb, ERR_error_string(nb, NULL));
    }

    stopTlsConnection(tls);
    
    return 0;
}
