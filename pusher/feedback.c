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

#define CLOSE_DATABASE \
    if (database) \
    { \
        sqlite3_finalize(deleteStmt); \
        sqlite3_finalize(selectStmt); \
        sqlite3_close(database); \
    }

#include <assert.h>
#include <arpa/inet.h>
#include <stdlib.h>
#include <string.h>
#include <strings.h>
#include <sys/stat.h>
#include <unistd.h>

#include <openssl/err.h>
#include <sqlite3.h>

#include "socket_connect.h"
#include "timestamp.h"
#include "tls_connection.h"

extern char* optarg;

static char certPath[256];
static char cacertPath[256];
static char passphraseFilePath[256];
static char passphrase[256];
static char host[256];
static unsigned short port = 0;
static int production = -1;
static char databasePath[256];

static sqlite3_stmt*
prepareStatement(sqlite3* database, char* sql)
{
    sqlite3_stmt* statement = NULL;
    int rc = sqlite3_prepare_v2(database, sql, -1, &statement, NULL);
    if (rc != SQLITE_OK)
    {
        timestamp_f(stderr);
        fprintf(stderr, "error %d from sqlite3_prepare_v2(%s)\n", rc, sql);
        return NULL;
    }

    return statement;
}

static time_t
getUpdateTimeForDeviceToken(char* token, sqlite3_stmt* statement)
{
    char flag[2];
    if (production) strcpy(flag, "t");
    else strcpy(flag, "f");

    sqlite3_reset(statement);
    sqlite3_bind_text(statement, 1, token, -1, SQLITE_STATIC);
    sqlite3_bind_text(statement, 2, flag, -1, SQLITE_STATIC);

    int rc = sqlite3_step(statement);
    if (rc != SQLITE_ROW)
    {
        timestamp_f(stderr);
        fprintf(stderr, "Error executing SELECT statement: %d\n", rc);
        return 0;
    }

    const char* updatedAt = (const char*)sqlite3_column_text(statement, 0);

    char updateTimestamp[32];
    strcpy(updateTimestamp, updatedAt);
    // strip out any subsecond timestamp
    char* period = strchr(updateTimestamp, '.');
    if (period) *period = '\0';

    return parseTimestamp(updateTimestamp, "%Y-%m-%d %T");
}

static int
removeDeviceToken(char* token, sqlite3_stmt* statement)
{
    char flag[2];
    if (production) strcpy(flag, "t");
    else strcpy(flag, "f");

    sqlite3_reset(statement);
    sqlite3_bind_text(statement, 1, token, -1, SQLITE_STATIC);
    sqlite3_bind_text(statement, 2, flag, -1, SQLITE_STATIC);

    return sqlite3_step(statement);
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
    host[0] = '\0';
    databasePath[0] = '\0';

    const char * const opts = "a:c:d:e:hP:p:";
    int c = -1;

    while ((c=getopt(argc, argv, opts)) != -1)
    {
        switch (c)
        {
        case 'a':
            if (hasLongArgument(c)) return 1;
            strcpy(cacertPath, optarg);
            break;
        case 'c':
            if (hasLongArgument(c)) return 1;
            strcpy(certPath, optarg);
            break;
        case 'P':
            if (hasLongArgument(c)) return 1;
            strcpy(passphraseFilePath, optarg);
            if (loadPassphrase()) return 1;
            break;
        case 'p':
            if (setHostAndPort()) return 1;
            break;
        case 'd':
            if (hasLongArgument(c)) return 1;
            strcpy(databasePath, optarg);
            break;
        case 'e':
            if (!strcasecmp(optarg, "prod")) production = 1;
            else if (!strcasecmp(optarg, "dev")) production = 0;
            break;
        case 'h':
        default:
            return -1;
        }
    }

    if (strlen(host) == 0 || port == 0 || strlen(certPath) == 0 || strlen(passphraseFilePath) == 0)
    {
        fprintf(stderr, "-P, -p and -c are required\n");
        return -1;
    }

    if (strlen(databasePath) > 0 && production < 0)
    {
        fprintf(stderr, "-e required with -d\n");
        return -1;
    }

    if (production >= 0 && strlen(databasePath) == 0)
    {
        fprintf(stderr, "-e requires -d\n");
        return -1;
    }

    return 0;
}

static void
usage(const char* s)
{
    fprintf(stderr, "usage:\n");
    fprintf(stderr, "    %s [-a cacertfile] [-c cert_path] [-h] [-P passphrase_file] [-p host:port] [-d databasepath] [-e dev|prod]\n", s);
    fprintf(stderr, "\n");
    fprintf(stderr, "    -a use cacertfile (.pem) for CA certs\n");
    fprintf(stderr, "    -c use certificate in file at cert_path (.p12, required)\n");
    fprintf(stderr, "    -h print this message and exit\n");
    fprintf(stderr, "    -P read the passphrase from passphrase_file(required)\n");
    fprintf(stderr, "    -p connect to remote host:port (required)\n");
    fprintf(stderr, "    -d remove dead device tokens from the database at databasepath\n");
    fprintf(stderr, "    -e feedback is from the prod or dev environment (required with -d)\n");
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

    // make logs a little easier to read/more useful
    setvbuf(stderr, NULL, _IOLBF, 0);

    timestamp_f(stderr);
    fprintf(stderr, "cert. file: %s. passphrase loaded\n", certPath);
    timestamp_f(stderr);
    fprintf(stderr, "host: %s, port: %d\n", host, port);
    if (strlen(databasePath) > 0)
    {
        timestamp_f(stderr);
        fprintf(stderr, "database: %s (%s)\n", databasePath, (production ? "prod" : "dev"));
    }

    /*
     * Open DB if so configured
     */

    sqlite3* database = NULL;
    sqlite3_stmt* selectStmt = NULL;
    sqlite3_stmt* deleteStmt = NULL;
    if (strlen(databasePath) > 0)
    {
        int rc = sqlite3_open_v2(databasePath, &database,
            SQLITE_OPEN_FULLMUTEX|SQLITE_OPEN_READWRITE, NULL);
        if (rc != SQLITE_OK)
        {
            timestamp_f(stderr);
            fprintf(stderr, "error %d from sqlite3_open_v2\n", rc);
            return -1;
        }

        selectStmt = prepareStatement(database, "SELECT updated_at FROM device_tokens WHERE token = ? AND production = ?");
        deleteStmt = prepareStatement(database, "DELETE FROM device_tokens WHERE token = ? AND production = ?");
    }

    /*
     * Connect to server
     */

    timestamp_f(stderr);
    fprintf(stderr, "attempting connection to %s:%d\n", host, port);
    s = socketConnect(host, port);
    if (s < 0)
    {
        timestamp_f(stderr);
        fprintf(stderr, "connection to %s:%d failed\n", host, port);
        CLOSE_DATABASE
        return -1;
    }

    timestamp_f(stderr);
    fprintf(stderr, "successfully connected to %s:%d\n", host, port);

    tls = makeTlsConnection(s, certPath, passphrase, cacertPath);
    if (!tls)
    {
        timestamp_f(stderr);
        fprintf(stderr, "TLS handshake failed\n");
        CLOSE_DATABASE
        return -1;
    }

    struct n_feedback
    {
        uint32_t n_time;
        uint16_t n_size;
        uint8_t n_token[32];
    } feedback;

    // sizeof(feedback) is 40
    const size_t feedbackSize = 38;

    /*
     * Now read feedback until no more input.
     */

    int nr = 0;
    while ((nr=SSL_read(tls, &feedback, feedbackSize)) == feedbackSize)
    {
        time_t time = ntohl(feedback.n_time);
        char timebuf[256];
        timestamp(time, timebuf, 255);

        uint16_t size = ntohs(feedback.n_size);

        char token[128];
        memset(token, 0, sizeof(token));
        int j;
        for (j=0; j<32; ++j)
        {
            sprintf(token+2*j, "%02x", feedback.n_token[j]);
        }

        timestamp_f(stderr);
        fprintf(stderr, "%s: DT (%u) %s\n", timebuf, size, token);

        if (!database) continue;

        /*
         * If using a DB, look for each DT and check the time of last registration.
         */

        time_t updatedAt = getUpdateTimeForDeviceToken(token, selectStmt);
        timestamp(updatedAt, timebuf, 255);

        // if there's no such token in the DB (we already removed it from a previous
        // feedback run), updatedAt will be 0.
        if (updatedAt == 0)
        {
            timestamp_f(stderr);
            fprintf(stderr, "device token %s not in DB\n", token);
            continue;
        }
        else if (time < updatedAt)
        {
            timestamp_f(stderr);
            fprintf(stderr, "device token %s reregistered at %s\n", token, timebuf);
            continue;
        }

        /*
         * If in the DB, and not registered since the feedback time, delete.
         */

        int rc = removeDeviceToken(token, deleteStmt);
        if (rc != SQLITE_DONE)
        {
            timestamp_f(stderr);
            fprintf(stderr, "failed to remove device token %s: %d\n", token, rc);
        }
        else
        {
            timestamp_f(stderr);
            fprintf(stderr, "deleted device token %s, last registered at %s\n", token, timebuf);
        }
    }

    CLOSE_DATABASE

    if (nr < 0)
    {
        timestamp_f(stderr);
        fprintf(stderr, "SSL_read returned error: %s", ERR_error_string(nr, NULL));
    }
    else
    {
        timestamp_f(stderr);
        fprintf(stderr, "<EOF>\n");
    }

    stopTlsConnection(tls);
    
    return 0;
}
