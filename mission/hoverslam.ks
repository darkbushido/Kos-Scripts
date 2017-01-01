local mission is import("lib/mission.ks").
local ship_utils is import("lib/ship_utils.ks").
local p is import("lib/params.ks").
print "Mission Params".
print p.
list files.
local mission_base is mission(mission_definition@).
function mission_definition {
  parameter seq, ev, next.
  SET pT TO AVAILABLETHRUST.
  ev:add("Power", ship_utils["power"]).
  SET thrott to 0.

function hoverslam {
  gear on.
  lock steering to srfretrograde.
  set throt to 0.
  lock truealt to (altitude - geoposition:terrainheight).
  lock throttle to throt.
  until ((altitude - geoposition:terrainheight) < p["LND"]["RadarOffset"]) or (list("Landed","Splashed"):contains(status)) {
    set throt to min(1,max(0,(((p["LND"]["HSMOD"]/(1+constant:e^(5-1.5*truealt)))+(truealt/min(-1,(verticalspeed))))+(abs(verticalspeed)/(availablethrust/mass))))).
    wait 0.
  }
  unlock throttle.
  lock steering to up.
  next().
}
function finish {
  ship_utils["enable"]().
  deletepath("startup.ks").
  if notfalse(p["NextShip"]) {
    local template to KUniverse:GETCRAFT(p["NextShip"], "VAB"). KUniverse:LAUNCHCRAFT(template).
  } else if p:haskey("SwitchToShp") { KUniverse:ACTIVEVESSEL(vessel(params["SwitchToShp"])).}
  reboot.
}
  seq:add(hoverslam@).
  seq:add(finish@).
}
export(mission_base).
