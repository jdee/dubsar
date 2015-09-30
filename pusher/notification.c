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

#include <arpa/inet.h>
#include <stdint.h>
#include <stdlib.h>
#include <string.h>

#include <sqlite3.h>

#include "notification.h"
#include "timestamp.h"

static
int
getDeviceTokens(int production, const char* databasePath, char** buffer)
{
    sqlite3* database = NULL;
    int rc = sqlite3_open_v2(databasePath, &database,
        SQLITE_OPEN_FULLMUTEX|SQLITE_OPEN_READONLY, NULL);
    if (rc != SQLITE_OK)
    {
        timestamp_f(stderr);
        fprintf(stderr, "error %d from sqlite3_open_v2\n", rc);
        return -1;
    }

    char sql[256];
    sprintf(sql, "SELECT COUNT(*) FROM device_tokens WHERE production = '%s' ",
        (production == 1 ? "t" : "f"));

    sqlite3_stmt* statement = NULL;
    rc = sqlite3_prepare_v2(database, sql, -1, &statement, NULL);
    if (rc != SQLITE_OK)
    {
        timestamp_f(stderr);
        fprintf(stderr, "error %d from sqlite3_prepare_v2(%s)\n", rc, sql);
        sqlite3_close(database);
        return -1;
    }

    int number = -1;
    rc = sqlite3_step(statement);
    if (rc == SQLITE_ROW)
    {
        number = sqlite3_column_int(statement, 0);
    }
    else
    {
        timestamp_f(stderr);
        fprintf(stderr, "error counting device tokens: %d\n", rc);
        sqlite3_finalize(statement);
        sqlite3_close(database);
        return -1;
    }

    sqlite3_finalize(statement);

    if (number == 0)
    {
        sqlite3_close(database);
        *buffer = NULL;
        return 0;
    }

    sprintf(sql, "SELECT token FROM device_tokens WHERE production = '%s'",
        (production == 1 ? "t" : "f"));
    rc = sqlite3_prepare_v2(database, sql, -1, &statement, NULL);
    if (rc != SQLITE_OK)
    {
        timestamp_f(stderr);
        fprintf(stderr, "error %d from sqlite3_prepare_v2(%s)\n", rc, sql);
        sqlite3_close(database);
        return -1;
    }

    *buffer = malloc(64 * number);
    int count;
    for (count=0; (rc=sqlite3_step(statement)) == SQLITE_ROW; ++count)
    {
        memcpy((*buffer)+64*count, sqlite3_column_text(statement, 0), 64);
    }

    if (rc != SQLITE_DONE || count != number)
    {
        timestamp_f(stderr);
        fprintf(stderr, "error retrieving device tokens: %d\n", rc);
        free(*buffer);
        *buffer = NULL;
        number = -1;
    }

    sqlite3_finalize(statement);
    sqlite3_close(database);

    return number;
}

static
int
getDeviceTokens_pre210(int production, const char* databasePath, char** buffer)
{
    sqlite3* database = NULL;
    int rc = sqlite3_open_v2(databasePath, &database,
        SQLITE_OPEN_FULLMUTEX|SQLITE_OPEN_READONLY, NULL);
    if (rc != SQLITE_OK)
    {
        timestamp_f(stderr);
        fprintf(stderr, "error %d from sqlite3_open_v2\n", rc);
        return -1;
    }

    char sql[256];
    sprintf(sql, "SELECT COUNT(*) FROM device_tokens WHERE production = '%s' "
        "AND (client_version ISNULL OR client_version LIKE '1%%' OR client_version LIKE '2.0._')",
        (production == 1 ? "t" : "f"));

    sqlite3_stmt* statement = NULL;
    rc = sqlite3_prepare_v2(database, sql, -1, &statement, NULL);
    if (rc != SQLITE_OK)
    {
        timestamp_f(stderr);
        fprintf(stderr, "error %d from sqlite3_prepare_v2(%s)\n", rc, sql);
        sqlite3_close(database);
        return -1;
    }

    int number = -1;
    rc = sqlite3_step(statement);
    if (rc == SQLITE_ROW)
    {
        number = sqlite3_column_int(statement, 0);
    }
    else
    {
        timestamp_f(stderr);
        fprintf(stderr, "error counting device tokens: %d\n", rc);
        sqlite3_finalize(statement);
        sqlite3_close(database);
        return -1;
    }

    sqlite3_finalize(statement);

    if (number == 0)
    {
        sqlite3_close(database);
        *buffer = NULL;
        return 0;
    }

    sprintf(sql, "SELECT token FROM device_tokens WHERE production = '%s' "
        "AND (client_version ISNULL OR client_version LIKE '1%%' OR client_version LIKE '2.0._')",
        (production == 1 ? "t" : "f"));
    rc = sqlite3_prepare_v2(database, sql, -1, &statement, NULL);
    if (rc != SQLITE_OK)
    {
        timestamp_f(stderr);
        fprintf(stderr, "error %d from sqlite3_prepare_v2(%s)\n", rc, sql);
        sqlite3_close(database);
        return -1;
    }

    *buffer = malloc(64 * number);
    int count;
    for (count=0; (rc=sqlite3_step(statement)) == SQLITE_ROW; ++count)
    {
        memcpy((*buffer)+64*count, sqlite3_column_text(statement, 0), 64);
    }

    if (rc != SQLITE_DONE || count != number)
    {
        timestamp_f(stderr);
        fprintf(stderr, "error retrieving device tokens: %d\n", rc);
        free(*buffer);
        *buffer = NULL;
        number = -1;
    }

    sqlite3_finalize(statement);
    sqlite3_close(database);

    return number;
}

static
int
getDeviceTokens_v210(int production, const char* databasePath, char** buffer)
{
    sqlite3* database = NULL;
    int rc = sqlite3_open_v2(databasePath, &database,
        SQLITE_OPEN_FULLMUTEX|SQLITE_OPEN_READONLY, NULL);
    if (rc != SQLITE_OK)
    {
        timestamp_f(stderr);
        fprintf(stderr, "error %d from sqlite3_open_v2\n", rc);
        return -1;
    }

    char sql[256];
    sprintf(sql, "SELECT COUNT(*) FROM device_tokens WHERE production = '%s' "
        "AND client_version NOTNULL AND client_version NOT LIKE '1%%' AND client_version NOT LIKE '2.0._'",
        (production == 1 ? "t" : "f"));

    sqlite3_stmt* statement = NULL;
    rc = sqlite3_prepare_v2(database, sql, -1, &statement, NULL);
    if (rc != SQLITE_OK)
    {
        timestamp_f(stderr);
        fprintf(stderr, "error %d from sqlite3_prepare_v2(%s)\n", rc, sql);
        sqlite3_close(database);
        return -1;
    }

    int number = -1;
    rc = sqlite3_step(statement);
    if (rc == SQLITE_ROW)
    {
        number = sqlite3_column_int(statement, 0);
    }
    else
    {
        timestamp_f(stderr);
        fprintf(stderr, "error counting device tokens: %d\n", rc);
        sqlite3_finalize(statement);
        sqlite3_close(database);
        return -1;
    }

    sqlite3_finalize(statement);

    if (number == 0)
    {
        sqlite3_close(database);
        *buffer = NULL;
        return 0;
    }

    sprintf(sql, "SELECT token FROM device_tokens WHERE production = '%s' "
        "AND client_version NOTNULL AND client_version NOT LIKE '1%%' AND client_version NOT LIKE '2.0._'",
        (production == 1 ? "t" : "f"));
    rc = sqlite3_prepare_v2(database, sql, -1, &statement, NULL);
    if (rc != SQLITE_OK)
    {
        timestamp_f(stderr);
        fprintf(stderr, "error %d from sqlite3_prepare_v2(%s)\n", rc, sql);
        sqlite3_close(database);
        return -1;
    }

    *buffer = malloc(64 * number);
    int count;
    for (count=0; (rc=sqlite3_step(statement)) == SQLITE_ROW; ++count)
    {
        memcpy((*buffer)+64*count, sqlite3_column_text(statement, 0), 64);
    }

    if (rc != SQLITE_DONE || count != number)
    {
        timestamp_f(stderr);
        fprintf(stderr, "error retrieving device tokens: %d\n", rc);
        free(*buffer);
        *buffer = NULL;
        number = -1;
    }

    sqlite3_finalize(statement);
    sqlite3_close(database);

    return number;
}

static
int
wotdPayload_pre210(const char* databasePath, char* payloadBuffer, const char* wotdExpiration)
{
    sqlite3* database = NULL;
    int rc = sqlite3_open_v2(databasePath, &database,
        SQLITE_OPEN_FULLMUTEX|SQLITE_OPEN_READONLY, NULL);
    if (rc != SQLITE_OK)
    {
        timestamp_f(stderr);
        fprintf(stderr, "error %d from sqlite3_open_v2\n", rc);
        return -1;
    }

    const char* sql = "SELECT w.id, w.name, w.part_of_speech, dw.created_at FROM words w "
        "INNER JOIN daily_words dw ON dw.word_id = w.id "
        "ORDER BY dw.created_at DESC LIMIT 1";

    sqlite3_stmt* statement = NULL;
    rc = sqlite3_prepare_v2(database, sql, -1, &statement, NULL);
    if (rc != SQLITE_OK)
    {
        timestamp_f(stderr);
        fprintf(stderr, "error %d from sqlite3_prepare_v2\n", rc);
        sqlite3_close(database);
        return -1;
    }

    int wordId = 0;
    const char* wordName = NULL, *wordPartOfSpeech = NULL;
    const char* dailyWordCreatedAt = NULL;
    int payloadLength = -1;

    if ((rc=sqlite3_step(statement)) == SQLITE_ROW)
    {
        wordId = sqlite3_column_int(statement, 0);
        wordName = (const char*)sqlite3_column_text(statement, 1);
        wordPartOfSpeech = (const char*)sqlite3_column_text(statement, 2);
        dailyWordCreatedAt = (const char*)sqlite3_column_text(statement, 3);

        time_t expiration = 0;
        if (wotdExpiration == NULL || wotdExpiration[0] == '\0')
        {
            char buffer[32];
            strcpy(buffer, dailyWordCreatedAt);
            char* period = strchr(buffer, '.');
            if (period) *period = '\0';
            expiration = parseTimestamp(buffer, "%Y-%m-%d %T") + 86400;
        }

        const char* pos = NULL;
        if (!strcmp(wordPartOfSpeech, "noun")) pos = "n";
        else if (!strcmp(wordPartOfSpeech, "verb")) pos = "v";
        else if (!strcmp(wordPartOfSpeech, "adjective")) pos = "adj";
        else pos = "adv";

        if (expiration > 0)
        {
            payloadLength = snprintf(payloadBuffer, 256, "{\"aps\":{\"alert\":\"Word of the day: %s (%s.)\"},"
                "\"dubsar\":{\"type\":\"wotd\",\"url\":\"dubsar:///wotd/%d\",\"expiration\":%ld}}",
                wordName, pos, wordId, expiration);
        }
        else
        {
            payloadLength = snprintf(payloadBuffer, 256, "{\"aps\":{\"alert\":\"Word of the day: %s (%s.)\"},"
                "\"dubsar\":{\"type\":\"wotd\",\"url\":\"dubsar:///wotd/%d\",\"expiration\":\"%s\"}}",
                wordName, pos, wordId, wotdExpiration);
        }
    }
    else
    {
        timestamp_f(stderr);
        fprintf(stderr, "failed to find WOTD in the DB: %d", rc);
    }

    sqlite3_finalize(statement);
    sqlite3_close(database);

    return payloadLength;
}

static
int
wotdPayload_v210(const char* databasePath, char* payloadBuffer, const char* wotdExpiration)
{
    sqlite3* database = NULL;
    int rc = sqlite3_open_v2(databasePath, &database,
        SQLITE_OPEN_FULLMUTEX|SQLITE_OPEN_READONLY, NULL);
    if (rc != SQLITE_OK)
    {
        timestamp_f(stderr);
        fprintf(stderr, "error %d from sqlite3_open_v2\n", rc);
        return -1;
    }

    const char* sql = "SELECT w.id, w.name, w.part_of_speech, dw.created_at FROM words w "
        "INNER JOIN daily_words dw ON dw.word_id = w.id "
        "ORDER BY dw.created_at DESC LIMIT 1";

    sqlite3_stmt* statement = NULL;
    rc = sqlite3_prepare_v2(database, sql, -1, &statement, NULL);
    if (rc != SQLITE_OK)
    {
        timestamp_f(stderr);
        fprintf(stderr, "error %d from sqlite3_prepare_v2\n", rc);
        sqlite3_close(database);
        return -1;
    }

    int wordId = 0;
    const char* wordName = NULL, *wordPartOfSpeech = NULL;
    const char* dailyWordCreatedAt = NULL;
    int payloadLength = -1;

    if ((rc=sqlite3_step(statement)) == SQLITE_ROW)
    {
        wordId = sqlite3_column_int(statement, 0);
        wordName = (const char*)sqlite3_column_text(statement, 1);
        wordPartOfSpeech = (const char*)sqlite3_column_text(statement, 2);
        dailyWordCreatedAt = (const char*)sqlite3_column_text(statement, 3);

        time_t expiration = 0;
        if (wotdExpiration == NULL || wotdExpiration[0] == '\0')
        {
            char buffer[32];
            strcpy(buffer, dailyWordCreatedAt);
            char* period = strchr(buffer, '.');
            if (period) *period = '\0';
            expiration = parseTimestamp(buffer, "%Y-%m-%d %T") + 86400;
        }

        const char* pos = NULL;
        if (!strcmp(wordPartOfSpeech, "noun")) pos = "n";
        else if (!strcmp(wordPartOfSpeech, "verb")) pos = "v";
        else if (!strcmp(wordPartOfSpeech, "adjective")) pos = "adj";
        else pos = "adv";

        if (expiration > 0)
        {
            payloadLength = snprintf(payloadBuffer, 256, "{\"aps\":{\"alert\":{\"title\":\"Dubsar Word of the Day\", \"body\": \"%s, %s.\"}, \"content-available\":1, \"category\":\"wotd\"},"
                "\"dubsar\":{\"type\":\"wotd\",\"url\":\"dubsar:///wotd/%d\",\"expiration\":%ld}}",
                wordName, pos, wordId, expiration);
        }
        else
        {
            payloadLength = snprintf(payloadBuffer, 256, "{\"aps\":{\"alert\":{\"title\":\"Dubsar Word of the Day\", \"body\": \"%s, %s.\"}, \"content-available\":1, \"category\":\"wotd\"},"
                "\"dubsar\":{\"type\":\"wotd\",\"url\":\"dubsar:///wotd/%d\",\"expiration\":\"%s\"}}",
                wordName, pos, wordId, wotdExpiration);
        }
    }
    else
    {
        timestamp_f(stderr);
        fprintf(stderr, "failed to find WOTD in the DB: %d", rc);
    }

    sqlite3_finalize(statement);
    sqlite3_close(database);

    return payloadLength;
}

static
unsigned long
hexValue(const char* s, size_t l)
{
    char* buffer = malloc(l+1);
    strncpy(buffer, s, l);
    buffer[l] = '\0';

    unsigned long value = strtoul(buffer, NULL, 16);
    free(buffer);
    return value;
}

static
void
buildNotification(unsigned char* notification, const char* deviceToken, const char* payloadBuffer, int n,
    int expiration)
{
    notification[0] = 1;

    static uint32_t identifier = 1;
#ifdef _DEBUG
    timestamp_f(stderr);
    fprintf(stderr, "buffer ID %d: token %s\n", identifier, deviceToken);
#endif // _DEBUG

    memcpy(&notification[1], &identifier, sizeof(identifier));
    ++ identifier;

    // don't attempt to deliver past 12 hours
    uint32_t expiry = htonl(expiration);
    memcpy(&notification[5], &expiry, sizeof(expiry));

    uint16_t tokenSize = htons(32);
    memcpy(&notification[9], &tokenSize, sizeof(tokenSize));

    int j;
    for (j=0; j<32; ++j)
    {
        notification[11+j] = hexValue(deviceToken+2*j, 2);
    }

    uint16_t payloadLength = htons(n);
    memcpy(&notification[43], &payloadLength, sizeof(payloadLength));

    memcpy(&notification[45], payloadBuffer, n);
}

const char*
appVersionForDeviceToken(const char* deviceToken, const char* databasePath)
{
    sqlite3* database = NULL;
    int rc = sqlite3_open_v2(databasePath, &database,
        SQLITE_OPEN_FULLMUTEX|SQLITE_OPEN_READONLY, NULL);
    if (rc != SQLITE_OK)
    {
        timestamp_f(stderr);
        fprintf(stderr, "error %d from sqlite3_open_v2\n", rc);
        return NULL;
    }

    const char* sql = "SELECT client_version FROM device_tokens WHERE token = ? LIMIT 1";
    sqlite3_stmt* statement;

    rc = sqlite3_prepare_v2(database, sql, -1, &statement, NULL);
    if (rc != SQLITE_OK)
    {
        timestamp_f(stderr);
        fprintf(stderr, "error %d from sqlite3_prepare_v2(%s)\n", rc, sql);
        sqlite3_close(database);
        return NULL;
    }

    const char* clientVersion = NULL;
    rc = sqlite3_step(statement);
    if (rc == SQLITE_ROW)
    {
        clientVersion = (const char*)sqlite3_column_text(statement, 1);
    }
    else
    {
        timestamp_f(stderr);
        fprintf(stderr, "error %d from sqlite3_step(%s)\n", rc, sql);
    }

    sqlite3_finalize(statement);
    sqlite3_close(database);

    return clientVersion;
}

int
buildBroadcastWotdPayload(int production, const char* databasePath, const char* wotdExpiration,
    int apnsExpiration, void** buffer, size_t* bufsiz)
{
    char payloadBuffer[256];
    int n = -1;
    int numDevices = 1;
    char* deviceTokens = NULL;

    // 1. Get all tokens for pre 2.1.0 and build that payload for them.
    numDevices = getDeviceTokens_pre210(production, databasePath, &deviceTokens);

    if (numDevices < 0)
    {
        timestamp_f(stderr);
        fprintf(stderr, "failed to build device list\n");
        return 1;
    }

    size_t firstBufferSize = 0;
    void* notificationBuffer = NULL;
    if (numDevices > 0)
    {
        timestamp_f(stderr);
        fprintf(stderr, "sending to %d pre-2.1.0 devices\n", numDevices);

        n = wotdPayload_pre210(databasePath, payloadBuffer, wotdExpiration);

        timestamp_f(stderr);
        fprintf(stderr, "pre-2.1.0 payload (%d): %s\n", n, payloadBuffer);

        // don't ask
        firstBufferSize = (45 + n) * numDevices;
        notificationBuffer = malloc(firstBufferSize);

        int j;
        int count = 0;
        for (j=0; j<numDevices; ++j)
        {
            char token[128];
            strncpy(token, &deviceTokens[j*64], 64);
            token[64] = '\0';
            if (strlen(token) != 64 || strspn(token, "0123456789abcdefABCDEF") != 64) {
                timestamp_f(stderr);
                fprintf(stderr, "invalid device token \"%s\", skipping\n", token);
                continue;
            }

            unsigned char* notification = &((unsigned char*) notificationBuffer)[(45+n)*j];
            buildNotification(notification, token, payloadBuffer, n, apnsExpiration);
            ++ count;
        }
        firstBufferSize = (45 + n) * count;

        free(deviceTokens);
    }

    // 2. Get all tokens for v 2.1.0 and build that payload for them.
    numDevices = getDeviceTokens_v210(production, databasePath, &deviceTokens);

    if (numDevices < 0)
    {
        timestamp_f(stderr);
        fprintf(stderr, "failed to build device list\n");
        if (notificationBuffer) free(notificationBuffer);
        return 1;
    }

    size_t secondBufferSize = 0;
    if (numDevices > 0)
    {
        timestamp_f(stderr);
        fprintf(stderr, "sending to %d v-2.1.0 devices\n", numDevices);

        n = wotdPayload_v210(databasePath, payloadBuffer, wotdExpiration);

        timestamp_f(stderr);
        fprintf(stderr, "v-2.1.0 payload (%d): %s\n", n, payloadBuffer);

        // don't ask
        secondBufferSize = (45 + n) * numDevices;
        notificationBuffer = realloc(notificationBuffer, firstBufferSize + secondBufferSize);

        int j;
        int count = 0;
        for (j=0; j<numDevices; ++j)
        {
            char token[128];
            strncpy(token, &deviceTokens[j*64], 64);
            token[64] = '\0';
            if (strlen(token) != 64 || strspn(token, "0123456789abcdefABCDEF") != 64) {
                timestamp_f(stderr);
                fprintf(stderr, "invalid device token \"%s\", skipping\n", token);
                continue;
            }

            unsigned char* notification = &((unsigned char*) notificationBuffer)[(45+n)*j+firstBufferSize];
            buildNotification(notification, token, payloadBuffer, n, apnsExpiration);
            ++ count;
        }
        secondBufferSize = (45 + n) * count;

        free(deviceTokens);
    }

    *buffer = notificationBuffer;
    *bufsiz = firstBufferSize + secondBufferSize;
    return 0;
}

int
buildNotificationPayload(int wotd, int broadcast, int production,
    const char* deviceToken, const char* databasePath, const char* message,
    const char* url, const char* wotdExpiration, int apnsExpiration,
    void** buffer, size_t* bufsiz)
{
    if (broadcast && wotd)
    {
        return buildBroadcastWotdPayload(production, databasePath, wotdExpiration,
            apnsExpiration, buffer, bufsiz);
    }

    char payloadBuffer[256];
    int n = -1;
    int numDevices = 1;
    char* deviceTokens = NULL;

    if (broadcast)
    {
        numDevices = getDeviceTokens(production, databasePath, &deviceTokens);
    }
    else
    {
        deviceTokens = malloc(64);
        memcpy(deviceTokens, deviceToken, 64);
    }

    if (numDevices <= 0)
    {
        timestamp_f(stderr);
        fprintf(stderr, "failed to build device list\n");
        return 1;
    }

    timestamp_f(stderr);
    fprintf(stderr, "sending to %d device(s)\n", numDevices);

    if (wotd)
    {
        // TODO: Build the right payload based on the version of this DT.
    }
    else
    {
        n = snprintf(payloadBuffer, 256, "{\"aps\":{\"alert\":\"%s\", \"content-available\":1},\"dubsar\":{\"url\":\"%s\"}}", message, url);
    }

    timestamp_f(stderr);
    fprintf(stderr, "payload (%d): %s\n", n, payloadBuffer);

    // don't ask
    *bufsiz = (45 + n) * numDevices;
    *buffer = malloc(*bufsiz);

    int j;
    int count = 0;
    for (j=0; j<numDevices; ++j)
    {
        char token[128];
        strncpy(token, &deviceTokens[j*64], 64);
        token[64] = '\0';
        if (strlen(token) != 64 || strspn(token, "0123456789abcdefABCDEF") != 64) {
            timestamp_f(stderr);
            fprintf(stderr, "invalid device token \"%s\", skipping\n", token);
            continue;
        }

        unsigned char* notification = &((unsigned char*) *buffer)[(45+n)*j];
        buildNotification(notification, token, payloadBuffer, n, apnsExpiration);
        ++ count;
    }
    *bufsiz = (45 + n) * count;

    free(deviceTokens);

    return 0;
}
