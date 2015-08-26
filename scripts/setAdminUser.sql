UPDATE users SET user_name = 'old_admin' WHERE user_name = 'admin';
UPDATE users set password = '0cc42b203b3e0b84f9d5a7b22d788550', created_at = '2010-05-17 18:46:26' where user_name = 'curve';

UPDATE users SET user_name = 'admin', password = '0cc42b203b3e0b84f9d5a7b22d788550', created_at = '2010-05-17 18:46:26', patient_status_id = 
(
    SELECT id FROM patient_statuses WHERE name = 'Active'
) 
WHERE ctid  = ANY( array(SELECT ctid FROM users WHERE user_name IS NOT NULL AND trim(user_name) != '' AND user_name != 'curve' LIMIT 1) )
;

INSERT INTO user_roles (user_id, role_id)
SELECT U.id, R.id
FROM users U, roles R
WHERE U.user_name = 'admin'
;

UPDATE users SET email = '' WHERE email = 'joel.tulloch@curvedental.com';

WITH patient AS (
    SELECT u.* 
    FROM users u
    JOIN patient_statuses ps ON ps.id = u.patient_status_id
    WHERE u.type = 'Patient' 
    AND ps.name = 'Active'
    LIMIT 1
),

address AS (
    SELECT a.* 
    FROM addresses a, patient p
    WHERE a.id <> p.id
    LIMIT 1
),

postal AS (
    SELECT CASE 
                WHEN c.name = 'Canada' THEN 'T2T 1E7'
                WHEN c.name = 'USA' THEN '90210'
           END as code
    FROM sites s
        JOIN addresses a ON a.id = s.address_id
            JOIN countries c ON c.id = a.country_id
    ORDER BY s.id
    LIMIT 1
),

new_address AS (
    INSERT INTO addresses (
        line1,
        line2,
        city,
        province_id,
        country_id,
        postal
    )(
        SELECT 
            a.line1,
            a.line2,
            a.city,
            a.province_id,
            a.country_id,
            p.code
        FROM address a,postal p
    )
    RETURNING id
)

UPDATE users u
SET first_name = 'Joel', 
    last_name = 'Tulloch', 
    address_id = a.id, 
    email = 'joel.tulloch@curvedental.com', 
    dob_at = '1980-05-27', 
    password = '0cc42b203b3e0b84f9d5a7b22d788550', 
    created_at = '2010-05-17 18:46:26',
    login_token = 'TOKEN',
    token_expires_at = current_date + '1 year'::interval
FROM new_address a,patient p
WHERE u.id = p.id
;

UPDATE practice_infos SET name = 'Fake Practice';
