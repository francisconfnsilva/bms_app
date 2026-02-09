INSERT INTO Country (name, flag, ISO_code) VALUES
('Portugal', 'https://upload.wikimedia.org/wikipedia/commons/a/a8/Flag_of_Portugal_%28official%29.svg', 'PRT'),
('Spain', 'https://upload.wikimedia.org/wikipedia/commons/9/9a/Flag_of_Spain.svg', 'ESP'),
('France', 'https://upload.wikimedia.org/wikipedia/commons/c/c3/Flag_of_France.svg', 'FRA');

INSERT INTO Location (name, latitude, longitude, defined_ISO) VALUES
('Faro Marina', 37.0194, -7.9304, 'PRT'),
('Lisbon Port', 38.7223, -9.1393, 'PRT'),
('Cadiz Harbor', 36.5271, -6.2886, 'ESP'),
('Barcelona Port', 41.3851, 2.1734, 'ESP'),
('Marseille Marina', 43.2965, 5.3698, 'FRA');

INSERT INTO Class (number, maximum_length) VALUES
(1, 10.0),
(2, 15.0),
(3, 20.0),
(4, 30.0);

INSERT INTO Sailor (email, first_name, surname) VALUES
('john.santos@mail.com', 'John', 'Santos'),
('mary.smith@mail.com', 'Mary', 'Smith'),
('peter.brown@mail.com', 'Peter', 'Brown'),
('ana.santos@mail.com', 'Ana', 'Santos'),
('luis.indio@mail.com', 'Luis', 'Indio'),
('carol.jones@mail.com', 'Carol', 'Jones');

INSERT INTO Senior (email) VALUES
('john.santos@mail.com'),
('mary.smith@mail.com'),
('ana.santos@mail.com');

INSERT INTO Junior (email) VALUES
('peter.brown@mail.com'),
('luis.indio@mail.com'),
('carol.jones@mail.com');

INSERT INTO Jurisdiction (name, type) VALUES
('Portuguese Internal Waters', 'Internal Waters'),
('Portuguese Territorial Sea', 'Territorial Sea'),
('Portuguese EEZ', 'Exclusive Economic Zone'),
('Spanish Internal Waters', 'Internal Waters'),
('Spanish Territorial Sea', 'Territorial Sea'),
('Spanish EEZ', 'Exclusive Economic Zone'),
('International Waters Atlantic', 'International Waters'),
('French Territorial Sea', 'Territorial Sea');

INSERT INTO comprise (name, type, ISO_code) VALUES
('Portuguese Internal Waters', 'Internal Waters', 'PRT'),
('Portuguese Territorial Sea', 'Territorial Sea', 'PRT'),
('Portuguese EEZ', 'Exclusive Economic Zone', 'PRT'),
('Spanish Internal Waters', 'Internal Waters', 'ESP'),
('Spanish Territorial Sea', 'Territorial Sea', 'ESP'),
('Spanish EEZ', 'Exclusive Economic Zone', 'ESP'),
('French Territorial Sea', 'Territorial Sea', 'FRA');

INSERT INTO Boat (cni, name, length, registration_year, picture, ISO_code, belongs_max) VALUES
('PT-5521-AB', 'Albatross', 9.5, 2020, 'https://powerboat.world/photos/powerboat/yysw309608.jpg', 'PRT', 10.0),
('PT-4539-KL', 'Sea Breeze', 14.0, 2021, 'https://www.barcheamotore.com/wp-content/uploads/2021/09/Cranchi-A46-Luxury-Tender-1024x569.jpg', 'PRT', 15.0),
('BA-3-442-21', 'Ocean Dream', 18.5, 2019, 'https://www.barcheamotore.com/wp-content/uploads/2023/03/tfile_big_11-1024x527.jpg', 'ESP', 20.0),
('PM-4-220-20', 'Mariposa', 12.0, 2022, 'https://www.barcheamotore.com/wp-content/uploads/2022/05/Scanner-1200-Envy-fuoribordo-.jpg', 'ESP', 15.0),
('ST 552301', 'Belle Mer', 25.0, 2018, 'https://photos.superyachtapi.com/download/101796/large', 'FRA', 30.0);

INSERT INTO Reservation (start_date, end_date, id_reserv) VALUES
('2024-06-01', '2024-06-10', 1),
('2024-07-15', '2024-07-25', 2),
('2024-08-01', '2024-08-15', 3),
('2024-09-01', '2024-09-02', 4);

INSERT INTO associates (id_reserv, cni, ISO_code, responsible_email) VALUES
(1, 'PT-5521-AB', 'PRT', 'john.santos@mail.com'),
(2, 'PT-4539-KL', 'PRT', 'mary.smith@mail.com'),
(3, 'BA-3-442-21', 'ESP', 'ana.santos@mail.com'),
(4, 'ST 552301', 'FRA', 'john.santos@mail.com');

INSERT INTO authorized (id_reserv, cni, ISO_code, email) VALUES
-- Reservation 1 (PT-5521-AB - Albatross)
(1, 'PT-5521-AB', 'PRT', 'john.santos@mail.com'),
(1, 'PT-5521-AB', 'PRT', 'peter.brown@mail.com'),
(1, 'PT-5521-AB', 'PRT', 'luis.indio@mail.com'),
-- Reservation 2 (PT-4539-KL - Sea Breeze)
(2, 'PT-4539-KL', 'PRT', 'mary.smith@mail.com'),
(2, 'PT-4539-KL', 'PRT', 'peter.brown@mail.com'),
-- Reservation 3 (BA-3-442-21 - Ocean Dream)
(3, 'BA-3-442-21', 'ESP', 'ana.santos@mail.com'),
(3, 'BA-3-442-21', 'ESP', 'peter.brown@mail.com'),
-- Reservation 4 (ST 552301 - Belle Mer)
(4, 'ST 552301', 'FRA', 'john.santos@mail.com');

INSERT INTO Certifications (email, issue_date, expiry_date, validates_max) VALUES
('john.santos@mail.com', '2023-01-15', '2026-01-15', 10.0),
('mary.smith@mail.com', '2023-03-20', '2026-03-20', 15.0),
('ana.santos@mail.com', '2023-05-10', '2026-05-10', 20.0),
('peter.brown@mail.com', '2023-06-01', '2026-06-01', 10.0);

INSERT INTO valid_in (email, issue_date, ISO_code) VALUES
('john.santos@mail.com', '2023-01-15', 'PRT'),
('john.santos@mail.com', '2023-01-15', 'ESP'),
('mary.smith@mail.com', '2023-03-20', 'PRT'),
('ana.santos@mail.com', '2023-05-10', 'ESP'),
('peter.brown@mail.com', '2023-06-01', 'PRT');

INSERT INTO Trip (tod, ad, id_reserv, cni, ISO_code, insurance_ref, starts_name, ends_name, skippers_email) VALUES
-- Trip 1: PT-5521-AB (Albatross) - John Santos as skipper (has proper cert for Class 1)
('2024-06-02', '2024-06-05', 1, 'PT-5521-AB', 'PRT', 'INS-2024-001', 'Faro Marina', 'Lisbon Port', 'john.santos@mail.com'),
-- Trip 2: PT-4539-KL (Sea Breeze) - Peter Brown as skipper (NO cert for Class 2 - Query D!)
('2024-07-16', '2024-07-20', 2, 'PT-4539-KL', 'PRT', 'INS-2024-002', 'Lisbon Port', 'Faro Marina', 'peter.brown@mail.com'),
-- Trip 3: BA-3-442-21 (Ocean Dream) - Ana Santos as skipper (has proper cert for Class 3)
('2024-08-02', '2024-08-08', 3, 'BA-3-442-21', 'ESP', 'INS-2024-003', 'Cadiz Harbor', 'Barcelona Port', 'ana.santos@mail.com');

INSERT INTO crosses (id_reserv, cni, ISO_code, tod, name, type, c_order) VALUES
-- Trip 1: Faro to Lisbon (within Portugal)
(1, 'PT-5521-AB', 'PRT', '2024-06-02', 'Portuguese Internal Waters', 'Internal Waters', 1),
(1, 'PT-5521-AB', 'PRT', '2024-06-02', 'Portuguese Territorial Sea', 'Territorial Sea', 2),
-- Trip 2: Lisbon to Faro (within Portugal)
(2, 'PT-4539-KL', 'PRT', '2024-07-16', 'Portuguese Territorial Sea', 'Territorial Sea', 1),
(2, 'PT-4539-KL', 'PRT', '2024-07-16', 'Portuguese Internal Waters', 'Internal Waters', 2),
-- Trip 3: Cadiz to Barcelona (Spain)
(3, 'BA-3-442-21', 'ESP', '2024-08-02', 'Spanish Internal Waters', 'Internal Waters', 1),
(3, 'BA-3-442-21', 'ESP', '2024-08-02', 'Spanish Territorial Sea', 'Territorial Sea', 2),
(3, 'BA-3-442-21', 'ESP', '2024-08-02', 'Spanish EEZ', 'Exclusive Economic Zone', 3);