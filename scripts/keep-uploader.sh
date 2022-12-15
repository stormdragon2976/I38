#!/bin/bash

# Use yad to enter the name of the bucket
NAME=$(yad --entry --title "Enter bucket name" --text "Enter the name of the bucket the file should be uploaded to:")

# If bucket name is blank, exit the script
if [-z "$NAME"]; then
  exit 1
fi

# Use yad to select a file
FILE=$(yad --file --title "Select a file to upload" --width=400 --height=200)

# If no file is selected, exit the script
if [ -z "$FILE" ]; then
  exit 1
fi

# Use yad to ask for an optional password
PASSWORD=$(yad --entry --title "Enter a password" --text "Enter a password for the file (optional)")

# If password is empty, don't include it in the curl command
if [ -z "$PASSWORD" ]; then
  # Use curl to upload the file and store the result in the RESULT variable
  RESULT=$(curl --upload-file {$FILE} https://{$NAME}.keep.sh)
else
  # Use curl to upload the file with the password and store the result in the RESULT variable
  RESULT=$(curl --upload-file {$FILE} https://{$NAME}.keep.sh -H "Authorization: ${PASSWORD}")
fi

# If the bucket name is "free", use yad to display the result of the file upload
if [ "$NAME" == "free" ]; then
  yad --title "File Upload Result" --text "${RESULT}"
fi
