# Il2CppDumper for COD

Here is a Unity Il2CppDumper I made that works for Call of Duty Mobile.

It works for both Android and iOS.

## Requirements

- You need to install [.NET 7.0](https://dotnet.microsoft.com/en-us/download/dotnet/thank-you/runtime-7.0.20-windows-x64-installer) in order to run
## Usage

Run `Il2CppDumper.exe` and choose the `il2cpp` executable file and `global-metadata.dat` file, then enter the information as prompted

The program will then generate all the output files in current working directory

For more details, check out the credit.

### Helper scripts

`auto_dump.sh` (Linux) and `auto_dump.bat` (Windows) do it for you — point one
at a folder holding the `.so` and `global-metadata.dat` and it picks them up and
writes the output to `<so-name>_dump/`:

```bash
./auto_dump.sh /path/to/folder
```

```bat
auto_dump.bat C:\path\to\folder
```

The build artifacts ship the matching script alongside the binary. See
[ARTIFACT_README.md](ARTIFACT_README.md) — the same file is included in those
zips as `README.md`.

## Credits

 - Perface - [Il2CppDumper](https://github.com/Perfare/Il2CppDumper)
