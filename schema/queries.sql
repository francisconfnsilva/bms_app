-- Query A: The name of all boats that are used in some trip.
SELECT DISTINCT b.name
FROM Boat b
JOIN Trip t
  ON t.cni = b.cni
 AND t.ISO_code = b.ISO_code;

-- Query B: The name of all boats that are not used in any trip.
SELECT b.name
FROM Boat b
LEFT JOIN Trip t
  ON t.cni = b.cni
 AND t.ISO_code = b.ISO_code
WHERE t.cni IS NULL;


-- Query C: The name of all boats registered in 'PRT'(ISO_code) for which at least one responsible for a reservation has a surname ending with 'Santos'.
SELECT DISTINCT b.name
FROM Boat b
JOIN associates a
  ON a.cni = b.cni
 AND a.ISO_code = b.ISO_code
JOIN Senior s
  ON s.email = a.responsible_email
JOIN Sailor sa
  ON sa.email = s.email
WHERE b.ISO_code = 'PRT'
  AND sa.surname LIKE '%Santos';

-- Query D: The full name of all skippers without any certificate corresponding to the class of the trip's boat.
SELECT DISTINCT sa.first_name, sa.surname
FROM Trip t
JOIN Boat b
  ON b.cni = t.cni
 AND b.ISO_code = t.ISO_code
JOIN Sailor sa
  ON sa.email = t.skippers_email
LEFT JOIN Certifications c
  ON c.email = sa.email
 AND c.validates_max = b.belongs_max
WHERE c.email IS NULL;

