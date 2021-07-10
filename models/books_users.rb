def get_users_book_list(user_id, book_id)
    sql = "SELECT * FROM books_users WHERE user_id = $1 AND book_id = $2;"
    records = run_sql(sql, [user_id, book_id])
end