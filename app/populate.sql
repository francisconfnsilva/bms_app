-- START THE TRANSACTION FOR DATA ENTRY
START TRANSACTION;
SET CONSTRAINTS ALL DEFERRED;
-- 1. COUNTRIES
INSERT INTO country (name, flag, iso_code) VALUES
('Portugal', 'https://upload.wikimedia.org/wikipedia/commons/a/a8/Flag_of_Portugal_%28official%29.svg', 'PRT'),
('Spain', 'https://upload.wikimedia.org/wikipedia/commons/9/9a/Flag_of_Spain.svg', 'ESP'),
('France', 'https://upload.wikimedia.org/wikipedia/commons/c/c3/Flag_of_France.svg', 'FRA');

-- 2. LOCATIONS
INSERT INTO location (name, latitude, longitude, country_name) VALUES
('Faro Marina', 37.0194, -7.9304, 'Portugal'),
('Lisbon Port', 38.7223, -9.1393, 'Portugal'),
('Cadiz Harbor', 36.5271, -6.2886, 'Spain'),
('Barcelona Port', 41.3851, 2.1734, 'Spain'),
('Marseille Marina', 43.2965, 5.3698, 'France');

-- 3. SAILORS
INSERT INTO sailor (email, firstname, surname) VALUES
('john.santos@mail.com', 'John', 'Santos'),
('mary.smith@mail.com', 'Mary', 'Smith'),
('peter.brown@mail.com', 'Peter', 'Brown'),
('ana.santos@mail.com', 'Ana', 'Santos'),
('luis.indio@mail.com', 'Luis', 'Indio'),
('carol.jones@mail.com', 'Carol', 'Jones');

INSERT INTO senior (email) VALUES
('john.santos@mail.com'),
('mary.smith@mail.com'),
('ana.santos@mail.com');

INSERT INTO junior (email) VALUES
('peter.brown@mail.com'),
('luis.indio@mail.com'),
('carol.jones@mail.com');

-- 4. CLASSES
INSERT INTO boat_class (name, max_length) VALUES
('Class 1', 10.0),
('Class 2', 15.0),
('Class 3', 20.0),
('Class 4', 30.0);

-- 5. CERTIFICATES
INSERT INTO sailing_certificate (sailor, issue_date, expiry_date, boat_class) VALUES
('john.santos@mail.com', '2023-01-15 00:00:00', '2026-01-15 00:00:00', 'Class 1'),
('john.santos@mail.com', '2020-01-01 00:00:00', '2023-01-01 00:00:00', 'Class 2'), -- Extra Cert
('mary.smith@mail.com', '2023-03-20 00:00:00', '2026-03-20 00:00:00', 'Class 2'),
('ana.santos@mail.com', '2023-05-10 00:00:00', '2026-05-10 00:00:00', 'Class 3'),
('peter.brown@mail.com', '2023-06-01 00:00:00', '2026-06-01 00:00:00', 'Class 1');

INSERT INTO valid_for (country_name, max_length, sailor, issue_date) VALUES
('Portugal', 10.0, 'john.santos@mail.com', '2023-01-15 00:00:00'),
('Spain', 10.0, 'john.santos@mail.com', '2023-01-15 00:00:00'),
('Portugal', 15.0, 'john.santos@mail.com', '2020-01-01 00:00:00'), -- Extra Valid_For
('Portugal', 15.0, 'mary.smith@mail.com', '2023-03-20 00:00:00'),
('Spain', 20.0, 'ana.santos@mail.com', '2023-05-10 00:00:00'),
('Portugal', 10.0, 'peter.brown@mail.com', '2023-06-01 00:00:00');

-- 6. BOATS
INSERT INTO boat (cni, name, length, year, country, boat_class) VALUES
('PT-5521-AB', 'Albatross', 9.5, 2020, 'Portugal', 'Class 1'),
('PT-4539-KL', 'Sea Breeze', 14.0, 2021, 'Portugal', 'Class 2'),
('BA-3-442-21', 'Ocean Dream', 18.5, 2019, 'Spain', 'Class 3'),
('PM-4-220-20', 'Mariposa', 12.0, 2022, 'Spain', 'Class 2'),
('ST 552301', 'Belle Mer', 25.0, 2018, 'France', 'Class 4');

-- 7. INTERVALS & RESERVATIONS
INSERT INTO date_interval (start_date, end_date) VALUES
('2024-06-01', '2024-06-10'),
('2024-07-15', '2024-07-25'),
('2024-08-01', '2024-08-15'),
('2024-09-01', '2024-09-02');

INSERT INTO reservation (start_date, end_date, country, cni, responsible) VALUES
('2024-06-01', '2024-06-10', 'Portugal', 'PT-5521-AB', 'john.santos@mail.com'),
('2024-07-15', '2024-07-25', 'Portugal', 'PT-4539-KL', 'mary.smith@mail.com'),
('2024-08-01', '2024-08-15', 'Spain', 'BA-3-442-21', 'ana.santos@mail.com'),
('2024-09-01', '2024-09-02', 'France', 'ST 552301', 'john.santos@mail.com');

INSERT INTO authorised (start_date, end_date, boat_country, cni, sailor) VALUES
('2024-06-01', '2024-06-10', 'Portugal', 'PT-5521-AB', 'john.santos@mail.com'),
('2024-06-01', '2024-06-10', 'Portugal', 'PT-5521-AB', 'peter.brown@mail.com'),
('2024-06-01', '2024-06-10', 'Portugal', 'PT-5521-AB', 'luis.indio@mail.com'),
('2024-07-15', '2024-07-25', 'Portugal', 'PT-4539-KL', 'mary.smith@mail.com'),
('2024-07-15', '2024-07-25', 'Portugal', 'PT-4539-KL', 'peter.brown@mail.com'),
('2024-08-01', '2024-08-15', 'Spain', 'BA-3-442-21', 'ana.santos@mail.com'),
('2024-08-01', '2024-08-15', 'Spain', 'BA-3-442-21', 'peter.brown@mail.com'),
('2024-09-01', '2024-09-02', 'France', 'ST 552301', 'john.santos@mail.com');

-- 8. TRIPS
INSERT INTO trip (takeoff, arrival, insurance, from_latitude, from_longitude, to_latitude, to_longitude, skipper, reservation_start_date, reservation_end_date, boat_country, cni) VALUES
('2024-06-02', '2024-06-05', 'INS-2024-001', 37.0194, -7.9304, 38.7223, -9.1393, 'john.santos@mail.com', '2024-06-01', '2024-06-10', 'Portugal', 'PT-5521-AB'),
('2024-06-07', '2024-06-09', 'INS-EXTRA-001', 38.7223, -9.1393, 37.0194, -7.9304, 'john.santos@mail.com', '2024-06-01', '2024-06-10', 'Portugal', 'PT-5521-AB'), -- Extra Trip
('2024-07-16', '2024-07-20', 'INS-2024-002', 38.7223, -9.1393, 37.0194, -7.9304, 'peter.brown@mail.com', '2024-07-15', '2024-07-25', 'Portugal', 'PT-4539-KL'),
('2024-08-02', '2024-08-08', 'INS-2024-003', 36.5271, -6.2886, 41.3851, 2.1734, 'ana.santos@mail.com', '2024-08-01', '2024-08-15', 'Spain', 'BA-3-442-21');

-- COMMIT THE TRANSACTION
COMMIT;