CREATE DATABASE peptide_retention;

CREATE TABLE IF NOT EXISTS peptides(
    id BIGSERIAL PRIMARY KEY,
    sequence TEXT NOT NULL UNIQUE,
    molecular_weight REAL,
    bullbreese REAL,
    real_retention_time REAL,
    length INT,
    cleavage VARCHAR(255),
    average_mass NUMERIC,
    monoisotopic_mass NUMERIC
);

CREATE TABLE IF NOT EXISTS predictions(
    id BIGSERIAL PRIMARY KEY,
    algorithm VARCHAR(255) NOT NULL,
    predicted_time REAL,
    peptide_id BIGSERIAL
);

CREATE TABLE IF NOT EXISTS proteins(
    id BIGSERIAL PRIMARY KEY,
    peptide_id BIGSERIAL,
    sequence_id BIGSERIAL
);

CREATE TABLE IF NOT EXISTS protein_sequences(
    id BIGSERIAL PRIMARY KEY,
    sequence TEXT NOT NULL,
    primary_id VARCHAR(255) UNIQUE NOT NULL,
    average_mass NUMERIC,
    monoisotopic_mass NUMERIC
);

CREATE TABLE IF NOT EXISTS protein_descriptions(
    id BIGSERIAL PRIMARY KEY,
    primary_id VARCHAR(255) UNIQUE NOT NULL,
    description TEXT
);

