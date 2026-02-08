CREATE TABLE IF NOT EXISTS patient (
    id UUID PRIMARY KEY,
    name VARCHAR(255) NOT NULL,
    date_of_birth DATE NOT NULL,
    email VARCHAR(255) NOT NULL
);
