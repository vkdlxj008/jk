-- Create a new database
CREATE DATABASE insurance_analysis;

-- Select a database
USE insurance_analysis;

-- Table generator (see insurance data header)
CREATE TABLE insurance_data (
    id INT AUTO_INCREMENT PRIMARY KEY,
    age INT,
    sex VARCHAR(10),
    bmi DECIMAL(5,2),
    children INT,
    smoker VARCHAR(5),
    region VARCHAR(20),
    charges DECIMAL(10,2)
);
