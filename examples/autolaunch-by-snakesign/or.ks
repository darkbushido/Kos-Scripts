This is "or" it puts your ship into circular orbit of any inclination and altitude, make sure you get the parameters right:
declare parameter apo. declare parameter inc.
print "Launching to: " + apo + "m at " + inc + "degrees".
print "3". wait .5. print "2". wait .5. print "1". wait .5.
set sd to 0.
sas on. set th to 1. lock throttle to th. set err to 0. set int to 0. set tv to 0.
set st to heading (90 + inc ,88). set f to 0.
stage.
print "launch!".
if stage:solidfuel > 1 { print "solid boosters detected". set sd to 1. }.
until altitude > 100 { if (verticalspeed > 5 and f=0) { print "positive rate". set f to 1. }. }.
set f to 0.
print "100m, roll program". lock steering to st. sas off. print "intelligent throttle".
lock tv to ship:termvelocity.
until apoapsis > 9000{ until stage:liquidfuel > .001 { set th to 0. stage.
print "Staging". wait .2.
}.
if stage:solidfuel < .001 and sd = 1 {
    stage.
    print "Staging boosters".
    wait .2.
    set sd to 0.
}.

set int to int + err.
set err to tv - airspeed.
if int > 30 {set int to 30.}.
if int < -5 {set int to -5.}.
set th to 0.2 * err + 0.02 * int.

if th < 1 and f = 0 {
    print "max Q".
    set f to 1.
}.
}.
set s to 50.
set st to heading(inc + 90, (40+s)).
print "pitch program".
set f to 0.
until apoapsis > 45000{
if altitude > 40000 and f = 0 {

    print "activating spacecraft".

    toggle ag1.

    print "jettison escape rocket".

    toggle ag2.

    set f to 1.

}.

until stage:liquidfuel > .001 {
    set th to 0.
    stage.
    print "Staging".
    wait .2.
}.


if stage:solidfuel < .001 and sd = 1 {
    stage.
    print "Staging boosters".
    wait .2.
    set sd to 0.
}.

set s to ((45000 - apoapsis) / 2000).
if s > 50 {set s to 50.}.
set st to heading(inc + 90, (40+s)).

set int to int + err.
set err to tv - airspeed.
if int > 30 {set int to 30.}.
if int < -10 {set int to -10.}.
set th to 0.2 * err + 0.02 * int.

if th < 1 and f = 0 {
    print "max Q2".
    set f to 1.
}.
}.
lock st to prograde. print "steering prograde".
set th to 1.
print "throttle to 100%".
until apoapsis > apo{
if altitude > 40000 and f = 0 {

    print "activating spacecraft".

    toggle ag1.

    print "jettison escape rocket".

    toggle ag2.

    set f to 1.

}.

until stage:liquidfuel > .001 {
    set th to 0.
    stage.
    print "Staging".
    wait .2.
}.

set th to 1.
}.
set th to 0.
print "wait to ap".
set warp to 3.
set s to 2200.
set dv to s - velocity:orbit:mag.
set t to (mass * dv) / (maxthrust).
set f to 0.
print "waiting: " + (eta:apoapsis - (t/2)) + "s".
until ( eta:apoapsis < ( t / 2)) {
if altitude > 40000 and f = 0 {

    print "activating spacecraft".

    toggle ag1.

    print "jettison escape rocket".

    toggle ag2.

    set f to 1.

}.

set dv to s - velocity:orbit:mag.

set t to (mass * dv) / (maxthrust).
}.
set ecco to apoapsis - periapsis.
set warp to 0.
set th to 1.
wait .1.
set ecc to apoapsis - periapsis.
set err to 0.
set int to 0.
set tht to 1.
set th to tht.
set f1 to 0.
set f2 to 0.
until ((ecc - 50) > ecco) {
set ecco to ecc.

set dv to s - velocity:orbit:mag.

set t to (mass * dv) / (maxthrust).

set err to t - eta:apoapsis + 1.

set int to int + err.

if int > 15 {set int to 15.}.

if int < -5 {set int to -5.}.

set tht to 0.3 * err + 0.03 * int.

if t < 1 {

    set tht to .5.
    if f1 = 0 {
        set f1 to 1.
        print "less than 1s, finalizing burn".
    }.
}.

if verticalspeed < 0 {
    set tht to 1.
    if f2 = 0 {
        set f2 to 1.
        print "falling!  Throttle to 100%".
    }.

}.

set th to tht.

until stage:liquidfuel > .001 {
    set th to 0.
    stage.
    print "Staging".
    set th to tht.
    wait .2.
}.

set ecc to apoapsis - periapsis.
}.
lock throttle to 0.
set ecc to apoapsis-periapsis.
print "eccentricity: "+ecc.
print "Done!".
SET SHIP:CONTROL:PILOTMAINTHROTTLE TO 0.