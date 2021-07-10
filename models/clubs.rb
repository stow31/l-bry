def create_club(club_name, user_id)
    sql = "INSERT INTO clubs(club_name, admin_user_id) VALUES ($1, $2);"
    run_sql(sql, [club_name, user_id])
end

def get_club_details_with_name(club_name)
    sql = "SELECT * FROM clubs WHERE club_name = $1;"
    run_sql(sql, [club_name])
end

def get_club_details_with_id(club_id)
    sql = "SELECT * FROM clubs where id = #{club_id}"
    run_sql(sql)[0]
end

def delete_club(club_id)
    sql = "DELETE FROM clubs WHERE id = $1;";
    run_sql(sql, [club_id])
end