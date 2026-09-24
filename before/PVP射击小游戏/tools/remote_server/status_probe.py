#!/usr/bin/env python3
"""Read Minecraft's public status without logging in or changing game state."""
import json
import socket
import struct
import sys


def varint(value):
    value &= 0xffffffff
    result = bytearray()
    while True:
        byte = value & 127
        value >>= 7
        result.append(byte | (128 if value else 0))
        if not value:
            return bytes(result)


def receive(sock, size):
    result = bytearray()
    while len(result) < size:
        chunk = sock.recv(size - len(result))
        if not chunk:
            raise ConnectionError('Connection closed before complete status response')
        result.extend(chunk)
    return bytes(result)


def read_varint(sock):
    result = 0
    for shift in range(0, 35, 7):
        byte = receive(sock, 1)[0]
        result |= (byte & 127) << shift
        if not byte & 128:
            return result
    raise ValueError('Invalid VarInt')


host = sys.argv[1]
port = int(sys.argv[2])
with socket.create_connection((host, port), timeout=8) as sock:
    address = host.encode()
    handshake = b'\0' + varint(-1) + varint(len(address)) + address + struct.pack('>H', port) + b'\1'
    sock.sendall(varint(len(handshake)) + handshake + b'\1\0')
    packet_size = read_varint(sock)
    if not 0 < packet_size <= 1024 * 1024:
        raise ValueError('Unexpected status packet size')
    assert read_varint(sock) == 0, 'Unexpected status packet type'
    size = read_varint(sock)
    if not 0 < size < packet_size:
        raise ValueError('Invalid status JSON size')
    result = json.loads(receive(sock, size))
    result.pop('favicon', None)
    print(json.dumps(result, ensure_ascii=False, indent=2))
