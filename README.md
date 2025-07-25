# Online-Note

Project Structure
graphql
Copy
Edit
my-cli-notes/
│
├── api.php         # Your PHP backend for CRUD
├── ielts.sh        # Your Bash script with aliases (instructions for setup)
└── README.md       # Documentation (goal, setup, usage)
README.md Example
Here’s a full README.md you can use:

markdown
Copy
Edit
# CLI Notes Tool

This project lets you **send, search, update, and delete messages** from the command line, storing them on a **remote server (Hostinger)** with a **PHP + MySQL API**.

You can type commands like:

```bash
send Hello world
get Hello
update 3 Updated message here
delete 4
All messages are stored in your MySQL database via api.php.

Files
api.php
PHP API that handles CRUD operations (send, get, update, delete).

ielts.sh
Bash script (contains alias functions) so you can use the commands directly in your terminal.

Setup Instructions
1. Host the PHP API
Upload api.php to your hosting server (e.g., Hostinger).

Create the messages table in your MySQL database:

sql
Copy
Edit
CREATE TABLE IF NOT EXISTS messages (
    id INT AUTO_INCREMENT PRIMARY KEY,
    content TEXT NOT NULL,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);
Edit api.php and set the correct MySQL host, user, password, and database name.

2. Configure the CLI Aliases
Open your ~/.bashrc:

bash
Copy
Edit
nano ~/.bashrc
Paste the contents of ielts.sh into your ~/.bashrc (or source it).

Reload your shell:

bash
Copy
Edit
source ~/.bashrc
Install jq for pretty-printing JSON:

bash
Copy
Edit
sudo apt install jq -y
Usage Examples
bash
Copy
Edit
send Hello world this is a test
get Hello
update 1 This is a new text for ID 1
delete 1
Goal of the Project
This tool allows you to:

Store text notes from your terminal directly to a remote MySQL database.

Search, update, and delete notes quickly.

Avoid manually crafting curl requests — just use simple commands.

