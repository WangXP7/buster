import struct, os, sys

PCK = sys.argv[1] if len(sys.argv) > 1 else "Nodebuster.pck"  # 用法: python unpack_pck.py <GDPC包文件> [输出目录]
OUT = sys.argv[2] if len(sys.argv) > 2 else "extracted"

def read_i32(f): return struct.unpack("<i", f.read(4))[0]
def read_i64(f): return struct.unpack("<q", f.read(8))[0]

with open(PCK, "rb") as f:
    magic = f.read(4)
    assert magic == b"GDPC", magic
    pack_format = read_i32(f)
    vmaj = read_i32(f); vmin = read_i32(f); vpatch = read_i32(f)
    print(f"pack_format={pack_format} godot={vmaj}.{vmin}.{vpatch}")
    flags = 0
    files_base = 0
    if pack_format >= 2:
        flags = read_i32(f)
        files_base = read_i64(f)
    # reserved 16 int32
    f.read(16*4)
    file_count = read_i32(f)
    print(f"flags={flags} files_base={files_base} file_count={file_count}")
    encrypted = bool(flags & 1)
    print("encrypted:", encrypted)

    entries = []
    for i in range(file_count):
        path_len = read_i32(f)
        path = f.read(path_len).rstrip(b"\x00").decode("utf-8", "replace")
        ofs = read_i64(f)
        size = read_i64(f)
        md5 = f.read(16)
        fflags = 0
        if pack_format >= 2:
            fflags = read_i32(f)
        entries.append((path, ofs, size, fflags))

    # extract
    exts = {}
    for path, ofs, size, fflags in entries:
        rel = path.replace("res://", "").replace("\\", "/")
        outp = os.path.join(OUT, rel)
        os.makedirs(os.path.dirname(outp), exist_ok=True)
        f.seek(files_base + ofs)
        data = f.read(size)
        with open(outp, "wb") as o:
            o.write(data)
        ext = os.path.splitext(rel)[1].lower()
        exts[ext] = exts.get(ext, 0) + 1

    print("\n=== extension counts ===")
    for e, c in sorted(exts.items(), key=lambda x:-x[1]):
        print(f"{e or '(none)'}: {c}")
    print(f"\nExtracted {len(entries)} files to {OUT}")
