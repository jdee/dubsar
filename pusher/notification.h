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

#include <sys/types.h>

/**
 * Build a notification payload for immediate transmission. The allocated storage,
 * on success, is stored in *buffer, and the size of the storage in *bufsiz. It is
 * the responsibility of the caller to free(*buffer) after transmission.
 * \param wotd[in] if 1, build a WOTD notification from the database
 * \param broadcast[in] if 1, send to all devices specified by \a production flag
 * \param deviceToken[in] specify in hex to send to a single device (use when \a broadcast is 0)
 * \param databasePath[in] the path to the sqlite database file, for use with \a wotd and \a broadcast
 * \param message[in] when \a wotd is 0, use this for the notification alert message
 * \param url[in] when \a wotd is 0, use this for the notification URL
 * \param buffer[out] address of a pointer to storage; set on return
 * \param bufsiz[out] address of a size_t to receive the size of the allocated buffer on return
 * \return 0 on success
 * \return -1 on failure, and logs
 */
extern int buildNotificationPayload(int wotd, int broadcast, int production,
    const char* deviceToken, const char* databasePath, const char* message,
    const char* url, void** buffer, size_t* bufsiz);
