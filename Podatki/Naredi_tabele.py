#!/usr/bin/python
# -*- encoding: utf-8 -*-

# uvozimo bottle.py
from bottle import *

# uvozimo ustrezne podatke za povezavo
import auth

# uvozimo psycopg2
import psycopg2, psycopg2.extensions, psycopg2.extras
psycopg2.extensions.register_type(psycopg2.extensions.UNICODE) # se znebimo problemov s šumniki

debug(True)

conn = psycopg2.connect(database=auth.db, host=auth.host, user=auth.user, password=auth.password)
conn.set_isolation_level(psycopg2.extensions.ISOLATION_LEVEL_AUTOCOMMIT) # onemogočimo transakcije
cur = conn.cursor(cursor_factory=psycopg2.extras.DictCursor)

cur.execute('''CREATE TABLE Zlocin (id text PRIMARY KEY,
                                       mesec text,
                                       gSirina text,
                                       gDolzina text,
                                       ulica text,
                                       tip text)''')

## cur.execute('''CREATE TABLE Okrozje (ime text PRIMARY KEY)''')

##cur.execute('''CREATE TABLE Postopek (id text PRIMARY KEY,
##                                      kazen text)''')

##cur.execute('''CREATE TABLE Preiskava (id SERIAL PRIMARY KEY,
##                                       datum date,
##                                       gSirina int,
##                                       gDolzina int,
##                                       spol text,
##                                       starostMin int,
##                                       starostMax int,
##                                       rasa text,
##                                       uradnaRasa text,
##                                       tip text,
##                                       predmetPreiskave text,
##                                       stanje text)''')

conn.commit()


