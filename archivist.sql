CREATE DATABASE IF NOT EXISTS archivist;
USE archivist;

CREATE TABLE IF NOT EXISTS histories (
    ID INT,
    Command VARCHAR(3000) NOT NULL,
    Category VARCHAR(255) NOT NULL,
    PRIMARY KEY (ID)
)