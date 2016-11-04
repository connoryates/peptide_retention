CREATE DATABASE IF NOT EXISTS yeast;
CREATE TABLE IF NOT EXISTS uniprot_yeast (
    id SERIAL PRIMARY KEY,
    peptide TEXT UNIQUE,
    bullbreese REAL,
    hodges_prediction REAL,
    length INT
);
