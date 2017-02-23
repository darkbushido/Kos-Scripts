This is "oi" the script that does the ascent approach and rendezvous:
set torb to 3 * 60.
set pos to positionat ( target, time+torb).
set ap to target:altitude.
set vel to velocityat (target, time+torb).
set v to vel:orbit:mag.
set def to arccos ( v / 2300 ).
print "offset " + round(def,3).
set no to north:vector.
set pro to velocityat(target,time+torb):orbit.
print "target inclination: " + orbitat(target,time+torb):inclination.
set inc to 90 - orbitat(target,time+torb):inclination - def.
if vectorangle (pro, no) > 90 {set inc to 90 + orbitat(target,time+torb):inclination + def.}.
print "launching to: " + round(ap) + " at " + round(inc). wait .5. print "2". wait .5. print "1". wait .5.
set sd to 0.
sas on. set th to 1. lock throttle to th. set err to 0. set int to 0. set tv to 0.
set st to heading (inc ,88). set f to 0.
stage.
print "launch!".
if stage:solidfuel > 1 { print "solid boosters detected". set sd to 1. }.
set f to 0. until altitude > 100 { if (verticalspeed > 5 and f=0) { print "positive rate". set f to 1. }. }.
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
set th to 0.2 * err + 0.01 * int.

if th < 1 and f = 0 {
    print "max Q".
    set f to 1.
}.
}.
set s to 50.
set st to heading( inc, (40+s)).
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
set st to heading(inc, (40+s)).

set int to int + err.
set err to tv - airspeed.
if int > 30 {set int to 30.}.
if int < -10 {set int to -10.}.
set th to 0.2 * err + 0.01 * int.

if th < 1 and f = 0 {
    print "max Q2".
    set f to 1.
}.
}.
lock st to prograde.
print "steering prograde".
set th to 1.
print "throttle to 100%".
set ap to target:altitude + 2000.
set f to 0.
until apoapsis > ap{
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
set d to target:velocity:orbit - velocity:orbit.
set n to -1 * target:direction:vector.
set a to vectorangle (d, n).
set d to d:normalized.
set n to n:normalized.
set r to 3 * (d - n) + d.
lock steering to r.
wait 1.
set ao to a.
print "waiting to adjust orbit".
set f to 0.
print "waiting for angle minimum".
until a > ao or f = 1 {
set d to target:velocity:orbit - velocity:orbit.

set n to -1 * target:direction:vector.

if maxthrust > 0 {set tb to d:mag * mass / (maxthrust * 2).}.

set ti to target:distance / d:mag.

clearscreen.

print "Angle:       " + round(a, 3).

print "Thrust Angle: " + round(vectorangle (d, r), 3).

print "Distance:    " + round(target:distance).

print "Impact Time:     " + round(ti).

print "Burn Time:       " + round(tb).

print "Closest Appr:    " + round((target:distance * sin (vectorangle (d, n)))).

if tb > ti {
    set f to 1.

    print "Aborting!".

}.

set d to d:normalized.

set n to n:normalized.

set r to 3 * (d - n) + d.

wait .5.

set ao to a.

set a to vectorangle (d, n).
}.
set f1 to 0.
set f2 to 0.
//direction finding
lock throttle to th.
set f to 0.
set d to target:velocity:orbit - velocity:orbit.
set dv to d:mag.
if maxthrust > 0 {set t to (mass * dv) / (maxthrust * 1.9).}.
set timp to target:distance / d:mag.
print "threshold at: " + t.
print "impact at: " + timp.
print "maintaining angle at maximum closing speed".
until timp < t {
until stage:liquidfuel > .001 {
    set th to 0.
    stage.
    print "Staging".
    wait .2.
}.

set d to target:velocity:orbit - velocity:orbit.

set n to -1 * target:direction:vector.

set dv to d:mag.

if maxthrust > 0 {set t to (mass * dv) / (maxthrust * 1.9).}.

set timp to target:distance / d:mag.

set d to d:normalized.

set n to n:normalized.

set m to vectorangle (d, n) * 6.

if vectorangle (d, n) > 9.2 { set m to (90 / vectorangle (d, n)).}.

set r to m * (d - n) + d.

lock steering to r.

set th to (vectorangle (d, n) - 1) / 4.

clearscreen.

print "Angle:        " + round(vectorangle (d, n), 3).

print "Thrust Angle: " + round(vectorangle (d, r), 3).

print "Distance:     " + round(target:distance).

print "Impact Time:  " + round(timp).

print "Burn Time:    " + round(t).

print "Closest Appr: " + round((target:distance * sin (vectorangle (d, n)))).

wait .25.
}.
set d to target:velocity:orbit - velocity:orbit.
set timp to (target:distance - 50) / d:mag.
set int to 0.
clearscreen.
print "maintaining angle and closing speed".
print "time to impact: " + timp.
print target:distance.
print d:mag.
until (target:distance < 60 or d:mag < 10) {
until stage:liquidfuel > .001 {
    set th to 0.
    stage.
    print "Staging".
    wait .2.
}.

set d to target:velocity:orbit - velocity:orbit.

set n to -1 * target:direction:vector.

set timp to (target:distance - 60) / d:mag.

if maxthrust > 0 {set v to (timp * (maxthrust / mass)) * 1.9.}.

set dv to d:mag.

if maxthrust > 0 {set t to (mass * dv) / (maxthrust * 1.9).}.

set err to d:mag - v.

set int to int + err.

if int > 50 { set int to 50. }.

if int < -50 { set int to -50. }.

set d to d:normalized.

set n to n:normalized.

if (vectorangle (d, n) / 3) - 1 > err * .3 + int * .01 { set th to (vectorangle (d, n) / 2).}.

if (vectorangle (d, n) / 3) - 1 < err * .3 + int * .01 { set th to err * .3 + int * .01.}.

set mult to vectorangle (d, n) * 5.

if vectorangle (d, n) > 9.2 { set mult to (90 / vectorangle (d, n)).}.

set r to mult * (d - n) + d.

lock steering to r.

clearscreen.

print "Angle:        " + round(vectorangle (d, n), 3).

print "Thrust Angle: " + round(vectorangle (d, r), 3).

print "Distance:     " + round(target:distance).

print "Impact Time:  " + round(timp).

print "Burn Time:    " + round(t).

print "Closest Appr: " + round((target:distance * sin (vectorangle (d, n)))).

wait .1.

set d to target:velocity:orbit - velocity:orbit.
}.
print "distance: " + target:distance.
print "closing speed: " + d:mag.
set th to 1.
lock throttle to th.
set d to target:velocity:orbit - velocity:orbit.
lock steering to d.
set th to d:mag / 30.
print "killing final velocity".
until d:mag < .5 {
until stage:liquidfuel > .001 {
    set th to 0.
    stage.
    print "Staging".
    wait .2.
}.

set d to target:velocity:orbit - velocity:orbit.

set th to d:mag / 30.
}.
print "distance: " + target:distance.
print "speed: " + d:mag.
SET SHIP:CONTROL:PILOTMAINTHROTTLE TO 0.