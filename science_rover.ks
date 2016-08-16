clearscreen.
Print "Science Patrol around KSC".
set waypoint1 to latlng(-0.0880702411485266, 285.338306892511).
set waypoint2 to latlng(-0.0852482662802016, 285.34956949764).
set waypoint3 to latlng(-0.0795903992425412, 285.355822892694).
set waypoint4 to latlng(-0.0789918106413352, 285.386249174916).
set waypoint5 to latlng(-0.0968132778146474, 285.392211971867).
set waypoint6 to latlng(-0.097764047975908, 285.444531471677).
set waypoint7 to latlng(-0.121731502276379, 285.395669841288).

set nextwaypoint to waypoint1.
set w to 1.
until w = 7 {
  lock wheelthrottle to -0.2.
  wait 3.
  lock wheelsteering to nextwaypoint.
  lock wheelthrottle to 0.1.
  wait 5.
  lock wheelthrottle to 0.5.
  until nextwaypoint:distance < 50 {
    set debugarrow1 to vecdraw(v(0,0,0),nextwaypoint:altitudeposition(ship:altitude+10),RGB(1,0,0),"Drive To",1.0, TRUE).
    set x to up - facing.
    set attitude to sqrt((x:pitch)^2+(x:yaw)^2).
    if attitude > 2 {unlock wheelsteering.}.
    if GROUNDSPEED > 14 {lock wheelthrottle to 0.1.}.
    if GROUNDSPEED < 14 {lock wheelthrottle to 0.5.}.
    if GROUNDSPEED > 18 {lock wheelthrottle to -0.1.}.

    if attitude < 2 {lock wheelsteering to nextwaypoint.}.
  }.
  print "Navigating to waypoint: " + w.
  set w to w +1.
  if w = 2 {set nextwaypoint to waypoint2.}.
  if w = 3 {set nextwaypoint to waypoint3.}.
  if w = 4 {set nextwaypoint to waypoint4.}.
  if w = 5 {set nextwaypoint to waypoint5.}.
  if w = 6 {set nextwaypoint to waypoint6.}.
}.
lock wheelthrottle to -0.1.
wait until surfacespeed < 3.
brakes on.
unlock all.
