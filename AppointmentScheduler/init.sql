CREATE TABLE IF NOT EXISTS patient (
    id UUID PRIMARY KEY,
    name VARCHAR(255) NOT NULL,
    date_of_birth DATE NOT NULL,
    email VARCHAR(255) NOT NULL
);

CREATE TABLE IF NOT EXISTS appointment (
    id UUID PRIMARY KEY,
    patient_id UUID NOT NULL REFERENCES patient(id),
    date TIMESTAMP NOT NULL,
    type VARCHAR(255) NOT NULL
);


CREATE TABLE IF NOT EXISTS tasks (
    id UUID PRIMARY KEY,
    appointment_id UUID NOT NULL REFERENCES appointment(id),
    status VARCHAR(255) NOT NULL,
    priority VARCHAR(255) NOT NULL
);

CREATE OR REPLACE FUNCTION create_task_for_appointment()
RETURNS TRIGGER AS $$
BEGIN
    INSERT INTO tasks (id, appointment_id, status, priority)
    VALUES (gen_random_uuid(), NEW.id, 'pending', 'normal');
    RETURN NEW;
END;
$$ LANGUAGE plpgsql;

CREATE OR REPLACE TRIGGER trg_appointment_create_task
AFTER INSERT ON appointment
FOR EACH ROW
EXECUTE FUNCTION create_task_for_appointment();
