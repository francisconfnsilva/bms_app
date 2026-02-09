DROP VIEW IF EXISTS trip_info;

CREATE VIEW trip_info AS
SELECT
    -- país de origem da viagem
    co_origin.iso_code      AS country_iso_origin,
    co_origin.name          AS country_name_origin,

    -- país de destino da viagem
    co_dest.iso_code        AS country_iso_dest,
    co_dest.name            AS country_name_dest,

    -- localizações de origem e destino
    loc_from.name           AS loc_name_origin,
    loc_to.name             AS loc_name_dest,

    -- barco e país do barco
    t.cni                   AS cni_boat,
    co_boat.iso_code        AS country_iso_boat,
    co_boat.name            AS country_name_boat,

    -- início da viagem
    t.takeoff               AS trip_start_date
FROM trip AS t
JOIN location AS loc_from
  ON t.from_latitude  = loc_from.latitude
 AND t.from_longitude = loc_from.longitude
JOIN country AS co_origin
  ON loc_from.country_name = co_origin.name
JOIN location AS loc_to
  ON t.to_latitude  = loc_to.latitude
 AND t.to_longitude = loc_to.longitude
JOIN country AS co_dest
  ON loc_to.country_name = co_dest.name
JOIN boat AS b
  ON t.boat_country = b.country
 AND t.cni          = b.cni
JOIN country AS co_boat
  ON b.country = co_boat.name;
