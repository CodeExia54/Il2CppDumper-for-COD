# Il2CppDumper for COD — Linux build

This zip contains the dumper binary plus `auto_dump.sh`, a helper that finds the
`.so` and `global-metadata.dat` in a folder and runs the dumper for you.

## Which zip do I have?

| Artifact | .NET 7 runtime required? | Size |
| --- | --- | --- |
| `Il2CppDumper-linux-x64-selfcontained` | No — the runtime is bundled | large (~70 MB) |
| `Il2CppDumper-linux-x64-fwdep` | Yes — install [.NET 7](https://dotnet.microsoft.com/en-us/download/dotnet/7.0) | small (~1 MB) |

## Setup

Zip files do not keep the executable bit, so restore it after unzipping:

```bash
unzip Il2CppDumper-linux-x64-selfcontained.zip -d il2cppdumper
cd il2cppdumper
chmod +x Il2CppDumper auto_dump.sh
```

(`auto_dump.sh` will `chmod +x` the dumper itself if you forget, but it needs to
be executable to run at all.)

## Usage — the helper script

Put the game's `libil2cpp.so` (or whatever the `.so` is called) and
`global-metadata.dat` together in one folder, then:

```bash
./auto_dump.sh /path/to/that/folder
```

With no argument it scans the current directory.

The script:

1. finds exactly one `.so` and one `global-metadata.dat` in that folder
   (top level only — it does not recurse). If it finds several, it asks
   which one to use;
2. creates `<so-name>_dump/` next to them;
3. runs the dumper and writes `dump.cs`, `script.json`, the IDA/Ghidra
   scripts and the rest into that folder.

Example:

```
$ ./auto_dump.sh ~/cod
🔍 Scanning in: /home/you/cod
📦 Using:
   SO   : /home/you/cod/libil2cpp.so
   DAT  : /home/you/cod/global-metadata.dat
   OUT  : /home/you/cod/libil2cpp_dump
🚀 Running Il2CppDumper...
✅ Dump completed successfully. Output in: /home/you/cod/libil2cpp_dump
```

### Pointing at a different binary

The script looks for the dumper next to itself, then in `out_ubuntu/`,
`out_fwdep/` and `out/`. To use a binary somewhere else:

```bash
IL2CPPDUMPER=/opt/il2cppdumper/Il2CppDumper ./auto_dump.sh ~/cod
```

## Usage — the dumper directly

```bash
./Il2CppDumper <libil2cpp.so> <global-metadata.dat> <output-dir>
```

Run it with no arguments to be prompted for the paths instead.

## Config

`config.json` sits next to the binary and controls what gets dumped
(method offsets, dummy DLLs, script output, etc.). Edit it before running if you
need to change the defaults.

## Troubleshooting

- **`Permission denied`** — run `chmod +x Il2CppDumper auto_dump.sh`.
- **`No such file or directory` on the fwdep build** — the .NET 7 runtime is
  missing; install it or use the self-contained zip.
- **`No .so file found`** — the `.so` must be in the top level of the folder you
  pass, and files with `backup` or `tmp` in the name are skipped.

## Credits

- Perfare — [Il2CppDumper](https://github.com/Perfare/Il2CppDumper)
