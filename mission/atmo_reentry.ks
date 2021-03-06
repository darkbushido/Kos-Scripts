local mission is import("lib/mission.ks").
local ship_utils is import("lib/ship_utils.ks").
local p is import("lib/params.ks").

print "Mission Params".
print p.
list files.
local mission_base is mission(mission_definition@).
function mission_definition {
  parameter seq, seqn, ev, next.
  SET pT TO AVAILABLETHRUST.
  ev:add("Power", ship_utils["power"]).
  SET thrott to 0.

function atmo_reentry {
  lock steering to lookdirup(v(0,1,0), sun:position).
  if Altitude < SHIP:BODY:ATM:HEIGHT + 10000 {
    lock steering to srfretrograde.
    until stage:number <= 1 {
      if STAGE:READY {STAGE.}
      else {wait 1.}
    }
    RADIATORS ON.
    ev:remove("Power"). ship_utils["disable"](). wait 5.
  } else if not ev:haskey("Power") {
    ev:add("Power", ship_utils["power"]). wait 5.
  }
  if (NOT CHUTESSAFE) { unlock steering. CHUTESSAFE ON. next().}
}
function finish {
  ship_utils["enable"]().
  deletepath("startup.ks").
  if notfalse(p["NextShip"]) {
    local template to KUniverse:GETCRAFT(p["NextShip"], "VAB"). KUniverse:LAUNCHCRAFT(template).
  } else if notfalse(p["SwitchToShp"]) { set KUniverse:ACTIVEVESSEL to p["SwitchToShp"].}
  reboot.
}
  seq:add(atmo_reentry@). seqn:add("atmo_reentry").
  seq:add(finish@). seqn:add("finish").
}
export(mission_base).
