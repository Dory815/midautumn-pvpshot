"""Small lossless NBT reader/writer for packaging the generated 26.2 save."""
import gzip
import struct


class Reader:
    def __init__(self, data):
        self.data, self.offset = data, 0

    def take(self, size):
        result = self.data[self.offset:self.offset + size]
        self.offset += size
        return result

    def number(self, kind):
        return struct.unpack('>' + kind, self.take(struct.calcsize(kind)))[0]

    def string(self):
        return self.take(self.number('H')).decode('utf-8')

    def payload(self, kind):
        if 1 <= kind <= 6:
            return self.number(['', 'b', 'h', 'i', 'q', 'f', 'd'][kind])
        if kind == 7:
            return self.take(self.number('i'))
        if kind == 8:
            return self.string()
        if kind == 9:
            subtype, size = self.number('b'), self.number('i')
            return subtype, [self.payload(subtype) for _ in range(size)]
        if kind == 10:
            result = {}
            while (subtype := self.number('b')):
                name = self.string()
                result[name] = (subtype, self.payload(subtype))
            return result
        if kind in (11, 12):
            return [self.number('i' if kind == 11 else 'q') for _ in range(self.number('i'))]
        raise ValueError(kind)


def string(value):
    value = value.encode('utf-8')
    return struct.pack('>H', len(value)) + value


def payload(kind, value):
    if 1 <= kind <= 6:
        return struct.pack('>' + ['', 'b', 'h', 'i', 'q', 'f', 'd'][kind], value)
    if kind == 7:
        return struct.pack('>i', len(value)) + value
    if kind == 8:
        return string(value)
    if kind == 9:
        subtype, values = value
        return bytes([subtype]) + struct.pack('>i', len(values)) + b''.join(payload(subtype, v) for v in values)
    if kind == 10:
        return b''.join(bytes([t]) + string(k) + payload(t, v) for k, (t, v) in value.items()) + b'\0'
    if kind in (11, 12):
        return struct.pack('>i', len(value)) + b''.join(struct.pack('>i' if kind == 11 else '>q', v) for v in value)
    raise ValueError(kind)


def read(path):
    reader = Reader(gzip.decompress(path.read_bytes()))
    kind, name = reader.number('b'), reader.string()
    return name, (kind, reader.payload(kind))


def write(path, root):
    name, (kind, value) = root
    path.write_bytes(gzip.compress(bytes([kind]) + string(name) + payload(kind, value), mtime=0))
