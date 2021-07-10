CREATE TABLE user_details(
    id SERIAL PRIMARY KEY,
    email TEXT,
    password TEXT,
    projects JSONB
);

INSERT INTO user_details (email, password, projects) VALUES ('sophie.townsend@mail.com', 'pudding', '[
    {"name": "tic tac toe", "url": "www.stow9770.com/tictactoe", "description": "this is a description of my tic tac toe game"},
    {"name": "lbry", "url": "www.stow9770.com/libry", "description": "this is a description of my book management"}
]');

-- returns all the arrays with position numbers
SELECT arr.position,arr.item_object
FROM user_details, jsonb_array_elements(projects) with ordinality arr(item_object, position)                                                  WHERE id=1;

-- 
SELECT arr.position,arr.item_object
FROM user_details, jsonb_array_elements(projects) with ordinality arr(item_object, position)
WHERE id=1 and arr.position=Cast((select arr.position  FROM user_details, jsonb_array_elements(projects) with ordinality arr(item_object, position)
WHERE id=1 and arr.item_object->>'name' = 'tic tac toe') as int);