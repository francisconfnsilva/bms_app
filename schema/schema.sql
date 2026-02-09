DROP TABLE IF EXISTS crosses;
DROP TABLE IF EXISTS valid_in;
DROP TABLE IF EXISTS Trip;
DROP TABLE IF EXISTS authorized;
DROP TABLE IF EXISTS associates;
DROP TABLE IF EXISTS Certifications;
DROP TABLE IF EXISTS Junior;
DROP TABLE IF EXISTS Senior;
DROP TABLE IF EXISTS Boat;
DROP TABLE IF EXISTS comprise;
DROP TABLE IF EXISTS Sailor;
DROP TABLE IF EXISTS Reservation;
DROP TABLE IF EXISTS Jurisdiction;
DROP TABLE IF EXISTS Location;
DROP TABLE IF EXISTS Class;
DROP TABLE IF EXISTS Country;



CREATE TABLE Country(
    name VARCHAR(70) NOT NULL,
    flag VARCHAR(200) NOT NULL,
    ISO_code CHAR(3),
    UNIQUE(name),--IC-8
    UNIQUE(flag), --IC-9
    PRIMARY KEY (ISO_code)
    -- Every Country must be defined by at least one Location
    -- Every Country must exist in the table "comprise"
    -- IC-5: A Country can only register a Boat if it has at least one Location defined.
);

CREATE TABLE Location (
    name VARCHAR(30),
    latitude NUMERIC(8,6) NOT NULL,
    longitude NUMERIC (9,6) NOT NULL,
    defined_ISO VARCHAR(30) NOT NULL,
    PRIMARY KEY (name),
    FOREIGN KEY (defined_ISO) REFERENCES Country(ISO_code)
    -- IC-4: Any two distinct Locations must be at a distance >= to one nautical mile.
    -- IC-5: A Country can only register a Boat if it has at least one Location defined.
);

CREATE TABLE Class (
  number INTEGER NOT NULL,
  maximum_length NUMERIC(4,1),
  PRIMARY KEY (maximum_length)
);

CREATE TABLE Sailor (
    email VARCHAR(254),
    first_name VARCHAR(20) NOT NULL,
    surname VARCHAR (20) NOT NULL,
    PRIMARY KEY (email)
    -- No sailor can exist at the same time in the both the table 'Senior' or in the table 'Junior'.
    -- IC-3: A Sailor can only be the skipper of a Trip if he/she is authorized for the Reservation that includes that Trip.
    -- IC-6: A Sailor can only be the skipper of a Trip if he/she holds a Certification that validates the Class the Boat belongs to.
    -- IC-11 A Sailor can only be the skipper of a Trip that crosses a Jurisdiction comprising a Country if he/she holds a Certification that is valid in that same Country.
);

CREATE TABLE Reservation (
    start_date DATE NOT NULL,
    end_date DATE NOT NULL,
    id_reserv INTEGER,
    PRIMARY KEY (id_reserv),
    CHECK (end_date >= start_date)
    -- Every Reservation must exist in the table "associates".
);

CREATE TABLE Jurisdiction (
    name VARCHAR(100),
    type VARCHAR(40),
    PRIMARY KEY (name, type)
    -- IC-12: A Jurisdiction of type 'International Waters' can never comprise a Country.
);

CREATE TABLE Boat (
    cni VARCHAR(20),
    name VARCHAR(50) NOT NULL,
    length NUMERIC(4,1) NOT NULL,
    registration_year INTEGER NOT NULL,
    picture VARCHAR(200),
    ISO_code CHAR(3),
    belongs_max NUMERIC(4,1) NOT NULL,
    PRIMARY KEY (ISO_code, cni),
    FOREIGN KEY (ISO_code) REFERENCES Country(ISO_code),
    FOREIGN KEY (belongs_max) REFERENCES Class(maximum_length)
    -- IC-1: A Boat must have a length less than or equal to the maximum_length of the Class it belongs to.
    -- IC-5: A Country can only register a Boat if it has at least one Location defined.
);

CREATE TABLE Junior (
    email VARCHAR (254),
    PRIMARY KEY (email),
    FOREIGN KEY (email) REFERENCES Sailor(email)
);

CREATE TABLE Senior (
    email VARCHAR (254),
    PRIMARY KEY (email),
    FOREIGN KEY (email) REFERENCES Sailor(email)
    -- IC-2: A Senior Sailor can only be responsible for a Reservation if he/she is authorized for that same Reservation.
);

CREATE TABLE comprise (
    name VARCHAR(100),
    type VARCHAR(40),
    ISO_code CHAR(3) NOT NULL,
    PRIMARY KEY (name, type),
    FOREIGN KEY (name, type) REFERENCES Jurisdiction(name, type),
    FOREIGN KEY (ISO_code) REFERENCES Country(ISO_code)
    -- IC-12: A Jurisdiction of type 'International Waters' can never comprise a Country.
);

CREATE TABLE Certifications (
    email VARCHAR (254),
    issue_date DATE,
    expiry_date DATE NOT NULL,
    validates_max NUMERIC(4,1),
    PRIMARY KEY (email, issue_date),
    FOREIGN KEY (email) REFERENCES Sailor(email),
    FOREIGN KEY (validates_max) REFERENCES Class(maximum_length)
    -- Every Certification must exist in the table "valid_in".
    -- IC-10: The take-off date (tod) of a Trip must occur between the issue_date and expire_date of the relevant Certification.
);

CREATE TABLE associates (
    id_reserv INTEGER,
    cni VARCHAR(20),
    ISO_code CHAR(3),
    responsible_email VARCHAR(254),
    PRIMARY KEY (id_reserv,cni,ISO_code),
    FOREIGN KEY (id_reserv) REFERENCES Reservation(id_reserv),
    FOREIGN KEY (cni, ISO_code) REFERENCES Boat(cni, ISO_code),
    FOREIGN KEY (responsible_email) REFERENCES Senior(email)
    -- Every associates must exist in the table "authorized".
    -- IC-2: A Senior Sailor can only be responsible for a Reservation if he/she is authorized for that same Reservation.
    -- IC-7: A trip must have a take-off date and arrival date within the start date and end date of the Reservation that includes it.
);

CREATE TABLE authorized (
    id_reserv INTEGER,
    cni VARCHAR(20),
    ISO_code CHAR(3),
    email VARCHAR(254),
    PRIMARY KEY (cni, id_reserv, ISO_code, email),
    FOREIGN KEY (id_reserv, cni, ISO_code) REFERENCES associates(id_reserv, cni, ISO_code),
    FOREIGN KEY (email) REFERENCES Sailor(email)
    -- IC-2: A Senior Sailor can only be responsible for a Reservation if he/she is authorized for that same Reservation (same id_reserv, cni, ISO_code, email).
    -- IC-3: A Sailor can only be the skipper of a Trip if he/she is authorized for the Reservation that includes that Trip.
);

CREATE TABLE Trip (
    tod DATE,
    ad DATE NOT NULL,
    id_reserv INTEGER,
    cni VARCHAR(20),
    ISO_code CHAR(3),
    insurance_ref VARCHAR(100),
    starts_name VARCHAR(30),
    ends_name VARCHAR(30),
    skippers_email VARCHAR(254),
    PRIMARY KEY (id_reserv,cni, ISO_code, tod),
    FOREIGN KEY (id_reserv, cni, ISO_code) REFERENCES associates(id_reserv, cni, ISO_code),
    FOREIGN KEY (starts_name) REFERENCES Location(name),
    FOREIGN KEY (ends_name) REFERENCES Location(name),
    FOREIGN KEY (skippers_email) REFERENCES Sailor(email),
    CHECK (ad >= tod)
    -- Every Trip must exist in the table "crosses"
    -- IC-3 A Sailor can only be the skipper of a Trip if he/she is authorized for the Reservation that includes that Trip.
    -- IC-6: A Sailor can only be the skipper of a Trip if he/she holds a Certification that validates the Class the Boat belongs to.
    -- IC-7 A trip must have a take-off date and arrival date within the start date and end date of the Reservation that includes it.
    -- IC-10 The take-off date (tod) of a Trip must occur between the issue_date and expire_date of the relevant Certification.
    -- IC-11 A Sailor can only be the skipper of a Trip that crosses a Jurisdiction comprising a Country if he/she holds a Certification that is valid in that same Country.
);

CREATE TABLE valid_in (
    email VARCHAR(254),
    issue_date DATE,
    ISO_code CHAR(3),
    PRIMARY KEY (email,issue_date,ISO_code),
    FOREIGN KEY (email,issue_date) REFERENCES Certifications(email,issue_date),
    FOREIGN KEY (ISO_code) REFERENCES Country(ISO_code)
);

CREATE TABLE crosses (
    id_reserv INTEGER,
    cni VARCHAR(20),
    ISO_code CHAR(3),
    tod DATE,
    name VARCHAR(100),
    type VARCHAR(40),
    c_order INTEGER NOT NULL,
    PRIMARY KEY (id_reserv, cni, ISO_code, tod, name, type),
    FOREIGN KEY (id_reserv, cni, ISO_code, tod) REFERENCES Trip(id_reserv, cni, ISO_code, tod),
    FOREIGN KEY (name, type) REFERENCES Jurisdiction(name, type)
);