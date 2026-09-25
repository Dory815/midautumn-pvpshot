"""按**原版协议**查一次服务器状态（server list ping），用来验证"不装模组的客户端能不能看到/连上"。

这一步是匿名、无认证的：只要服务器能被原版协议识别，原版客户端的服务器列表就能显示它。

用法：
    python tools/server-status.py [主机] [端口]
默认 127.0.0.1:25566。
"""

from __future__ import annotations

import json
import socket
import struct
import sys


def write_varint(value: int) -> bytes:
    out = b""
    while True:
        byte = value & 0x7F
        value >>= 7
        if value:
            out += bytes([byte | 0x80])
        else:
            out += bytes([byte])
            return out


def read_varint(sock: socket.socket) -> int:
    result = 0
    shift = 0
    while True:
        byte = sock.recv(1)
        if not byte:
            raise EOFError("连接被关闭")
        result |= (byte[0] & 0x7F) << shift
        if not byte[0] & 0x80:
            return result
        shift += 7


def main(host: str, port: int) -> int:
    with socket.create_connection((host, port), timeout=8) as sock:
        # handshake: protocol=-1(仅状态查询), host, port, next_state=1
        host_bytes = host.encode()
        payload = (
            write_varint(0x00)
            + write_varint(0xFFFFFFFF)
            + write_varint(len(host_bytes))
            + host_bytes
            + struct.pack(">H", port)
            + write_varint(1)
        )
        sock.sendall(write_varint(len(payload)) + payload)
        sock.sendall(write_varint(1) + write_varint(0x00))  # status request

        read_varint(sock)               # packet length
        read_varint(sock)               # packet id
        length = read_varint(sock)
        data = b""
        while len(data) < length:
            data += sock.recv(length - len(data))

    info = json.loads(data.decode("utf-8"))
    print("== 原版协议状态查询成功 ==")
    print("版本:", info.get("version", {}).get("name"), "protocol", info.get("version", {}).get("protocol"))
    print("在线/上限:", info.get("players", {}).get("online"), "/", info.get("players", {}).get("max"))
    motd = info.get("description")
    print("MOTD:", json.dumps(motd, ensure_ascii=False))
    sample = info.get("players", {}).get("sample") or []
    if sample:
        print("玩家样例:", ", ".join(p.get("name", "?") for p in sample))
    print("服务端上报的模组信息(fml/modinfo):", "有" if "modinfo" in info else "无")
    return 0


if __name__ == "__main__":
    host = sys.argv[1] if len(sys.argv) > 1 else "127.0.0.1"
    port = int(sys.argv[2]) if len(sys.argv) > 2 else 25566
    raise SystemExit(main(host, port))
