library(ggmap)
#qmap('Ljubljana')
#qmap('Catez 8212', zoom = 16, maptype = 'hybrid') # lahko tudi type satellite

#setwd("C:/Users/Neza/Desktop/OPB/gorile/TestiranjeZemljevidov")
crimes <- read.csv("2016-03-city-of-london-street.csv")
#View(crimes) # pokaze celotno tabelo
#head(crimes) # prvih sest stolpcev tabele

# naredimo bazicen zemljevid kraja City of London
zemljevid <- qmap('City of London', zoom = 14, maptype = 'hybrid')
# na zemljevid narisemo rdece pikice tam, kjer so se zlocini zgodili
zemljevid + geom_point(data = crimes, aes(x = Longitude, y = Latitude), color="red", size=3, alpha=0.5)