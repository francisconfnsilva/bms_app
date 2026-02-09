-- 1
-- Logic: Group by country, count boats, and ensure that count is greater or equal to the count of every other country.
SELECT country
FROM boat
GROUP BY country
HAVING COUNT(*) >= ALL (
    SELECT COUNT(*)
    FROM boat
    GROUP BY country
);

-- 2
-- Logic: Join Sailor and Certificate, Group by Sailor, filter where count >= 2.
SELECT s.firstname, s.surname, s.email
FROM sailor s
JOIN sailing_certificate sc ON s.email = sc.sailor
GROUP BY s.firstname, s.surname, s.email
HAVING COUNT(*) >= 2;


-- 3
-- Logic: Relational Division. We look for sailors where there does NOT exist a location in Portugal
-- that the sailor has NOT visited (Double NOT EXISTS).
SELECT s.firstname, s.surname
FROM sailor s
WHERE NOT EXISTS (
    -- Find a location in Portugal...
    SELECT l.latitude, l.longitude
    FROM location l
    WHERE l.country_name = 'Portugal'
    -- ...that this sailor has NOT sailed to.
    AND NOT EXISTS (
        SELECT 1
        FROM trip t
        WHERE t.skipper = s.email
        AND t.to_latitude = l.latitude
        AND t.to_longitude = l.longitude
    )
);

-- 4
-- Logic: Count trips per skipper and compare to the count of trips of all other skippers.
SELECT s.firstname, s.surname, COUNT(*) AS trip_count
FROM sailor s
JOIN trip t ON s.email = t.skipper
GROUP BY s.firstname, s.surname, s.email
HAVING COUNT(*) >= ALL (
    SELECT COUNT(*)
    FROM trip
    GROUP BY skipper
);

-- 5
-- Logic: Group by Sailor AND Reservation (composite key). Sum the duration (arrival - takeoff).
-- Compare that sum to the sums of all other Sailor-Reservation pairs.
SELECT s.firstname, s.surname, SUM(t.arrival - t.takeoff) AS total_duration
FROM sailor s
JOIN trip t ON s.email = t.skipper
GROUP BY s.firstname, s.surname, s.email, t.reservation_start_date, t.reservation_end_date, t.boat_country, t.cni
HAVING SUM(t.arrival - t.takeoff) >= ALL (
    SELECT SUM(t2.arrival - t2.takeoff)
    FROM trip t2
    GROUP BY t2.skipper, t2.reservation_start_date, t2.reservation_end_date, t2.boat_country, t2.cni
);