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

#include <stdio.h>
#include <time.h>

/**
 * Generate a human-readable timestamp from a time_t.
 * \param t the time_t as input
 * \param buffer a buffer in which to store the formatted timestamp
 * \param max the size of \a buffer, in bytes
 */
extern void timestamp(time_t t, char* buffer, size_t max);

/**
 * Write a subsecond timestamp to the supplied \a fp.
 * \param fp the FILE pointer to which to write the timestamp
 */
extern void timestamp_f(FILE* fp);

extern time_t parseTimestamp(const char* timestamp, const char* format);
