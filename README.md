# Goran Đurić
# Opis projekta:
## Ovaj projekat sadrži analizu podatak fudbalsih sezona 2023/24 i sezone 2024/25 Enegleske lige
### Izvlačenje različitih podatak vezano za:
- Golove
- Poene
- Prosek pobeda po utakmicama i koliko puta je pobeđivao domaćin a koliko gost
- Informacije o stadionima, lokacija i posete (prosečna, ukupna, bez poseta itd.)  
## Predpostavke
### Deo A - pitanja o podacima
- Zadatak 5: Predpostavljeno je da se trazi ukupna prosecna posecenost za sve klubove u sezoni.
- Zadatak 7: Ovde je pretpostavljeno da se traze i auto golovi, pa su i oni uracunati u resenje.  
### Deo B - izvestaj o sezoni 2024/25
0) Sve vrednosti u izvestaju su zaokruzene na dve decimale
1) Pregled sezone: Nema odlozenih utakmica u ovaoj sezoni, sve su odigrane po planu.
3) Publika: Uzete su u obzir samo utakmice gde imamo upisanu posecenost stadiona (tj. nismo racunali broj utakmica gde je posecenost NULL)
5) Igraci: U rezultate nisu uracunati auto golovi. Takodje u strelcima postoje dva igraca sa istim imenom i prezimenom, ali player_id je razlicit sto znaci da su dva razlicita igraca.
### Deo C - prozorske funkcije
2) Nije racunata utakmica koja nema zabelezenu posetu. Ako se za nju stavi nula onda ce nam prosek biti niži.
3) Ovde nisu uzeti u obzir autogolovi, samo regularni golovi i golovi iz penala su uzeti u obzir. Dodato i minute i added_time u ORDER BY zbog preciznost koji je igrač dao zadnji gol.
5) Pošto u zadatku piše da pratimo bodove kluba Northport City dati su bodovi od početka sezone. A da je trebala samo utakmica u kojoj je presao 50 bodova dodali bi na kraju query-a samo ovaj uslov: ORDER BY pts_so_far > 50 DESC LIMIT 1