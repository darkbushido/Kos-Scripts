local mission is import("lib/mission.ks").
local ship_utils is import("lib/ship_utils.ks").
local p is import("lib/params.ks").
local suicide is import("lib/suicide_burn.ks").
print "Mission Params".
print p.
list files.
local mission_base is mission(mission_definition@).
function mission_definition {
  parameter seq, ev, next.
  SET prevThrust TO AVAILABLETHRUST.
  ev:add("Power", ship_utils["power"]).
  SET PID TO PIDLOOP(0.01, 0.006, 0.006, 0, 1).
  SET PID:SETPOINT TO BODY:ATM:HEIGHT + 10000.
  SET thrott to 0.

function suicide_burn {
  suicide["SuicideBurn"]().
  next().
}
function finish {
  ship_utils["enable"]().
  deletepath("startup.ks").
  if defined(p) {
    if p["NextShip"]:typename = "Vessel" {
      local template to KUniverse:GETCRAFT(p["NextShip"], "VAB").
      KUniverse:LAUNCHCRAFT(template).
    } else if p:haskey("SwitchToShp") {
      KUniverse:ACTIVEVESSEL(vessel(params["SwitchToShp"])).
    }
  }
  reboot.
}
  seq:add(suicide_burn@).
  seq:add(finish@).
}
export(mission_base).
