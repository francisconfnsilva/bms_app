-- ==================================================================================
-- IC-1: Every Sailor is either Senior or Junior
-- ==================================================================================

-- 1. FUNCTION: Check Disjoint ("Cannot be both")
CREATE OR REPLACE FUNCTION check_sailor_disjoint() RETURNS TRIGGER AS $$
BEGIN
    -- If we are inserting into Senior, ensure they are not already in Junior
    IF TG_TABLE_NAME = 'senior' THEN
        IF EXISTS (SELECT 1 FROM junior WHERE email = NEW.email) THEN
            RAISE EXCEPTION 'Integrity Error: Sailor % cannot be both Senior and Junior', NEW.email;
        END IF;
    -- If we are inserting into Junior, ensure they are not already in Senior
    ELSIF TG_TABLE_NAME = 'junior' THEN
        IF EXISTS (SELECT 1 FROM senior WHERE email = NEW.email) THEN
            RAISE EXCEPTION 'Integrity Error: Sailor % cannot be both Senior and Junior', NEW.email;
        END IF;
    END IF;
    RETURN NEW;
END;
$$ LANGUAGE plpgsql;

-- 2. FUNCTION: Check Mandatory ("Must be at least one")
-- This function checks if the sailor exists in EITHER table.
CREATE OR REPLACE FUNCTION check_sailor_mandatory() RETURNS TRIGGER AS $$
BEGIN
    IF NOT EXISTS (SELECT 1 FROM senior WHERE email = NEW.email)
       AND NOT EXISTS (SELECT 1 FROM junior WHERE email = NEW.email) THEN
        RAISE EXCEPTION 'Integrity Error: Sailor % must be either Senior or Junior (Total Participation)', NEW.email;
    END IF;
    RETURN NEW;
END;
$$ LANGUAGE plpgsql;

-- 3. TRIGGERS
-- Disjoint checks happen immediately
DROP TRIGGER IF EXISTS trig_check_senior_disjoint ON senior;
CREATE TRIGGER trig_check_senior_disjoint
BEFORE INSERT OR UPDATE ON senior
FOR EACH ROW EXECUTE FUNCTION check_sailor_disjoint();

DROP TRIGGER IF EXISTS trig_check_junior_disjoint ON junior;
CREATE TRIGGER trig_check_junior_disjoint
BEFORE INSERT OR UPDATE ON junior
FOR EACH ROW EXECUTE FUNCTION check_sailor_disjoint();

-- Mandatory check is DEFERRED (happens at commit time)
DROP TRIGGER IF EXISTS trig_check_sailor_mandatory ON sailor;
CREATE CONSTRAINT TRIGGER trig_check_sailor_mandatory
AFTER INSERT ON sailor DEFERRABLE
FOR EACH ROW EXECUTE FUNCTION check_sailor_mandatory();


-- ==================================================================================
-- IC-2: Trips for the same reservation must not overlap
-- ==================================================================================

-- 1. FUNCTION: Check for time overlaps
CREATE OR REPLACE FUNCTION check_trip_overlap() RETURNS TRIGGER AS $$
BEGIN
    -- Check if there is any EXISTING row that overlaps with the NEW row
    -- for the same reservation keys (reservation_start, reservation_end, country, cni)
    IF EXISTS (
        SELECT 1 FROM trip
        WHERE
            -- Match the Reservation ID (Composite Key)
            boat_country = NEW.boat_country
            AND cni = NEW.cni
            AND reservation_start_date = NEW.reservation_start_date
            AND reservation_end_date = NEW.reservation_end_date

            -- Check for Date Overlap logic: (StartA < EndB) and (EndA > StartB)
            AND takeoff < NEW.arrival
            AND arrival > NEW.takeoff

            -- Ensure we aren't comparing the row to itself (important for UPDATEs)
            AND (takeoff, reservation_start_date, reservation_end_date, boat_country, cni)
                IS DISTINCT FROM
                (NEW.takeoff, NEW.reservation_start_date, NEW.reservation_end_date, NEW.boat_country, NEW.cni)
    ) THEN
        RAISE EXCEPTION 'Integrity Error: Overlapping trips detected for boat % (Reservation Start: %)', NEW.cni, NEW.reservation_start_date;
    END IF;
    RETURN NEW;
END;
$$ LANGUAGE plpgsql;

-- 2. TRIGGER
DROP TRIGGER IF EXISTS trig_check_trip_overlap ON trip;
CREATE TRIGGER trig_check_trip_overlap
BEFORE INSERT OR UPDATE ON trip
FOR EACH ROW EXECUTE FUNCTION check_trip_overlap();

-- ==================================================================================
-- Evaluation
-- ==================================================================================

-- IC-1

START TRANSACTION;

    SET CONSTRAINTS ALL DEFERRED;

    -- Insert the generic sailor
    INSERT INTO sailor (email, firstname, surname)
    VALUES ('captain.jack@mail.com', 'Jack', 'Sparrow');

    -- Insert the specific rank
    INSERT INTO senior (email)
    VALUES ('captain.jack@mail.com');

COMMIT;

-- This should FAIL immediately because we didn't assign a rank
INSERT INTO sailor (email, firstname, surname)
VALUES ('pirate@mail.com', 'Jack', 'Sparrow');

SET search_path TO project_db;

-- 1. Create a valid Senior (This block should SUCCEED)
START TRANSACTION;
SET CONSTRAINTS ALL DEFERRED;
INSERT INTO sailor (email, firstname, surname) VALUES ('senior_bob@mail.com', 'Bob', 'Marley');
INSERT INTO senior (email) VALUES ('senior_bob@mail.com');
COMMIT;

-- 2. Now try to add Bob to 'junior' (This line should FAIL)
INSERT INTO junior (email) VALUES ('senior_bob@mail.com');

-- IC-2

-- Try to add a trip from June 4th to June 6th (Overlaps with existing June 2-5 trip)
INSERT INTO trip (takeoff, arrival, insurance, from_latitude, from_longitude, to_latitude, to_longitude, skipper, reservation_start_date, reservation_end_date, boat_country, cni)
VALUES (
    '2024-06-04', '2024-06-06', -- Overlapping Dates!
    'INS-TEST-FAIL',
    37.0194, -7.9304, 38.7223, -9.1393, -- Locations
    'john.santos@mail.com', -- Skipper
    '2024-06-01', '2024-06-10', 'Portugal', 'PT-5521-AB' -- Same Reservation
);