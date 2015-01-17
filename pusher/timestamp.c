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

#define _XOPEN_SOURCE

#include <sys/time.h>

#include "timestamp.h"

void
timestamp(time_t t, char* buffer, size_t max)
{
    struct tm local;
    localtime_r(&t, &local);

    strftime(buffer, max, "%m-%d-%Y %T", &local);
}

void
timestamp_f(FILE* fp)
{
    struct timeval now;
    gettimeofday(&now, NULL);

    char buffer[256];
    timestamp(time(NULL), buffer, 255);

    fprintf(fp, "%s", buffer);
    fprintf(fp, ".%06ld ", now.tv_usec);
}

time_t
parseTimestamp(const char* timestamp, const char* format)
{
    struct tm utc;
    strptime(timestamp, format, &utc);
    return mktime(&utc);
}
