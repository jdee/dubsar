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

#include <openssl/ssl.h>

/**
 * Load the specified .p12 file with the specified passphrase into the specified
 * SSL context to use for peer-to-peer auth. Can also specify explicitly a file for
 * CA certs.
 * \param ctx the SSL_CTX to use
 * \param path the path to the .p12 file to use
 * \param passphrase the passphrase for the .p12 file
 * \param cacertfile the path to the CA cert file to use
 * \return 0 on success
 * \return -1 and logs on error
 */
extern int useCertFile(SSL_CTX* ctx, const char* path, const char* passphrase, const char* cacertfile);
