CREATE EXTENSION IF NOT EXISTS pg_cron;

DROP TABLE  IF EXISTS users;
DROP TABLE  IF EXISTS users_audit;


CREATE TABLE users (
    id SERIAL PRIMARY KEY,
    name TEXT,
    email TEXT,
    role TEXT,
    updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

CREATE TABLE users_audit (
    id SERIAL PRIMARY KEY,
    user_id INTEGER,
    changed_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    changed_by TEXT,
    field_changed TEXT,
    old_value TEXT,
    new_value TEXT
);


CREATE OR REPLACE FUNCTION log_user_audit()
RETURNS TRIGGER AS $$
BEGIN
IF TG_OP = 'UPDATE' THEN
    IF OLD.name IS DISTINCT FROM NEW.name THEN
        INSERT INTO users_audit(user_id, changed_by, field_changed,old_value,new_value) 
        VALUES (OLD.id,session_user,'name', OLD.name, NEW.name); 
    END IF;
    IF OLD.email IS DISTINCT FROM NEW.email THEN
        INSERT INTO users_audit(user_id, changed_by, field_changed,old_value,new_value) 
        VALUES (OLD.id,session_user,'email', OLD.email, NEW.email); 
    END IF;
	IF OLD.role IS DISTINCT FROM NEW.role THEN
        INSERT INTO users_audit(user_id, changed_by, field_changed,old_value,new_value) 
        VALUES (OLD.id,session_user,'role', OLD.role, NEW.role); 
    END IF;
	NEW.updated_at := NOW();
END IF;
    RETURN NEW;
END;
$$ LANGUAGE plpgsql;

DROP TRIGGER IF EXISTS trigger_log_user_audit ON users;
CREATE TRIGGER trigger_log_user_audit
BEFORE UPDATE OF name,email,role ON users
FOR EACH ROW
EXECUTE FUNCTION log_user_audit();


INSERT INTO users (name, email,role)
VALUES 
('Ivan Ivanov', 'ivan@example.com','DE'),
('Alex Borovikov', 'alex@example.com','AD'),
('Anna Petrova', 'anna@example.com','DS');

select * FROM users;

UPDATE users
SET name = 'Ilia Ivanov'
WHERE id = 1;


UPDATE users
SET email = 'ilia@example.com',
role = 'chief'
WHERE id = 1;

UPDATE users
SET role = NULL
WHERE id = 2;

select * FROM users_audit;




