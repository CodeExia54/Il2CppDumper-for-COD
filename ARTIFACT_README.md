# Il2CppDumper for COD — build artifact

This zip contains the dumper binary plus a helper script that finds the `.so`
and `global-metadata.dat` in a folder and runs the dumper for you:
`auto_dump.sh` on Linux, `auto_dump.bat` on Windows.

## Which zip do I have?

| Artifact | .NET 7 runtime required? | Size |
| --- | --- | --- |
| `Il2CppDumper-<rid>-selfcontained` | No — the runtime is bundled | large (~70 MB) |
| `Il2CppDumper-<rid>-fwdep` | Yes — install [.NET 7](https://dotnet.microsoft.com/en-us/download/dotnet/7.0) | small (~1 MB) |

`<rid>` is `linux-x64` or `win-x64`.

## Setup

### Linux

Zip files do not keep the executable bit, so restore it after unzipping:

```bash
unzip Il2CppDumper-linux-x64-selfcontained.zip -d il2cppdumper
cd il2cppdumper
chmod +x Il2CppDumper auto_dump.sh
```

(`auto_dump.sh` will `chmod +x` the dumper itself if you forget, but it needs to
be executable to run at all.)

### Windows

Unzip anywhere and you are done. Windows may mark files downloaded from the
internet as blocked — if `Il2CppDumper.exe` refuses to start, right-click it →
Properties → Unblock.

## Usage — the helper script

Put the game's `libil2cpp.so` (or whatever the `.so` is called) and
`global-metadata.dat` together in one folder, then:

```bash
# Linux
./auto_dump.sh /path/to/that/folder
```

```bat
:: Windows
auto_dump.bat C:\path\to\that\folder
```

With no argument it scans the current directory. On Windows you can also drag a
folder onto `auto_dump.bat` in Explorer.

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

The script looks for the dumper next to itself, then in `out_ubuntu/` /
`out_win/`, `out_fwdep/` and `out/`. To use a binary somewhere else, set
`IL2CPPDUMPER`:

```bash
IL2CPPDUMPER=/opt/il2cppdumper/Il2CppDumper ./auto_dump.sh ~/cod
```

```bat
set IL2CPPDUMPER=D:\tools\Il2CppDumper.exe
auto_dump.bat C:\cod
```

## Usage — the dumper directly

```bash
./Il2CppDumper <libil2cpp.so> <global-metadata.dat> <output-dir>
```

```bat
Il2CppDumper.exe <libil2cpp.so> <global-metadata.dat> <output-dir>
```

Run it with no arguments to be prompted for the paths instead.

## Config

`config.json` sits next to the binary and controls what gets dumped
(method offsets, dummy DLLs, script output, etc.). Edit it before running if you
need to change the defaults.

## Troubleshooting

- **`Permission denied` (Linux)** — run `chmod +x Il2CppDumper auto_dump.sh`.
- **`No such file or directory` on the fwdep build** — the .NET 7 runtime is
  missing; install it or use the self-contained zip.
- **Windows says the app can't start / a DLL is missing** — same thing: install
  the .NET 7 runtime, or use the self-contained zip.
- **`No .so file found`** — the `.so` must be in the top level of the folder you
  pass, and files with `backup` or `tmp` in the name are skipped.

## Credits

- Perfare — [Il2CppDumper](https://github.com/Perfare/Il2CppDumper)
