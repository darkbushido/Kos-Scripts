sas off.
rcs off.
set p to 7.
set i to p / 3.
set st to prograde.
lock steering to st.
lock st to target:portfacing:vector:normalized * -1.
wait 4.
rcs on.
lock cls to (target:ship:velocity:orbit - ship:velocity:orbit).
lock u to (facing * R (-90, 0, 0)):vector:normalized.
lock fwd to facing:vector:normalized.
lock stb to (facing * R (0, 90, 0)):vector:normalized.
lock uerr to target:ship:position * u.
lock ferr to target:ship:position * fwd.
lock stberr to target:ship:position * stb.
lock dup to cls * u.
lock dstb to cls * stb.
lock dfwd to cls * fwd.
set f to 1.
set uint to 0.
set stbint to 0.
set fint to 0.
set standoff to target:ship:position:mag.
if standoff < 15 {set standoff to 15.}.
until f = 0 {
set fwddes to (standoff - ferr) / 10.
if (abs(uerr) < .5) and (abs(stberr) < .5) { set fwddes to (ferr/ 20) * -1. set standoff to ferr. }.
if fwddes > 1.5 {set fwddes to 1.5.}.
if fwddes < -1.5 {set fwddes to -1.5.}.
set updes to (uerr / 12) * -1.
set stbdes to (stberr / 12) * -1.
if updes > 1.5 {set updes to 1.5.}.
if updes < -1.5 {set updes to -1.5.}.
if stbdes > 1.5 {set stbdes to 1.5.}.
if stbdes < -1.5 {set stbdes to -1.5.}.
set fpot to dfwd - fwddes.
set upot to dup - updes.
set stbpot to dstb - stbdes.
set fint to fint + fpot * .1.
set stbint to stbint + stbpot * .1.
set uint to uint + upot * .1.
if fint > 5 { set fint to 5.}.
if fint < -5 { set fint to -5. }.
if stbint > 5 { set stbint to 5.}.
if uint > 5 { set uint to 5. }.
if stbint < -5 { set stbint to -5.}.
if uint < -5 { set uint to -5. }.
set fwdctr to fpot * p + fint * i.
set ship:control:fore to (fwdctr).
set upctr to upot * p + uint * i.
set ship:control:top to (upctr).
set stbctr to stbpot * p + stbint * i.
set ship:control:starboard to (stbctr).
clearscreen.
print "up " + round(uerr, 2) + "m, " + round(dup, 2)+"m/s".
print "fwd " + round(ferr, 2) + "m, " + round(dfwd, 2)+"m/s".
print "stb " + round(stberr, 2) + "m, " + round(dstb, 2)+"m/s".
if (abs(uerr) < .5) and (abs(stberr) < .5) { print "approaching". }.
if (abs(uerr) > .5) or (abs(stberr) > .5) { print "holding at: " + round(standoff). }.
wait .1.
}.