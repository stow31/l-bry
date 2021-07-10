def books_in_club(club_id, status)
    sql = "SELECT * FROM books_clubs WHERE club_id = $1 AND book_status = $2;"

    run_sql(sql, [club_id, status])
end

def books_in_clubs(user_id, book_id)
    sql = "SELECT * FROM clubs_users JOIN clubs ON clubs_users.club_id = clubs.id JOIN books_clubs ON clubs_users.club_id = books_clubs.club_id WHERE clubs_users.user_id = $1 and books_clubs.book_id = $2;"
    club_book_records = run_sql(sql, [user_id, book_id]);
end