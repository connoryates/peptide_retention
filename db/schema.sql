CREATE DATABASE IF NOT EXISTS yeast;
CREATE TABLE IF NOT EXISTS uniprot_yeast (
    id SERIAL PRIMARY KEY,
    peptide VARCHAR(1000),
    bullbreese REAL,
    retention REAL,
    length INT
);
