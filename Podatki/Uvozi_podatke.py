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

def uvozi_street(csv_datoteka):
    i = True
    with open(csv_datoteka, 'r') as csvfile:
##        spamreader = csv.reader(csvfile, delimiter=' ', quotechar='|')
        for row in csvfile:
            if i:
                i = False
                continue
            row = (row.split(','))[:-1]
            id_z = row[0]
            if id_z == '':
                continue
            mesec = row[1][-2:]
            gsirina = row[4]
            gdolzina = row[5]
            ulica = row[6]
            tip = row[9]
            cur.execute('''INSERT INTO Zlocin VALUES (%s, %s, %s, %s, %s, %s)''',
                           [id_z, mesec, gsirina, gdolzina, ulica, tip])
    

conn.commit()


##uvozi_street('2015-06-city-of-london-street.csv')
