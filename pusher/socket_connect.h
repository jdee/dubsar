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

/**
 * Create a socket and connect to the specified host and port via TCP. Socket is
 * blocking and enables the Nagle algorithm. The SO_RCVTIMEO socket option is set
 * to 10 seconds.
 *
 * \param host the host to connect to: DNS or dotted IP
 * \param port the port number to connect to on \a host
 * \return a valid file descriptor on success
 * \return -1 on failure and logs errors
 */
extern int socketConnect(const char* host, unsigned short port);
