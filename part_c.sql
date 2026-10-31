USE bootcamp.northern_star;

-- 1 zadatak: Колики удео у укупном броју голова лиге у сезони 2024/25 има сваки клуб? Ко има највећи удео?
WITH golova_po_klubu AS(
    SELECT
        t.team_id, t.team_name AS klub,
        SUM(m.home_goals) AS golovi
    FROM matches m
    JOIN teams t ON t.team_id = m.home_team_id
    WHERE m.season = '2024/25'
    GROUP BY t.team_id, t.team_name
    UNION ALL
    SELECT
        t.team_id, t.team_name AS klub,
        SUM(m.away_goals) AS golovi
    FROM matches m
    JOIN teams t ON t.team_id = m.away_team_id
    WHERE m.season = '2024/25'
    GROUP BY t.team_id, t.team_name
)
SELECT
   DISTINCT klub,
   SUM(golovi) OVER (partition BY team_id) AS golova_po_klubu,
   SUM(golovi) OVER () AS golovi_lige,
   ROUND((golova_po_klubu / golovi_lige) * 100.0, 2) AS udeo
FROM golova_po_klubu
ORDER BY udeo DESC;
-- Resenje: Najveci udeo lige Kingsbridge City sa 7.6%

-- 2 zadatak: Која су три стадиона са највећом просечном посетом у сезони 2024/25?
SELECT
    s.stadium_name AS stadion,
    ROUND(AVG(m.attendance), 2) AS prosek 
FROM matches m
JOIN stadiums s ON s.stadium_id = m.stadium_id
WHERE m.season = '2024/25'
GROUP BY m.stadium_id, stadion
ORDER BY prosek DESC LIMIT 3;
-- Resenje: 
-- stadion	                prosek
-- Harbourside Park	        44074.05
-- Kingsbridge Stadium	    37968.42
-- Northport Arena	        36250.17

-- 3 zadatak: За сваки клуб, ко је дао последњи гол клуба у сезони 2024/25 и када? Који клуб је последњи гол дао најраније?
SELECT
    t.team_name AS klub, 
    m.kickoff_ts AS datum, 
    p.first_name AS igrac_ime, 
    p.last_name AS igrac_prezime
FROM match_events me
JOIN matches m ON m.match_id = me.match_id
JOIN teams t ON t.team_id = me.team_id
JOIN players p ON p.player_id = me.player_id
WHERE me.event_type IN ('goal', 'penalty_goal') AND m.season = '2024/25'
QUALIFY ROW_NUMBER() OVER (PARTITION BY me.team_id ORDER BY m.kickoff_ts DESC, me.minute DESC, COALESCE(me.added_time, 0) DESC) = 1
ORDER BY m.kickoff_ts;
-- Resenje: 
-- klub	                    datum	                            igrac_ime	    igrac_prezime
-- Elmsworth Wanderers	    2025-05-03T15:00:00.000+00:00	    Marko	        Stanković

-- 4 zadatak: За домаће утакмице клуба Northport United у сезони 2024/25 прикажите посету и промену у односу на претходну домаћу утакмицу. Где је највећи пад?
SELECT
    DATE(m.kickoff_ts) AS datum,
    t.team_name AS klub,
    m.attendance AS posecenost,
    COALESCE(CAST(posecenost - LAG(m.attendance) OVER(ORDER BY kickoff_ts) AS STRING), 'Nema prethodne utakmice') AS razlika_u_odnosu_na_prethodnu
FROM matches m
JOIN teams t ON t.team_id = m.home_team_id
WHERE m.season = '2024/25' AND t.team_name = 'Northport United'
ORDER BY razlika_u_odnosu_na_prethodnu;
-- Resenje: Najveci pad za utakmicu odigranu 2024-11-10 gde je 10267 gledalaca manje u odnosu na prethodnu.

-- 5 zadatak: Пратите бодове клуба Northport City утакмицу по утакмицу у сезони 2024/25. У којој утакмици по реду и ког датума је прешао 50 бодова?
WITH running AS (
    SELECT
        t.team_id,
        t.team_name AS klub,
        kickoff_ts AS datum,
        ROW_NUMBER () OVER w AS games_played, 
        SUM (
            CASE WHEN t.team_id = m.home_team_id AND m.home_goals > m.away_goals THEN 3 
                 WHEN t.team_id = m.home_team_id AND m.home_goals = m.away_goals THEN 1 
                 WHEN t.team_id = m.away_team_id AND m.home_goals < m.away_goals THEN 3 
                 WHEN t.team_id = m.away_team_id AND m.home_goals = m.away_goals THEN 1 END
        ) OVER w AS pts_so_far
    FROM matches m
    JOIN teams t ON t.team_id = m.home_team_id OR t.team_id = m.away_team_id
    WHERE m.season = '2024/25' AND t.team_name = 'Northport City'
    WINDOW w AS (
        PARTITION BY season, team_id ORDER BY kickoff_ts, match_id ROWS BETWEEN UNBOUNDED PRECEDING AND CURRENT ROW
    )
)
SELECT 
    datum, 
    klub, games_played, pts_so_far
FROM running;
-- Resenje: Klub Northport City je nakon odigrane 21 utakmice (tj. 21 kola ) skupio vise od 50 bodova (51 bod ukupno).