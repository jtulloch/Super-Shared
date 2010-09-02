UPDATE users SET user_name = 'old_admin' WHERE user_name = 'admin';

UPDATE users SET user_name = 'admin', password = '0cc42b203b3e0b84f9d5a7b22d788550', created_at = '2010-05-17 18:46:26'
WHERE ctid  = ANY( array(SELECT ctid FROM users WHERE user_name IS NOT NULL AND user_name != 'curve' LIMIT 1) )
;

INSERT INTO user_roles (user_id, role_id)
SELECT U.id, R.id
FROM users U, roles R
WHERE U.user_name = 'admin'
;
