#!/usr/bin/env bash

# Name: beam-summit-2023
# Description: Script to build out directories with presentation title, speaker, and tags from Beam Summit 2023 schedule
# Author: Jason Walsh <j@wal.sh>


# Check dependencies
command -v iconv >/dev/null 2>&1 || { printf "\e[93m\e[1m%s\e[0m\n" "iconv is required but is not installed. Aborting." >&2; exit 1; }
command -v tr >/dev/null 2>&1 || { printf "\e[93m\e[1m%s\e[0m\n" "tr is required but is not installed. Aborting." >&2; exit 1; }

DEBUG=true

SESSIONS_FILE=beam_summit_2023.txt

# Check for the data file 
if [ ! -f $SESSIONS_FILE ]; then
    echo "$SESSIONS_FILE not found"
    exit 1
else
    echo "Using $SESSIONS_FILE for sessions"
fi

SPEAKER="Sean Jensen-Grey"
TAGS="#BeamSummit2023 #ApacheBeam #DataEngineering #MachineLearning"

echo "Checking for $SPEAKER"

# Loop through files containing schedule
grep -l "$SPEAKER" $SESSIONS_FILE | while read -r file; do
    # Extract title from file and transform for safer directory name
    TITLE="$(sed -n 's/%//p' <<< "$(grep -o '## .*' "$file" | head -n 1 | sed 's/## //' | iconv -t ascii//TRANSLIT//IGNORE | tr '[:upper:]' '[:lower:]' | sed -E 's/[^a-zA-Z0-9]+/-/g')")"

    # Create directory for presentation
    if [ -n "$TITLE" ]; then
	if $DEBUG; then
	    echo "$TITLE"
            sed -n "/$SPEAKER/,/^[0-9]\{2\}:[0-9]\{2\} /p" "$file" | sed 's/\([0-9]\{2\}\:\)\{2\} [AP]M \-[0-9]\{2\}:[0-9]\{2\} PM\:/\n\n\0/g'
	else
            mkdir -p "$TITLE"
            cd "$TITLE"
	    
            # Add speaker and tags to README
            echo "Speaker: $SPEAKER" > README.org
            echo "Tags: $TAGS" >> README.org
	    
            # Add presentation schedule to README
            echo "" >> README.org
            echo "Schedule:" >> README.org
            echo "" >> README.org
            sed -n "/$SPEAKER/,/^[0-9]\{2\}:[0-9]\{2\} /p" "$file" | sed 's/\([0-9]\{2\}\:\)\{2\} [AP]M \-[0-9]\{2\}:[0-9]\{2\} PM\:/\n\n\0/g' >> README.org

            cd ..
	fi
    fi
done
