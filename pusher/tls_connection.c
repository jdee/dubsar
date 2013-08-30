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

#include <unistd.h>

#include <openssl/err.h>
#include <openssl/pem.h>

#include "cert_file.h"
#include "timestamp.h"
#include "tls_connection.h"

SSL*
makeTlsConnection(int fd, const char* certPath, const char* passphrase, const char* cacertpath)
{
    SSL_CTX* ctx = NULL;
    SSL* ssl = NULL;
    int result = -1;
    X509* cert = NULL;
    X509_NAME* subjectName = NULL;

    /*
     * Initialize openssl
     */

    OpenSSL_add_all_algorithms();
    ERR_load_BIO_strings();
    ERR_load_crypto_strings();
    SSL_load_error_strings();

    if (SSL_library_init() < 0)
    {
        timestamp_f(stderr);
        fprintf(stderr, "failed to initialize ssl library\n");
        return NULL;
    }

    /*
     * TLS 1 handshake
     */

    ctx = SSL_CTX_new(TLSv1_client_method());
    if (!ctx)
    {
        timestamp_f(stderr);
        fprintf(stderr, "failed to initialize ssl context\n");
        close(fd);
        return NULL;
    }

    if (useCertFile(ctx, certPath, passphrase, cacertpath))
    {
        timestamp_f(stderr);
        fprintf(stderr, "failed to load cert from file\n");
        SSL_CTX_free(ctx);
        close(fd);
        return NULL;
    }

    ssl = SSL_new(ctx);
    if (!ssl)
    {
        timestamp_f(stderr);
        fprintf(stderr, "SSL_new failed\n");
        SSL_CTX_free(ctx);
        close(fd);
        return NULL;
    }

    SSL_CTX_free(ctx);
    SSL_set_fd(ssl, fd);

    /*
     * By default, APNS picks AES256-SHA, but with TLSv1, that CBC-based cipher
     * is vulnerable to the BEAST. The server seems to accept RC4-SHA. Put both in this order
     * to make sure we connect, just in case. No support for forward secrecy seems to be
     * available.
     */
    SSL_set_cipher_list(ssl, "RC4-SHA:AES256-SHA");

    if (SSL_connect(ssl) <= 0)
    {
        int error = ERR_get_error();
        timestamp_f(stderr);
        fprintf(stderr, "error %d from SSL_connect: %s\n", error, ERR_error_string(error, NULL));
        SSL_free(ssl);
        return NULL;
    }

    timestamp_f(stderr);
    fprintf(stderr, "TLSv1 handshake successful\n");
    timestamp_f(stderr);
    fprintf(stderr, "cipher: %s\n", SSL_get_cipher(ssl));

    cert = SSL_get_peer_certificate(ssl);
    if (cert == NULL)
    {
        timestamp_f(stderr);
        fprintf(stderr, "peer cert is NULL\n");
        stopTlsConnection(ssl);
        return NULL;
    }
    else
    {
        subjectName = X509_get_subject_name(cert);
        timestamp_f(stderr);
        X509_NAME_print_ex_fp(stderr, subjectName, 2, 0);
        fprintf(stderr, "\n");

#ifdef _DEBUG
        PEM_write_X509(stderr, cert);
#endif // _DEBUG
    }

    timestamp_f(stderr);
    fprintf(stderr, "peer certificate is ");
    result = SSL_get_verify_result(ssl);
    if (result == X509_V_OK)
    {
        fprintf(stderr, "valid\n");
    }
    else
    {
        fprintf(stderr, "invalid: %d\n", result);
        stopTlsConnection(ssl);
        return NULL;
    }

    return ssl;
}

void
stopTlsConnection(SSL* ssl)
{
    int rc = -1;

    /*
     * See https://www.openssl.org/docs/ssl/SSL_shutdown.html#
     * Should it be while instead of if?
     */
    timestamp_f(stderr);
    fprintf(stderr, "calling SSL_shutdown\n");
    if ((rc=SSL_shutdown(ssl)) == 0)
    {
        timestamp_f(stderr);
        fprintf(stderr, "calling SSL_shutdown again\n");
        rc = SSL_shutdown(ssl);
    }

    if (rc <= 0)
    {
        timestamp_f(stderr);
        fprintf(stderr, "failed to shut down TLS connection successfully\n");
    }
    else
    {
        timestamp_f(stderr);
        fprintf(stderr, "shut down TLS connection\n");
    }

    SSL_free(ssl);
}
