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

##cur.execute('''CREATE TABLE Zlocin (id SERIAL PRIMARY KEY,
##                                    idP text,
##                                    mesec int,
##                                    prijavil text,
##                                    ukrepal text,
##                                    gSirina decimal,
##                                    gDolzina decimal,
##                                    lokacija text,
##                                    lsoa text,                                  
##                                    tip text,
##                                    status text)''')

##cur.execute('''CREATE TABLE Postopek (id SERIAL PRIMARY KEY,
##                                      idP text,
##                                      mesec int,
##                                      prijavil text,
##                                      ukrepal text,
##                                      gSirina decimal,
##                                      gDolzina decimal,
##                                      lokacija text,
##                                      lsoa text,
##                                      stanje text)''')


##cur.execute('''CREATE TABLE Preiskava (id SERIAL PRIMARY KEY,
##                                       tip text,
##                                       dan int,
##                                       mesec int,
##                                       gSirina decimal,
##                                       gDolzina decimal,
##                                       spol text,
##                                       starostMin int,
##                                       starostMax int,
##                                       rasa text,
##                                       uradnaRasa text,
##                                       predmetPreiskave text,
##                                       stanje text)''')

##cur.execute('''CREATE TABLE Lokacija (id text PRIMARY KEY,
##                                      lsoa text)''')



##cur.execute('''CREATE TABLE LSOA (id text PRIMARY KEY,
##                                  ime text)''')

conn.commit()


