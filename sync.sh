#!/bin/zsh

# Ensure ADB is installed
if ! command -v adb &> /dev/null; then
    echo "ADB is not installed. Please install it first."
    exit 1
fi

# Create a base directory to store the images
BASE_DIR="$HOME/Pictures"
mkdir -p "$BASE_DIR"

# Start the ADB server
adb start-server

echo "Waiting for the Android device"
# Wait for the device
adb wait-for-device

# Pull images from the device
echo "Pulling images from device..."

FILES=($(adb shell find /sdcard/DCIM/Camera -type f ! -name ".trashed*"))

for FILE in "${FILES[@]}"; do
    # Get the last modified time of the file from the device
    echo $FILE
    MOD_TIME=$(adb shell stat -c %Y "$FILE")
    
    LC_TIME=fr_FR.UTF-8


    YEAR=$(LC_TIME=$LC_TIME date -r $MOD_TIME +%Y)
    MONTH=$(LC_TIME=$LC_TIME date -r $MOD_TIME +%m)
    MONTH_NAME=$(LC_TIME=$LC_TIME date -r $MOD_TIME +%B)

    MONTH_NAME=$(echo "$MONTH_NAME" | awk '{print toupper(substr($0,1,1)) tolower(substr($0,2))}')

    FOLDER_NAME="$YEAR/$MONTH $MONTH_NAME"
    
    # Create a directory for the month if it doesn't exist
    DEST_DIR="$BASE_DIR/$FOLDER_NAME"
    mkdir -p "$DEST_DIR"
    
    echo $DEST_DIR
    # Pull the file to the appropriate directory
    adb pull "$FILE" "$DEST_DIR/"
done

echo "All images have been transferred and organized by month."
