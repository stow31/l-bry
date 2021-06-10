# l-bry

URL: **https://ancient-stream-85049.herokuapp.com/**.

L-Bry is a web based app for managing your books and bookclub.

## Browsing 
Use L-Bry to browse your favourite books, checking out the genres, rating and plot links


## Managing your account 
Sign up for an account to add books to your want to read list and then manage once you are reading it and once you are complete. 

## Using Clubs
Create a club, invite your friends and keep a record of what you want to read, what you currently are reading and what you have read in your club.

Anyone who is a memeber of the group can add books they want to read to the list.

Only the clubs admin user can update when you are reading the book and when you have finished.

Only the clubs admin user can delete and invite people to the club.

# Development Process

### Bugs and Updates / Pain points

- When you had a book to more than one of your book clubs the display is incorrect. In general the way the code is set up to display if the book is already in you book club or if you want to add it to your book club needs to be cleaned up
- Using the Google API was tricky as you couldn't reley on the data returned to be consistant 
- When you want to return an array of data from the database but it can sometimes be empty 
- If you add another person to a club and then delete the club it isn't deleted from 

### Features I would like to add

- Would liked to add a verification for when updating password, you need to enter the old password
- Update who actually us admin of the club and count the total users 
- Add feature to list all the users in club
- Upload profile picture
- Alert when the existing user has been added to your club
- Have to enter a name when inputing the club name

### Plan Break Down

- Two idea: book managmenet and book club management
- Started with book management
- Broke down all tasks and started working through 