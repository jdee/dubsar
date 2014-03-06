/*
 *  Dubsar Dictionary Project
 *  Copyright (C) 2010-14 Jimmy Dee
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

#include <openssl/ssl.h>

/**
 * Execute a TLSv1 handshake over the specified socket \a fd. Verifies the server's
 * SSL cert as well.
 * \param fd a connected socket FD to use
 * \param certPath the path to the .p12 file for peer-to-peer auth
 * \param passphrase the passphrase for the .p12 file
 * \param cacertpath the path to the CA cert file
 * \return a pointer to an SSL object for use with openssl calls
 * \return NULL on failure
 */
extern SSL* makeTlsConnection(int fd, const char* certPath, const char* passphrase, const char* cacertpath);

/**
 * Stop the TLS session gracefully, checking appropriate conditions.
 * Also frees the SSL object and logs.
 * \param ssl the SSL object to stop
 */
extern void stopTlsConnection(SSL* ssl);
