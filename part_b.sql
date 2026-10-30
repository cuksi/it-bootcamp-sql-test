USE bootcamp.northern_star;

-- 1 zadatak: Преглед сезоне: број утакмица и голова, просечан број голова по утакмици, удео победа домаћина, нерешених и победа гостију.
SELECT
    COUNT(m.match_id) AS ukupan_broj_utakmica_u_sezoni,
    SUM(m.home_goals + m.away_goals) AS ukupno_golova_u_sezoni,
    ROUND(ukupno_golova_u_sezoni / ukupan_broj_utakmica_u_sezoni, 2) AS prosecno_golova_po_mecu,
    COUNT_IF(m.home_goals > m.away_goals) AS ukupno_pobeda_kuci,
    COUNT_IF(m.home_goals = m.away_goals) AS ukupno_neresenih_utakmica,
    COUNT_IF(m.home_goals < m.away_goals) AS ukupno_pobeda_u_gostima,
    ROUND(ukupno_pobeda_kuci / ukupan_broj_utakmica_u_sezoni * 100.0, 2) AS procenat_pobeda_kuci,
    ROUND(ukupno_neresenih_utakmica / ukupan_broj_utakmica_u_sezoni * 100.0, 2) AS procenat_neresenih,
    ROUND(ukupno_pobeda_u_gostima / ukupan_broj_utakmica_u_sezoni * 100.0, 2) AS procenat_pobeda_u_gostima
FROM matches m
WHERE m.season = '2024/25';
-- Rezultat:
-- ukupan_broj_utakmica_u_sezoni	ukupno_golova_u_sezoni	    prosecno_golova_po_mecu	    ukupno_pobeda_kuci	    ukupno_neresenih_utakmica	    ukupno_pobeda_u_gostima	    procenat_pobeda_kuci	    procenat_neresenih	    procenat_pobeda_u_gostima
-- 380	                            1092	                    2.87	                    157	                    95	                            128	                        41.32	                    25	                    33.68

-- 2 zadatak: По месецима: број утакмица и голова по месецима, и просечан број голова по утакмици у сваком месецу. Који месец се издваја?
SELECT
    MONTH(m.kickoff_ts) AS mesec,
    COUNT(m.match_id) AS ukupno_utakmica_u_mesecu,
    SUM(m.home_goals + m.away_goals) AS ukupno_golova_u_mesecu,
    ROUND(ukupno_golova_u_mesecu / ukupno_utakmica_u_mesecu, 2) AS prosecno_golova_po_mesecu
FROM matches m
WHERE m.season = '2024/25'
GROUP BY mesec
ORDER BY mesec;
-- Izdavaja se Avgust sa malim brojem utakmica i zbog toga ima najveci prosek golova u mesecu sa 3.54

-- 3 zadatak: Публика: просечна посета и попуњеност по стадиону; утакмице без податка о посети и утакмица без публике.
-- Uzete su u obzir samo utakmice gde imamo upisanu posecenost stadiona (tj. nismo racunali broj utakmica gde je posecenost NULL)
SELECT
    ROUND(AVG(m.attendance), 2) AS prosecna_poseta_u_sezoni,
    COUNT_IF(m.attendance IS NULL) AS utakmice_bez_podataka_o_posecenosti,
    COUNT_IF(m.attendance = 0) AS utakmice_bez_publike
FROM matches m
WHERE m.season = '2024/25';
-- prosecna_poseta_u_sezoni 	utakmice_bez_podataka_o_posecenosti	        utakmice_bez_publike
-- 24199.49	                    9	                                        0

SELECT
    s.stadium_name AS stadion,
    ROUND(SUM(m.attendance) / (s.capacity * (COUNT(m.match_id) - COUNT_IF(attendance IS NULL))) * 100.0 , 2) AS prosecna_popunjenost_po_stadionu
FROM matches m
LEFT JOIN stadiums s ON s.stadium_id = m.stadium_id
WHERE m.season = '2024/25'
GROUP BY s.stadium_name, s.capacity
ORDER BY prosecna_popunjenost_po_stadionu DESC;
-- stadion	                    prosecna_popunjenost_po_stadionu
-- Elmsworth Lane	            90.61
-- Castle Grounds	            89.75
-- Northport Arena	            88.42
-- Valemont Park	            88.16
-- Westmere Park	            88.01
-- Oakfield Road	            87.82
-- Mill Lane	                87.58
-- Forest Ground	            87.02
-- Stonebridge Park	            86.99
-- Cliff Road	                86.33
-- Queensport Docks Stadium	    85.82
-- Dunmore Park	                85.64
-- The Albion Ground	        84.78
-- Harbourside Park	            84.76
-- Riverside Ground	            84.62
-- Brackley Road	            84.19
-- Thornbury Bowl	            83.9
-- Lakeside Stadium	            83.55
-- Pemberton Park	            83.07
-- Kingsbridge Stadium	        80.78
-- National Stadium	            35.51

-- 4 zadatak: Судије: за сваког судију број утакмица и картони по утакмици.
SELECT
    r.referee_name AS ime_sudije,
    COUNT(DISTINCT m.match_id) AS broj_utakmica_sudije,
    COUNT(me.event_type) / broj_utakmica_sudije AS kartona_po_utakmici
FROM matches m
LEFT JOIN match_events me ON me.match_id = m.match_id AND me.event_type IN ('yellow_card', 'second_yellow', 'red_card')
JOIN referees r ON r.referee_id = m.referee_id
WHERE m.season = '2024/25'
GROUP BY ime_sudije
ORDER BY kartona_po_utakmici DESC;
-- ime_sudije	            broj_utakmica_sudije	kartona_po_utakmici
-- Peter Lindgren	        20	                    4.25
-- Amir Haddad	            20	                    4.1
-- Craig Pawson-Lee	        20	                    4
-- Luca Benedetti	        20	                    3.75
-- Mark Halsey-Brown	    20	                    3.75
-- Henrik Dahl	            20	                    3.75
-- Ivan Kovač	            20	                    3.75
-- Daniel Price	            20	                    3.65
-- Simon Albright	        20	                    3.6
-- Stuart Attwell-Jones	    20	                    3.55
-- Robert Kane	            20	                    3.45
-- Gavin Reid	            20	                    3.4
-- Owen Pritchard	        20	                    3.4
-- Tomás Herrera	        20	                    3.25
-- Neil Swarbrick	        20	                    3.15
-- Graham Sutton	        20	                    2.85
-- Michael Oliver Hart	    20	                    2.8
-- Jonas Berg	            20	                    2.8
-- Samuel Achebe	        20	                    2.75

-- 5 zadatak: Играчи: пет најбољих стрелаца и пет најбољих асистената.
-- U rezultate nisu uracunati auto golovi
SELECT 
    me.player_id, p.first_name, p.last_name,
    COUNT(*) AS golovi
FROM match_events me
JOIN matches m ON m.match_id = me.match_id
JOIN players p ON p.player_id = me.player_id
WHERE m.season = '2024/25' AND me.event_type IN ('goal', 'penalty_goal')
GROUP BY me.player_id, p.first_name, p.last_name
ORDER BY golovi DESC LIMIT 5;
-- Najbolji strelci:
-- player_id	first_name	    last_name	    golovi
-- 678	        Mattéo	        O'Brien	        34
-- 676	        Leo	            Marsh	        32
-- 680	        José	        Muñoz	        24
-- 234	        Marko	        Stanković	    17
-- 677	        Leo	            Marsh	        16
-- imaju dva igraca sa istim imenom i prezimenom u strelcima ali razliciti player id sto znaci da su dva razlicita igraca.

SELECT 
    me.related_player_id, p.first_name, p.last_name,
    COUNT(*) AS asistencije
FROM match_events me
JOIN matches m ON m.match_id = me.match_id
JOIN players p ON p.player_id = me.related_player_id
WHERE m.season = '2024/25' AND me.event_type = 'goal'
GROUP BY me.related_player_id, p.first_name, p.last_name
ORDER BY asistencije DESC LIMIT 5;
-- Najbolji asistenti:
-- related_player_id	    first_name	        last_name	    asistencije
-- 19	                    Pablo	            Fernández	    9
-- 111	                    Filip	            Petrović	    7
-- 341	                    Eirik	            Solberg	        7
-- 49	                    Lucas	            Pereira	        7
-- 45	                    Mikkel	            Nielsen	        6

-- 6 zadatak: Квалитет података: бар два проблема на која сте наишли у подацима (на пример утакмица чији резултат се не слаже са догађајима, догађаји са непостојећим играчем, дан без тренера), са упитима који их проналазе.
select * from matches where season = '2024/25';

SELECT * FROM manager_spells WHERE end_date < '2025-05-18' and end_date > '2024-08-17';
SELECT * FROM teams WHERE team_id = 7;
-- Tim Castlebrook United (team_id = 7) je bio jedan dan bez trenera

SELECT * FROM teams WHERE team_id = 6;
SELECT * FROM manager_spells WHERE start_date > '2025-02-27';
-- Tim Westmere Town (team_id = 6) je bio od 2025-02-27 do 2025-03-03 bez trenera