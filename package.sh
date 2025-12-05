#!/usr/bin/env bash

# This script packages the SanctuaryComms addon for different WoW versions.
# Usage: ./package.sh <version>
# Example: ./package.sh Retail

# --- Configuration ---
ADDON_NAME="SanctuaryComms"
# Source is the current directory
SOURCE_DIR="."
# Release artifacts will be created in the parent directory
RELEASE_DIR="../release"

# --- Script Logic ---

# 1. Validate input
if [ -z "$1" ]; then
  echo "Usage: $0 <Retail|Classic|Ascension>"
  exit 1
fi

VERSION_NAME=$1
TOC_FILE=""

if [ "$VERSION_NAME" == "Retail" ]; then
  TOC_FILE="${ADDON_NAME}.toc"
elif [ "$VERSION_NAME" == "Classic" ]; then
  TOC_FILE="${ADDON_NAME}_Classic.toc"
elif [ "$VERSION_NAME" == "Ascension" ]; then
  TOC_FILE="${ADDON_NAME}_Ascension.toc"
else
  echo "Error: Invalid version specified. Use 'Retail', 'Classic', or 'Ascension'."
  exit 1
fi

PACKAGE_DIR="${RELEASE_DIR}/${ADDON_NAME}"
ZIP_NAME="../${ADDON_NAME}-${VERSION_NAME}.zip"

echo "Packaging for ${VERSION_NAME}..."

# 2. Clean up and create directories
rm -rf "$RELEASE_DIR"
mkdir -p "$PACKAGE_DIR"

# 3. Copy addon files
echo "Copying files..."
cp ./*.lua "$PACKAGE_DIR/"
cp -r ./libs "$PACKAGE_DIR/"
cp ./${TOC_FILE} "${PACKAGE_DIR}/${ADDON_NAME}.toc"

# 4. Create the zip archive
echo "Creating archive: ${ZIP_NAME}"
(cd "$RELEASE_DIR" && zip -r "${ZIP_NAME}" "$ADDON_NAME")

# 5. Clean up temporary directory
rm -rf "$RELEASE_DIR"

echo "Done. Addon packaged as ${ZIP_NAME}"
