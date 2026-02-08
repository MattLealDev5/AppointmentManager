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
