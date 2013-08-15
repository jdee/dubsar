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

#include <arpa/inet.h>
#include <stdint.h>
#include <stdio.h>
#include <stdlib.h>
#include <string.h>
#include <time.h>

#include <sqlite3.h>

#include "notification.h"

static
int
getDeviceTokens(int production, const char* databasePath, char** buffer)
{
    sqlite3* database = NULL;
    int rc = sqlite3_open_v2(databasePath, &database,
        SQLITE_OPEN_FULLMUTEX|SQLITE_OPEN_READONLY, NULL);
    if (rc != SQLITE_OK)
    {
        fprintf(stderr, "error %d from sqlite3_open_v2\n", rc);
        return -1;
    }

    char sql[256];
    sprintf(sql, "SELECT COUNT(*) FROM device_tokens WHERE production = '%s'",
        (production == 1 ? "t" : "f"));

    sqlite3_stmt* statement = NULL;
    rc = sqlite3_prepare_v2(database, sql, -1, &statement, NULL);
    if (rc != SQLITE_OK)
    {
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
wotdPayload(const char* databasePath, char* payloadBuffer)
{
    sqlite3* database = NULL;
    int rc = sqlite3_open_v2(databasePath, &database,
        SQLITE_OPEN_FULLMUTEX|SQLITE_OPEN_READONLY, NULL);
    if (rc != SQLITE_OK)
    {
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
        fprintf(stderr, "error %d from sqlite3_prepare_v2\n", rc);
        sqlite3_close(database);
        return -1;
    }

    int wordId = 0;
    const char* wordName = NULL, *wordPartOfSpeech = NULL;
    // const char* dailyWordCreatedAt = NULL;
    int payloadLength = -1;

    if ((rc=sqlite3_step(statement)) == SQLITE_ROW)
    {
        wordId = sqlite3_column_int(statement, 0);
        wordName = (const char*)sqlite3_column_text(statement, 1);
        wordPartOfSpeech = (const char*)sqlite3_column_text(statement, 2);
        // dailyWordCreatedAt = (const char*)sqlite3_column_text(statement, 3);

        /* What? No strptime?
        struct tm created;
        strptime(dailyWordCreatedAt, "%Y-%m-%d %T", &created);
        time_t expiration = mktime(&created) + 86400;
         */

        // roughly speaking, we should only be sending WOTD pushes when the
        // WOTD is generated, so this is about right
        time_t expiration = time(NULL) + 86400;

        const char* pos = NULL;
        if (!strcmp(wordPartOfSpeech, "noun")) pos = "n";
        else if (!strcmp(wordPartOfSpeech, "verb")) pos = "v";
        else if (!strcmp(wordPartOfSpeech, "adjective")) pos = "adj";
        else pos = "adv";

        payloadLength = snprintf(payloadBuffer, 256, "{\"aps\":{\"alert\":\"Word of the day: %s (%s.)\"},"
            "\"dubsar\":{\"type\":\"wotd\",\"url\":\"dubsar:///wotd/%d\",\"expiration\":%ld}}",
            wordName, pos, wordId, expiration);
    }
    else
    {
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
buildNotification(char* notification, const char* deviceToken, const char* payloadBuffer, int n)
{
    notification[0] = 1;

    /*
     * TODO: Increment identifier with each notification
     */
    uint32_t identifier = 1;
    memcpy(&notification[1], &identifier, sizeof(identifier));

    uint32_t expiry = htonl(time(NULL) + 86400);
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

int
buildNotificationPayload(int wotd, int broadcast, int production,
    const char* deviceToken, const char* databasePath, const char* message,
    const char* url, void** buffer, size_t* bufsiz)
{
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
        fprintf(stderr, "failed to build device list\n");
        return 1;
    }

    if (wotd)
    {
        n = wotdPayload(databasePath, payloadBuffer);
    }
    else
    {
        snprintf(payloadBuffer, 256, "{\"aps\":{\"alert\":\"%s\"},\"dubsar\":{\"url\":\"%s\"}}", message, url);
    }

    fprintf(stderr, "payload (%d): %s\n", n, payloadBuffer);

    // don't ask
    *bufsiz = (45 + n) * numDevices;
    *buffer = malloc(*bufsiz);

    int j;
    for (j=0; j<numDevices; ++j)
    {
        char* notification = &((char*) *buffer)[(45+n)*j];
        buildNotification(notification, &deviceTokens[j*64], payloadBuffer, n);
    }

    free(deviceTokens);

    return 0;
}
