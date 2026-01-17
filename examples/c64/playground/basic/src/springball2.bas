    5 frame=53280:bkg=53281:text=1024:colr=55296:obs=216:ball=81
   10 print"{clr}"
   20 poke frame,7: poke bkg,0
   21 for l= 1 to 10
   25 poke text+int(rnd(1)*1000),obs
   27 next l
   30 x=1:y=1
   40 dx=1:dy=1
   50 poke colr+x+40*y,1
   55 poke text+x+40*y,ball
   60 for t=1 to 20: next
   70 loc=text+x+40*y
   80 x=x+dx
   85 if peek(text+x+40*y)=obs then dx=-dx:goto 80
   90 if x=0 or x=39 then dx=-dx
  100 y=y+dy
  105 if peek(text+x+40*y)=obs then dy=-dy:goto 100
  110 if y=0 or y=24 then dy=-dy
  115 poke loc,32
  120 goto 50
