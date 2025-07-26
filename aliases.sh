# API base URL
API_URL="https://cornflowerblue-elephant-797936.hostingersite.com/api.php"

# Send a new message (accepts multi-word input)
send() {
    local message="$*"
    curl -s -X POST --data-urlencode "message=$message" "$API_URL" | jq .
}

# Search messages (accepts multi-word search term)
get() {
    local data term_width content_w id_w date_w padding

    # Fetch data based on flags
    if [[ "$1" == "-a" ]]; then
        data=$(curl -s -G --data-urlencode "all=1" "$API_URL")
    elif [[ "$1" =~ ^-[0-9]+$ ]]; then
        limit="${1#-}"
        data=$(curl -s -G --data-urlencode "limit=$limit" "$API_URL")
    else
        term="$*"
        data=$(curl -s -G --data-urlencode "search=$term" "$API_URL")
    fi

    if [[ -z "$data" || "$data" == "[]" ]]; then
        echo -e "\033[31mNo messages found.\033[0m"
        return
    fi

    # Detect terminal width
    term_width=$(tput cols 2>/dev/null || echo 120)
    id_w=5
    date_w=20
    padding=10  # space for borders & spacing
    content_w=$((term_width - id_w - date_w - padding))
    if ((content_w < 20)); then
        content_w=20  # Minimum content width
    fi

    # Convert JSON to TSV
    local table
    table=$(echo "$data" | jq -r '.[] | [.id, .content, .created_at] | @tsv')

    # Render dynamic table
    awk -F'\t' -v id_w="$id_w" -v content_w="$content_w" -v date_w="$date_w" 'BEGIN {
        HEADER="\033[1;34m"
        ID="\033[1;32m"
        CONTENT="\033[0;36m"
        DATE="\033[0;33m"
        RESET="\033[0m"

        # Top border
        printf "┌"; for(i=0;i<id_w+2;i++) printf "─";
        printf "┬"; for(i=0;i<content_w+2;i++) printf "─";
        printf "┬"; for(i=0;i<date_w+2;i++) printf "─";
        printf "┐\n";

        # Header
        printf "│ "HEADER"%-*s"RESET" │ "HEADER"%-*s"RESET" │ "HEADER"%-*s"RESET" │\n",
            id_w, "ID", content_w, "Content", date_w, "Created At";

        # Header separator
        printf "├"; for(i=0;i<id_w+2;i++) printf "─";
        printf "┼"; for(i=0;i<content_w+2;i++) printf "─";
        printf "┼"; for(i=0;i<date_w+2;i++) printf "─";
        printf "┤\n";
    }
    {
        id=$1; content=$2; date=$3;

        # Wrap content across multiple lines
        n = int((length(content) + content_w - 1) / content_w);
        for (i=1; i<=n; i++) {
            line = substr(content, (i-1)*content_w+1, content_w);
            if (i == 1) {
                printf "│ "ID"%-*s"RESET" │ "CONTENT"%-*s"RESET" │ "DATE"%-*s"RESET" │\n",
                    id_w, id, content_w, line, date_w, date;
            } else {
                printf "│ %-*s │ "CONTENT"%-*s"RESET" │ %-*s │\n",
                    id_w, "", content_w, line, date_w, "";
            }
        }
    }
    END {
        # Bottom border
        printf "└"; for(i=0;i<id_w+2;i++) printf "─";
        printf "┴"; for(i=0;i<content_w+2;i++) printf "─";
        printf "┴"; for(i=0;i<date_w+2;i++) printf "─";
        printf "┘\n";
    }' <<< "$table"
}

# Copy raw message content by ID
copy() {
    local id="$1"
    local message=$(curl -s -G --data-urlencode "all=1" "$API_URL" | jq -r ".[] | select(.id==$id) | .content")
    if [[ -z "$message" ]]; then
        echo -e "\033[31mMessage not found.\033[0m"
        return 1
    fi
    echo -n "$message" | xclip -selection clipboard
    echo -e "\033[32mCopied message for ID $id to clipboard.\033[0m"
}

# Get the latest message (1 row), auto-copy to clipboard
getl() {
    # Fetch only the latest message (1 row)
    local data
    data=$(curl -s -G --data-urlencode "limit=1" "$API_URL")

    if [[ -z "$data" || "$data" == "[]" ]]; then
        echo -e "\033[31mNo messages found.\033[0m"
        return
    fi

    # Extract message fields
    local id message created
    id=$(echo "$data" | jq -r '.[0].id')
    message=$(echo "$data" | jq -r '.[0].content')
    created=$(echo "$data" | jq -r '.[0].created_at')

    # Copy message to clipboard
    echo -n "$message" | xclip -selection clipboard

    # Detect terminal width dynamically
    local term_width content_w id_w date_w padding
    term_width=$(tput cols 2>/dev/null || echo 120)
    id_w=5
    date_w=20
    padding=10  # For borders and spacing
    content_w=$((term_width - id_w - date_w - padding))
    if ((content_w < 20)); then
        content_w=20  # Minimum width
    fi

    # Render table for the single row
    awk -v id="$id" -v msg="$message" -v date="$created" -v id_w="$id_w" -v content_w="$content_w" -v date_w="$date_w" 'BEGIN {
        HEADER="\033[1;34m"
        ID="\033[1;32m"
        CONTENT="\033[0;36m"
        DATE="\033[0;33m"
        RESET="\033[0m"

        # Top border
        printf "┌"; for(i=0;i<id_w+2;i++) printf "─";
        printf "┬"; for(i=0;i<content_w+2;i++) printf "─";
        printf "┬"; for(i=0;i<date_w+2;i++) printf "─";
        printf "┐\n";

        # Header row
        printf "│ "HEADER"%-*s"RESET" │ "HEADER"%-*s"RESET" │ "HEADER"%-*s"RESET" │\n",
            id_w, "ID", content_w, "Content", date_w, "Created At";

        # Header separator
        printf "├"; for(i=0;i<id_w+2;i++) printf "─";
        printf "┼"; for(i=0;i<content_w+2;i++) printf "─";
        printf "┼"; for(i=0;i<date_w+2;i++) printf "─";
        printf "┤\n";

        # Wrap long content across multiple lines
        n = int((length(msg) + content_w - 1) / content_w);
        for (i=1; i<=n; i++) {
            line = substr(msg, (i-1)*content_w+1, content_w);
            if (i == 1) {
                printf "│ "ID"%-*s"RESET" │ "CONTENT"%-*s"RESET" │ "DATE"%-*s"RESET" │\n",
                    id_w, id, content_w, line, date_w, date;
            } else {
                printf "│ %-*s │ "CONTENT"%-*s"RESET" │ %-*s │\n",
                    id_w, "", content_w, line, date_w, "";
            }
        }

        # Bottom border
        printf "└"; for(i=0;i<id_w+2;i++) printf "─";
        printf "┴"; for(i=0;i<content_w+2;i++) printf "─";
        printf "┴"; for(i=0;i<date_w+2;i++) printf "─";
        printf "┘\n";

        # Confirmation
        printf "\033[32mCopied latest message (ID %s) to clipboard.\033[0m\n", id;
    }'
}
# Update a message by ID (first arg is ID, rest is the new text)
update() {
    local id="$1"
    shift
    local new_text="$*"
    curl -s -X PUT --data-urlencode "id=$id" --data-urlencode "content=$new_text" "$API_URL" | jq .
}

# Delete a message by ID
delete() {
    local id="$1"
    curl -s -X DELETE --data-urlencode "id=$id" "$API_URL" | jq .
}
