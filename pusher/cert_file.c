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

#include <openssl/err.h>
#include <openssl/pkcs12.h>

#include "cert_file.h"
#include "timestamp.h"

int
useCertFile(SSL_CTX* ctx, const char* path, const char* passphrase, const char* cacertfile)
{
    FILE *p12_file;
    PKCS12 *p12_cert = NULL;
    EVP_PKEY *pkey;
    X509 *x509_cert;
    
    p12_file = fopen(path, "r");
    if (!p12_file)
    {
        timestamp_f(stderr);
        perror(path);
        return -1;
    }

    d2i_PKCS12_fp(p12_file, &p12_cert);
    fclose(p12_file);

    if (!PKCS12_parse(p12_cert, passphrase, &pkey, &x509_cert, NULL))
    {
        int error = ERR_get_error();
        timestamp_f(stderr);
        fprintf(stderr, "failed to parse p12 file; error %d\n", error);
        PKCS12_free(p12_cert);
        return -1;
    }
    PKCS12_free(p12_cert);

    if (!SSL_CTX_use_certificate(ctx, x509_cert))
    {
        int error = ERR_get_error();
        timestamp_f(stderr);
        fprintf(stderr, "failed to set cert for SSL context; error %d\n", error);
        X509_free(x509_cert);
        EVP_PKEY_free(pkey);
        return -1;
    }
    X509_free(x509_cert);

    if (!SSL_CTX_use_PrivateKey(ctx, pkey))
    {
        int error = ERR_get_error();
        timestamp_f(stderr);
        fprintf(stderr, "failed to set private key for SSL context; error %d\n", error);
        EVP_PKEY_free(pkey);
        return -1;
    }
    EVP_PKEY_free(pkey);

    if (cacertfile && *cacertfile && !SSL_CTX_load_verify_locations(ctx, cacertfile, NULL))
    {
        timestamp_f(stderr);
        fprintf(stderr, "failed to load root cert for verification from %s\n", cacertfile);
        return -1;
    }

    return 0;
}
