    1 rem up, up and away!
    5 print"{clr}"
   10 v=53248 : rem basisadresse vic
   11 s=2040 : rem basisadresse sprite pointer
   13 poke v+21,4+8+16 : rem sprite 2, 3 und 4 aktivieren
   14 poke v+39+2,1 : rem sprite 2 farbe
   15 poke s+2,13: poke s+3,13: poke s+4,13: rem daten fuer sprites aus blk 13
   16 b=13*64 : rem basisadresse datenblock 13
   20 for n=0 to 62 : read q : poke b+n,q : next
   25 poke v+23,4: poke v+29,4: rem expand sprite 2
   30 for x=0 to 255
   40 poke v+4,x : rem x-koord. sprite 2
   45 poke v+6,(x+50)and255: rem x-koord. sprite 3
   48 poke v+8,x : rem x-koord. sprite 4
   50 poke v+5,x : rem y-koord. sprite 2
   55 poke v+7,255-x : rem y-koord. sprite 3
   58 poke v+9,100 : rem y-koord. sprite 4
   60 next x
   70 goto 30
  200 data 0,127,0,1,255,192,3,255,224,3,231,224
  210 data 7,217,240,7,223,240,7,217,240,3,231,224
  220 data 3,255,224,3,255,224,2,255,160,1,127,64
  230 data 1,62,64,0,156,128,0,156,128,0,73,0,0,73,0
  240 data 0,62,0,0,62,0,0,62,0,0,28,0
