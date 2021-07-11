# l-bry

URL: **https://ancient-stream-85049.herokuapp.com/**.

L-Bry is a web based app for managing your books and bookclub using Google Books API.

Created using Ruby, CSS, Sinatra, HTTParty, PG and BCyrpt.

![alt text](https://github.com/stow31/l-bry/blob/main/screenshots/lbry-homepage.png)

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

- When you had a book to more than one of your book clubs the display is incorrect. In general the way the code is set up to display if the book is already in you book club or if you want to add it to your book club needs to be cleaned up / redone.
- Using the Google API was tricky as you couldn't reley on the data returned to be consistant.
- Accounting for when you want to return an array of data from the database but it can sometimes be empty.
- If you add another person to a club and then delete the club it isn't deleted from.

### Features I would like to add

- Would liked to add a verification for when updating password, you need to enter the old password
- Update who actually is admin of the club and count the total users in each club.
- Add feature to list all the users in club.
- Upload profile picture.
- Alert when the existing user has been added to your club or if the user you are trying to add doesn't exist.
- When setting up a club make it require a name.
- Cross check between if a book as been read in book club add it to your personal read list.

### Plan Break Down

- Two idea: book managmenet and book club management
- Started with book management.
- Created rough wireframes and then broke that into a list of smaller tasks that I slowly worked through.
- Once the MVP was competed started to attempt the book club management feature which I followed the above process.
- The book club feature was harder than anticipated and I plan to further investigate over the coming weeks.