# Online-Note

Objective: From your bash/zsh terminal send, get, update, or delete or 1 line message from internet api server
In your hosting make new site:
Make new database
select database and write this query:
```
CREATE TABLE IF NOT EXISTS messages (
    id INT AUTO_INCREMENT PRIMARY KEY,
    content TEXT NOT NULL,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);
```
and paste this api.php code add credential for database for password, db_name, and user_name and save file
Online Setup Completed test your_website_url/api.php working or not if it returns empty array it is working fine

For offline command line setup with aliases:
```
nano ~/.zshrc
```
*or based on your terminal
```
nano ~/.bashrc
```
paste code at the bottom and save it
Offline setup completed
test it get 
```
send Hello World
```
it will return success response 
you can get it will return all message with have that word like
```
❯ get Hello
[
  {
    "id": 5,
    "content": "Hello World",
    "created_at": "2025-07-25 14:51:37"
  }
]
```
for update paste id of it
```
update 5 "What a Sunny day"
```
for delete 
```
delete 5
```

### Additional changes
```
get # return latest 5 message
get -8 # return latest 8 message respect to flag
get -a # return all message
getl # return latest message and copied message to clipboard automatically
copy 22 # it copies content of message 22 data
``` 
Finish
