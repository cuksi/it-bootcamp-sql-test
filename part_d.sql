USE bootcamp.test_3_nedelja;

-- CREATE SCHEMA IF NOT EXISTS test_3_nedelja;

-- DROP TABLE dim_player;

CREATE OR REPLACE TABLE dim_team AS
SELECT 
    team_id, team_name, short_name AS team_code
FROM bootcamp.northern_star.teams;

CREATE OR REPLACE TABLE dim_date AS
SELECT CAST(DATE_FORMAT(d, 'yyyyMMdd') AS INT) AS date_key,
       d                                       AS full_date,
       DATE_FORMAT(d, 'EEEE')                  AS weekday_name,
       DAYOFWEEK(d) IN (1, 7)                  AS is_weekend,
       CASE WHEN MONTH(d) >= 7 THEN CONCAT(YEAR(d), '/', SUBSTRING(CAST(YEAR(d) + 1 AS STRING), 3, 2))
            ELSE CONCAT(YEAR(d) - 1, '/', SUBSTRING(CAST(YEAR(d) AS STRING), 3, 2))
       END                                     AS season
FROM (SELECT EXPLODE(SEQUENCE(DATE'2023-07-01', DATE'2025-06-30', INTERVAL 1 DAY)) AS d);

CREATE OR REPLACE TABLE dim_player AS
SELECT player_id, first_name, last_name, nationality, position
FROM bootcamp.northern_star.players
UNION ALL
SELECT -1, 'Nije odredjen', 'Nije odredjen', 'Nepoznato', 'Nepoznato';

CREATE OR REPLACE TABLE dim_referee AS
SELECT referee_id, referee_name, nationality
FROM bootcamp.northern_star.referees;

CREATE OR REPLACE TABLE fact_card AS
SELECT
    me.event_id,
    me.match_id,
    CAST(DATE_FORMAT(m.kickoff_ts, 'yyyyMMdd') AS INT) AS date_key,
    me.team_id,
    COALESCE(dp.player_id, -1) AS player_id,
    m.referee_id,
    me.event_type AS card_type
FROM bootcamp.northern_star.match_events me
JOIN bootcamp.northern_star.matches m ON m.match_id = me.match_id
LEFT JOIN dim_player dp ON dp.player_id = me.player_id
WHERE me.event_type IN ('yellow_card', 'second_yellow', 'red_card');

SELECT * FROM fact_card;

SELECT COUNT(*) FROM fact_card; -- Ukupno 2678 redova u fact_cards

SELECT COUNT(*) FROM bootcamp.northern_star.match_events WHERE event_type IN ('yellow_card', 'second_yellow', 'red_card');  -- ukupno 2678 kartona u izvornoj tabeli

SELECT * FROM fact_card WHERE player_id = -1;
SELECT COUNT(*) FROM fact_card WHERE player_id = -1
-- Ima dva zuta kartona (yellow_card)