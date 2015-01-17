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

#include <netdb.h>
#include <netinet/in.h>
#include <netinet/tcp.h>
#include <string.h>
#include <sys/socket.h>
#include <unistd.h>

#include "socket_connect.h"
#include "timestamp.h"

int socketConnect(const char* host, unsigned short port)
{
    char sport[8];
    sprintf(sport, "%d", port);

    struct addrinfo hints;
    memset(&hints, 0, sizeof(hints));
    hints.ai_family = AF_INET;
    hints.ai_socktype = SOCK_STREAM;
    hints.ai_flags = AI_NUMERICSERV;

    struct addrinfo* result;
    int rc = getaddrinfo(host, sport, &hints, &result);
    if (rc != 0)
    {
        timestamp_f(stderr);
        fprintf(stderr, "%s\n", gai_strerror(rc));
        return -1;
    }

    int s = socket(AF_INET, SOCK_STREAM, 0);
    if (s == -1)
    {
        timestamp_f(stderr);
        perror("socket");
        return -1;
    }

    int on = 1;
    if (setsockopt(s, SOL_SOCKET, SO_REUSEADDR, &on, sizeof(on)))
    {
        timestamp_f(stderr);
        perror("SO_REUSEADDR");
        return -1;
    }

    struct timeval timeout;
    timeout.tv_sec = 10;
    timeout.tv_usec = 0;
    if (setsockopt(s, SOL_SOCKET, SO_RCVTIMEO, &timeout, sizeof(timeout)))
    {
        timestamp_f(stderr);
        perror("SO_RCVTIMEO");
        return -1;
    }

    int off = 0;
    if (setsockopt(s, IPPROTO_TCP, TCP_NODELAY, &off, sizeof(off)))
    {
        timestamp_f(stderr);
        perror("TCP_NODELAY");
        return -1;
    }

    int connected = 0;
    while (result)
    {
        if (connect(s, result->ai_addr, result->ai_addrlen) == 0)
        {
            connected = 1;
            break;
        }

        result = result->ai_next;
    }

    freeaddrinfo(result);

    if (!connected)
    {
        timestamp_f(stderr);
        fprintf(stderr, "Failed to connect to %s:%d\n", host, port);
        close(s);
        return -1;
    }

    return s;
}
