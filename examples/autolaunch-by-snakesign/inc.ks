{
set torb to 3 * 60.
set pos to positionat ( target, time+torb).
set upv to up:vector.
until (vectorangle (pos, upv) < 15) and (vectorangle (pos, upv) > 0) {
set pos to positionat ( target, time+torb).

set upv to up:vector.

clearscreen.

print vectorangle (pos, upv).

//if vectorangle (pos, upv) > 40 { set warp to 4. }.
//if vectorangle (pos, upv) < 40 { set warp to 2. }.
}.
set warp to 0.
wait .5.
run oi.