def get_club_list(user_id)
    sql = "SELECT * FROM clubs_users JOIN clubs ON clubs_users.club_id = clubs.id WHERE clubs_users.user_id = $1;"
    run_sql(sql, [user_id])
end

def delete_club_from_all_users(club_id)
    sql = "DELETE FROM clubs_users WHERE club_id = $1;";
    run_sql(sql, [club_id])
end

def assign_user_to_club(user_id, club_id)
    sql = "INSERT INTO clubs_users(user_id, club_id) VALUES ($1, $2);"
    run_sql(sql, [user_id, club_id])
end