#!/bin/bash
# codeexia@codeexia-Nitro-AN515-55:~/Desktop/kernel/Il2CppDumper-for-COD$ ./auto_dump.sh test
# ------------------------------------------------------------
# Auto Il2Cpp Dumper Script
# Usage: ./auto_dump.sh [folder]
# If no folder is given, it uses the current directory.
# It looks for one .so file and one global-metadata.dat file.
# ------------------------------------------------------------

# Locate the Il2CppDumper binary. It can sit next to this script (that is how
# the CI artifacts are laid out) or in one of the local build output folders.
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
DUMPER="${IL2CPPDUMPER:-}"

if [ -z "$DUMPER" ]; then
    for candidate in \
        "$SCRIPT_DIR/Il2CppDumper" \
        "$SCRIPT_DIR/out_ubuntu/Il2CppDumper" \
        "$SCRIPT_DIR/out_fwdep/Il2CppDumper" \
        "$SCRIPT_DIR/out/Il2CppDumper"; do
        if [ -f "$candidate" ]; then
            DUMPER="$candidate"
            break
        fi
    done
fi

# Check if the dumper exists
if [ -z "$DUMPER" ] || [ ! -f "$DUMPER" ]; then
    echo "❌ Error: Il2CppDumper binary not found."
    echo "   Looked next to this script and in out_ubuntu/, out_fwdep/, out/."
    echo "   Set IL2CPPDUMPER=/path/to/Il2CppDumper to point at it explicitly."
    exit 1
fi

# Artifact zips do not preserve the executable bit — restore it if needed.
if [ ! -x "$DUMPER" ]; then
    chmod +x "$DUMPER" 2>/dev/null || {
        echo "❌ Error: $DUMPER is not executable and chmod failed."
        exit 1
    }
fi

# Get the target directory (first argument or current directory)
TARGET_DIR="${1:-.}"

# Resolve to absolute path
cd "$TARGET_DIR" || { echo "❌ Cannot enter directory $TARGET_DIR"; exit 1; }
TARGET_DIR="$(pwd)"

echo "🔍 Scanning in: $TARGET_DIR"

# Find .so files (excluding possible backup or temporary files)
SO_FILES=($(find "$TARGET_DIR" -maxdepth 1 -type f -name "*.so" ! -name "*backup*" ! -name "*tmp*" | sort))
# Find global-metadata.dat (case‑insensitive)
DAT_FILES=($(find "$TARGET_DIR" -maxdepth 1 -type f -iname "global-metadata.dat" | sort))

# Check results
if [ ${#SO_FILES[@]} -eq 0 ]; then
    echo "❌ No .so file found in $TARGET_DIR"
    exit 1
fi

if [ ${#DAT_FILES[@]} -eq 0 ]; then
    echo "❌ No global-metadata.dat file found in $TARGET_DIR"
    exit 1
fi

# If more than one, let the user choose (or just pick the first)
if [ ${#SO_FILES[@]} -gt 1 ]; then
    echo "⚠️  Multiple .so files found:"
    for i in "${!SO_FILES[@]}"; do
        echo "  $((i+1))) $(basename "${SO_FILES[$i]}")"
    done
    read -p "Choose the number (1-${#SO_FILES[@]}, default 1): " choice
    choice=${choice:-1}
    SO_FILE="${SO_FILES[$((choice-1))]}"
else
    SO_FILE="${SO_FILES[0]}"
fi

if [ ${#DAT_FILES[@]} -gt 1 ]; then
    echo "⚠️  Multiple .dat files found:"
    for i in "${!DAT_FILES[@]}"; do
        echo "  $((i+1))) $(basename "${DAT_FILES[$i]}")"
    done
    read -p "Choose the number (1-${#DAT_FILES[@]}, default 1): " choice
    choice=${choice:-1}
    DAT_FILE="${DAT_FILES[$((choice-1))]}"
else
    DAT_FILE="${DAT_FILES[0]}"
fi

# Create output directory (named after the .so file, or "output" if none)
BASE_NAME="$(basename "$SO_FILE" .so)"
OUTPUT_DIR="${TARGET_DIR}/${BASE_NAME}_dump"

echo "📦 Using:"
echo "   SO   : $SO_FILE"
echo "   DAT  : $DAT_FILE"
echo "   OUT  : $OUTPUT_DIR"

mkdir -p "$OUTPUT_DIR"

# Run the dumper
echo "🚀 Running Il2CppDumper..."
"$DUMPER" "$SO_FILE" "$DAT_FILE" "$OUTPUT_DIR"

if [ $? -eq 0 ]; then
    echo "✅ Dump completed successfully. Output in: $OUTPUT_DIR"
else
    echo "❌ Dumper failed. Check the error messages above."
fi
