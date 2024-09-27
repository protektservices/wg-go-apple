#!/bin/bash

if [[ -z $1 ]]; then
    echo "Provide an output path for the XCFramework"
    exit 1
fi

PLATFORMS_PATH="build"
FRAMEWORK_PATH="$1"
ARGS=""

# Build arguments for xcodebuild
for ARG in $(ls $PLATFORMS_PATH); do
    ARGS+="-library $PLATFORMS_PATH/$ARG/libwg-go.a "
    ARGS+="-headers $PLATFORMS_PATH/$ARG/Headers2 "
done

# Generate XCFramework
echo "Generating XCFramework..."
rm -rf "$FRAMEWORK_PATH"
xcodebuild -create-xcframework $ARGS -output "$FRAMEWORK_PATH"

# Rename Headers to Headers2 and update plists
echo "Renaming Headers to Headers2 and updating plists..."
find "$FRAMEWORK_PATH" -type d -name "Headers" | while read -r dir; do
    mv "$dir" "${dir}2"
    plist_dir=$(dirname "$dir")
    plist_path="$plist_dir/Info.plist"
    if [ -f "$plist_path" ]; then
        sed -i '' 's/<string>Headers<\/string>/<string>Headers2<\/string>/' "$plist_path"
    fi
done

# Update main Info.plist
main_plist="$FRAMEWORK_PATH/Info.plist"
if [ -f "$main_plist" ]; then
    echo "Updating main Info.plist..."
    sed -i '' 's/<string>Headers<\/string>/<string>Headers2<\/string>/' "$main_plist"
fi

echo "XCFramework modification completed."
