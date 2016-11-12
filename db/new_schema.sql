CREATE DATABASE peptide_retention;

CREATE TABLE IF NOT EXISTS peptides(
    id BIGSERIAL PRIMARY KEY,
    sequence TEXT NOT NULL UNIQUE,
    molecular_weight REAL,
    bullbreese REAL,
    real_retention_time REAL,
    length INT,
    cleavage VARCHAR(255)
);

CREATE TABLE IF NOT EXISTS predictions(
    id BIGSERIAL PRIMARY KEY,
    algorithm VARCHAR(255) NOT NULL,
    predicted_time REAL,
    peptide_id BIGSERIAL
);

ALTER TABLE predictions ADD FOREIGN KEY(peptide_id) REFERENCES peptides(id);

CREATE TABLE IF NOT EXISTS proteins(
    id BIGSERIAL PRIMARY KEY,
    peptide_id BIGSERIAL,
    sequence_id BIGSERIAL
);

ALTER TABLE proteins ADD FOREIGN KEY(peptide_id) REFERENCES peptides(id);
ALTER TABLE proteins ADD FOREIGN KEY(sequence_id) REFERENCES protein_sequences(id);

CREATE TABLE IF NOT EXISTS protein_sequences(
    id BIGSERIAL PRIMARY KEY,
    sequence TEXT NOT NULL,
    primary_id VARCHAR(255) UNIQUE NOT NULL
);

ALTER TABLE protein_sequences ADD FOREIGN KEY(primary_id) REFERENCES protein_descriptions(primary_id);

CREATE TABLE IF NOT EXISTS protein_descriptions(
    id BIGSERIAL PRIMARY KEY,
    primary_id VARCHAR(255) UNIQUE NOT NULL,
    description TEXT
);

