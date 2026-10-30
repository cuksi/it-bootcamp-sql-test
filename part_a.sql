-- 1 zadatak: Колико утакмица је одиграно у фебруару 2025?
SELECT
    COUNT(*)
FROM matches m
WHERE m.kickoff_ts >= '2025-02-01' AND m.kickoff_ts < '2025-03-01';
-- Resenje: ukupno 40 utakmica

-- 2 zadatak: Који стадион има највећи капацитет, а који је највећи стадион неког клуба?
SELECT
    s.stadium_id, s.stadium_name, s.capacity
FROM stadiums s
ORDER BY s.capacity DESC LIMIT 1;
-- Najveci kapacitet stadiona:
-- stadium_id	    stadium_name	    capacity
-- 22	            National Stadium	80000

SELECT
    t.team_id,
    s.stadium_name, s.stadium_id,
    s.capacity
FROM teams t
LEFT JOIN stadiums s ON s.stadium_id = t.stadium_id
ORDER BY s.capacity DESC;
-- Najveci stadion nekog kluba: Harbourside Park - kapacitet: 52000

-- 3 zadatak: Колико играча у лиги има српско држављанство (nationality = 'Serbia')?
SELECT
    COUNT(*) AS broj_igraca
FROM players p
WHERE nationality = 'Serbia';
-- Resenje: ukupno 42 ugraca imaju Srpsko drzavljanstvo

-- 4 zadatak: Колико утакмица је завршено резултатом 1:1?
SELECT
    COUNT(*) AS total_games
FROM matches m
WHERE m.home_goals = 1 AND m.away_goals = 1;
-- Resenje: ukupno 94 utakmice su zavrsene nereseno rezultatom 1:1

-- 5 zadatak: Колика је просечна посета по сезони?
SELECT
    m.season AS sezona,
    ROUND(SUM(m.attendance) / COUNT(m.match_id) , 2) AS prosecna_poseta
FROM matches m
WHERE m.status = 'played'
GROUP BY m.season;
-- Rezultat:
-- sezona	    prosecna_poseta
-- 2023/24	    23765.12
-- 2024/25	    23626.35

-- 6 zadatak: Колико голова је дато из пенала по сезони?
-- penalty_goal
SELECT
    m.season as sezona,
    COUNT(*) AS gol_iz_penala
FROM matches m
LEFT JOIN match_events me ON me.match_id = m.match_id
WHERE me.event_type = 'penalty_goal'
GROUP BY m.season;
-- Resenje:
-- sezona	    gol_iz_penala
-- 2023/24	    104
-- 2024/25	    109

-- 7 zadatak: Колико различитих играча је дало бар један гол у сезони 2024/25?
SELECT
    m.season AS sezona,
    COUNT(DISTINCT me.player_id) AS broj_razlicitih_igraca
FROM matches m
LEFT JOIN match_events me ON me.match_id = m.match_id
WHERE m.season = '2024/25' AND me.event_type IN ('penalty_goal', 'goal', 'own_goal')
GROUP BY m.season;
-- Resenje: u sezoni 2024/25 je dalo 330 razlicitih igraca gol, ukljucuuto gol.

-- 8 zadatak: Који судија је највише пута судио утакмице клуба Northport United?
SELECT
    m.referee_id, r.referee_name AS ime_sudije,
    COUNT(
        CASE WHEN t.team_id = m.home_team_id THEN 1
             WHEN t.team_id = m.away_team_id THEN 1 
             ELSE 0 END
    ) AS broj_utakmica
FROM matches m
JOIN teams t ON t.team_id = m.home_team_id OR t.team_id = m.away_team_id
JOIN referees r ON r.referee_id = m.referee_id
WHERE t.team_name = 'Northport United'
GROUP BY m.referee_id, r.referee_name
ORDER BY broj_utakmica DESC LIMIT 1;
-- Resenje: Peter Lindgren je sudio najvise utakmica timu Northport United, to je 9 utakmica.

-- 9 zadatak: Који судија је у сезони 2024/25 имао највећи удео утакмица у којима је досуђен бар један пенал, дат или промашен?
WITH sudija_penal AS (
    SELECT
        r.referee_name,
        SUM(
            CASE WHEN me.event_type = 'penalty_goal' THEN 1 
                WHEN me.event_type = 'penalty_miss' THEN 1 
                END
        ) AS tot_penalty
    FROM referees AS r
    LEFT JOIN matches m ON r.referee_id = m.referee_id
    JOIN match_events me ON m.match_id = me.match_id
    WHERE m.season = '2024/25'
    GROUP BY r.referee_name
)
SELECT
    referee_name,
    ROUND(tot_penalty / (SELECT COUNT(*) FROM matches WHERE season = '2024/25') * 100, 2) AS udeo
FROM sudija_penal
ORDER BY udeo DESC LIMIT 1;
-- Resenje: Peter Lindgren ima najveci udeo 3.68

-- 10 zadatak: Који тренер је освојио највише бодова у утакмицама у којима је његов тим губио на полувремену? Рачунајте и домаће и гостујуће утакмице.
WITH total_pts AS (
    SELECT
        ms.spell_id, ms.manager_name AS manager_name,
        SUM(
            CASE WHEN m.home_goals_ht < m.away_goals_ht AND m.home_goals > m.away_goals THEN 3 
                WHEN m.home_goals_ht < m.away_goals_ht AND m.home_goals = m.away_goals THEN 1 
                ELSE 0 END
        ) AS pts
    FROM matches m
    LEFT JOIN manager_spells ms ON ms.team_id = m.home_team_id
    GROUP BY ms.spell_id, ms.manager_name
    UNION
    SELECT
        ms.spell_id, ms.manager_name  AS manager_name,
        SUM(
            CASE WHEN m.home_goals_ht > m.away_goals_ht AND m.home_goals < m.away_goals THEN 3 
                WHEN m.home_goals_ht > m.away_goals_ht AND m.home_goals = m.away_goals THEN 1 
                ELSE 0 END
        ) AS pts
    FROM matches m
    LEFT JOIN manager_spells ms ON ms.team_id = m.away_team_id
    GROUP BY ms.spell_id, ms.manager_name
)
SELECT
    manager_name,
    SUM(pts) AS ukupno_bodova
FROM total_pts
GROUP BY manager_name
ORDER BY ukupno_bodova DESC LIMIT 1;
-- Resenje: Zoran Tošić sa ukupno 18 poena.