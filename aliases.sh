# API base URL
API_URL="https://cornflowerblue-elephant-797936.hostingersite.com/api.php"

# Send a new message (accepts multi-word input)
send() {
    local message="$*"
    curl -s -X POST -d "message=$message" "$API_URL" | jq .
}

# Search messages (accepts multi-word search term)
get() {
    local term="$*"
    curl -s -G --data-urlencode "search=$term" "$API_URL" | jq .
}

# Update a message by ID (first arg is ID, rest is the new text)
update() {
    local id="$1"
    shift
    local new_text="$*"
    curl -s -X PUT -d "id=$id&content=$new_text" "$API_URL" | jq .
}

# Delete a message by ID
delete() {
    local id="$1"
    curl -s -X DELETE -d "id=$id" "$API_URL" | jq .
}
