#!/usr/bin/python
# -*- encoding: utf-8 -*-

# uvozimo bottle.py
from bottle import *

# uvozimo ustrezne podatke za povezavo
import auth

# uvozimo psycopg2
import psycopg2, psycopg2.extensions, psycopg2.extras
psycopg2.extensions.register_type(psycopg2.extensions.UNICODE) # se znebimo problemov s šumniki

import csv

debug(True)

conn = psycopg2.connect(database=auth.db, host=auth.host, user=auth.user, password=auth.password)
conn.set_isolation_level(psycopg2.extensions.ISOLATION_LEVEL_AUTOCOMMIT) # onemogočimo transakcije
cur = conn.cursor(cursor_factory=psycopg2.extras.DictCursor)

def preveri(podatek):
    if podatek == '':
        return None
    else:
        return float(podatek)

def uvozi_street(csv_datoteka):
    i = True
    with open(csv_datoteka, 'r') as csvfile:
        for row in csvfile:
            if i:
                i = False
                continue
            row = (row.split(','))[:-1]
            id_p = row[0]
            if id_p == '':
                id_p = None
            mesec = row[1][-2:]
            mesec = preveri(mesec)
            prijavil = row[2]
            ukrepal = row[3]
            gsirina = row[4]
            gsirina = preveri(gsirina)
            gdolzina = row[5]
            gdolzina = preveri(gdolzina)
            lokacija = row[6]
            if lokacija != 'No Location':
                lokacija = lokacija[11:]
            lsoa = row[7]
            tip = row[9]
            status = row[10]
            cur.execute('''INSERT INTO Zlocin (idp, mesec, prijavil, ukrepal, gsirina, gdolzina, lokacija, lsoa, tip, status)
                           VALUES (%s, %s, %s, %s, %s, %s, %s, %s, %s, %s)''',
                           [id_p, mesec, prijavil, ukrepal, gsirina, gdolzina, lokacija, lsoa, tip, status])

def uvozi_lsoa(csv_datoteka):
    i = True
    cur.execute('''SELECT id FROM lsoa''')
    flattened = [val for sublist in cur.fetchall() for val in sublist]
    s = set(flattened)
    with open(csv_datoteka, 'r') as csvfile:
        for row in csvfile:
            if i:
                i = False
                continue
            row = (row.split(','))[:-1]
            koda = row[7]
            if koda in s:
                continue
            else:
                s.add(koda)
            ime = row[8]
            cur.execute('''INSERT INTO lsoa VALUES (%s, %s)''',
                           [koda, ime])

def uvozi_preiskava(csv_datoteka):
    i = True
    with open(csv_datoteka, 'r') as csvfile:
        for row in csvfile:
            if i:
                i = False
                continue
            row = (row.split(','))[:-1]
            tip = row[0]
            datum = row[1]
            dan = datum[8:10]
            mesec = datum[5:7]
            gsirina = row[4]
            gsirina = preveri(gsirina)
            gdolzina = row[5]
            gdolzina = preveri(gdolzina)
            spol = row[6]
            starost = row[7]
            if starost == '':
                starostmin = None
                starostmax = None
            else:
                starostmin = smin(starost)
                starostmax = smax(starost)
            rasa = row[8]
            uradnarasa = row[9]
            predmetpreiskave = row[11]
            stanje = row[12]
            cur.execute('''INSERT INTO Preiskava (tip, dan, mesec, gsirina, gdolzina, spol, starostmin, starostmax, rasa, uradnarasa, predmetpreiskave, stanje)
                           VALUES (%s, %s, %s, %s, %s, %s, %s, %s, %s, %s, %s, %s)''',
                           [tip, dan, mesec, gsirina, gdolzina, spol, starostmin, starostmax, rasa, uradnarasa, predmetpreiskave, stanje])

def smin(starost):
    if 'over' in starost:
        return int(starost[5:])
    elif 'under' in starost:
        return None
    else:
        return int(starost[:2])

def smax(starost):
    if 'over' in starost:
        return None
    elif 'under' in starost:
        return int(starost[6:])
    else:
        return int(starost[3:])

def uvozi_postopek(csv_datoteka):
    i = True
    with open(csv_datoteka, 'r') as csvfile:
        for row in csvfile:
            if i:
                i = False
                continue
            row = (row.split(','))
            idp = row[0]
            mesec = row[1][5:]
            prijavil = row[2]
            ukrepal = row[3]
            gsirina = row[4]
            gsirina = preveri(gsirina)
            gdolzina = row[5]
            gdolzina = preveri(gdolzina)
            lokacija = row[6]
            lsoa = row[7]
            stanje = row[9]
            cur.execute('''INSERT INTO Postopek (idp, mesec, prijavil, ukrepal, gsirina, gdolzina, lokacija, lsoa, stanje)
                           VALUES (%s, %s, %s, %s, %s, %s, %s, %s, %s)''',
                           [idp, mesec, prijavil, ukrepal, gsirina, gdolzina, lokacija, lsoa, stanje])
            
                          
    
conn.commit()

##uvozi_street('ClevelandPolice/2015-01/2015-01-cleveland-street.csv')
##uvozi_street('ClevelandPolice/2015-02/2015-02-cleveland-street.csv')
##uvozi_street('ClevelandPolice/2015-03/2015-03-cleveland-street.csv')
##uvozi_street('ClevelandPolice/2015-04/2015-04-cleveland-street.csv')
##uvozi_street('ClevelandPolice/2015-05/2015-05-cleveland-street.csv')
##uvozi_street('ClevelandPolice/2015-06/2015-06-cleveland-street.csv')
##uvozi_street('ClevelandPolice/2015-07/2015-07-cleveland-street.csv')
##uvozi_street('ClevelandPolice/2015-08/2015-08-cleveland-street.csv')
##uvozi_street('ClevelandPolice/2015-09/2015-09-cleveland-street.csv')
##uvozi_street('ClevelandPolice/2015-10/2015-10-cleveland-street.csv')
##uvozi_street('ClevelandPolice/2015-11/2015-11-cleveland-street.csv')
##uvozi_street('ClevelandPolice/2015-12/2015-12-cleveland-street.csv')

uvozi_postopek('ClevelandPolice/2015-01/2015-01-cleveland-outcomes.csv')
uvozi_postopek('ClevelandPolice/2015-02/2015-02-cleveland-outcomes.csv')
uvozi_postopek('ClevelandPolice/2015-03/2015-03-cleveland-outcomes.csv')
uvozi_postopek('ClevelandPolice/2015-04/2015-04-cleveland-outcomes.csv')
uvozi_postopek('ClevelandPolice/2015-05/2015-05-cleveland-outcomes.csv')
uvozi_postopek('ClevelandPolice/2015-06/2015-06-cleveland-outcomes.csv')
uvozi_postopek('ClevelandPolice/2015-07/2015-07-cleveland-outcomes.csv')
uvozi_postopek('ClevelandPolice/2015-08/2015-08-cleveland-outcomes.csv')
uvozi_postopek('ClevelandPolice/2015-09/2015-09-cleveland-outcomes.csv')
uvozi_postopek('ClevelandPolice/2015-10/2015-10-cleveland-outcomes.csv')
uvozi_postopek('ClevelandPolice/2015-11/2015-11-cleveland-outcomes.csv')
uvozi_postopek('ClevelandPolice/2015-12/2015-12-cleveland-outcomes.csv')


##uvozi_street('2015-01/2015-01-city-of-london-street.csv')
##uvozi_street('2015-02/2015-02-city-of-london-street.csv')
##uvozi_street('2015-03/2015-03-city-of-london-street.csv')
##uvozi_street('2015-04/2015-04-city-of-london-street.csv')
##uvozi_street('2015-05/2015-05-city-of-london-street.csv')
##uvozi_street('2015-06/2015-06-city-of-london-street.csv')
##uvozi_street('2015-07/2015-07-city-of-london-street.csv')
##uvozi_street('2015-08/2015-08-city-of-london-street.csv')
##uvozi_street('2015-09/2015-09-city-of-london-street.csv')
##uvozi_street('2015-10/2015-10-city-of-london-street.csv')
##uvozi_street('2015-11/2015-11-city-of-london-street.csv')
##uvozi_street('2015-12/2015-12-city-of-london-street.csv')

##uvozi_lsoa('2015-01/2015-01-city-of-london-street.csv')
##uvozi_lsoa('2015-02/2015-02-city-of-london-street.csv')
##uvozi_lsoa('2015-03/2015-03-city-of-london-street.csv')
##uvozi_lsoa('2015-04/2015-04-city-of-london-street.csv')
##uvozi_lsoa('2015-05/2015-05-city-of-london-street.csv')
##uvozi_lsoa('2015-06/2015-06-city-of-london-street.csv')
##uvozi_lsoa('2015-07/2015-07-city-of-london-street.csv')
##uvozi_lsoa('2015-08/2015-08-city-of-london-street.csv')
##uvozi_lsoa('2015-09/2015-09-city-of-london-street.csv')
##uvozi_lsoa('2015-10/2015-10-city-of-london-street.csv')
##uvozi_lsoa('2015-11/2015-11-city-of-london-street.csv')
##uvozi_lsoa('2015-12/2015-12-city-of-london-street.csv')

##uvozi_preiskava('2015-03/2015-03-city-of-london-stop-and-search.csv')
##uvozi_preiskava('2015-04/2015-04-city-of-london-stop-and-search.csv')
##uvozi_preiskava('2015-05/2015-05-city-of-london-stop-and-search.csv')
##uvozi_preiskava('2015-06/2015-06-city-of-london-stop-and-search.csv')
##uvozi_preiskava('2015-07/2015-07-city-of-london-stop-and-search.csv')
##uvozi_preiskava('2015-08/2015-08-city-of-london-stop-and-search.csv')
##uvozi_preiskava('2015-09/2015-09-city-of-london-stop-and-search.csv')
##uvozi_preiskava('2015-10/2015-10-city-of-london-stop-and-search.csv')
##uvozi_preiskava('2015-11/2015-11-city-of-london-stop-and-search.csv')
##uvozi_preiskava('2015-12/2015-12-city-of-london-stop-and-search.csv')

##uvozi_postopek('2015-01/2015-01-city-of-london-outcomes.csv')
##uvozi_postopek('2015-02/2015-02-city-of-london-outcomes.csv')
##uvozi_postopek('2015-03/2015-03-city-of-london-outcomes.csv')
##uvozi_postopek('2015-04/2015-04-city-of-london-outcomes.csv')
##uvozi_postopek('2015-05/2015-05-city-of-london-outcomes.csv')
##uvozi_postopek('2015-06/2015-06-city-of-london-outcomes.csv')
##uvozi_postopek('2015-07/2015-07-city-of-london-outcomes.csv')
##uvozi_postopek('2015-08/2015-08-city-of-london-outcomes.csv')
##uvozi_postopek('2015-09/2015-09-city-of-london-outcomes.csv')
##uvozi_postopek('2015-10/2015-10-city-of-london-outcomes.csv')
##uvozi_postopek('2015-11/2015-11-city-of-london-outcomes.csv')
##uvozi_postopek('2015-12/2015-12-city-of-london-outcomes.csv')
