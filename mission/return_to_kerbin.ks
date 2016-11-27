local mission is import("lib/mission.ks").
local ship_utils is import("lib/ship_utils.ks").
local p is import("lib/params.ks").
list files.
local science_flyby is mission(mission_definition@).
function mission_definition {
  parameter seq, ev, next.
  // parameter params, seq, ev, next, a_on to true.
  SET prevThrust TO AVAILABLETHRUST.
  ev:add("Power", ship_utils["power"]).
  print p["PAlt"].
  SET PID TO PIDLOOP(0.01, 0.006, 0.006, 0, 1).
  SET PID:SETPOINT TO BODY:ATM:HEIGHT + 10000.
  SET thrott to 0.

function wait_for_soi_change_kerbin {
  wait 5.
  lock steering to lookdirup(v(0,1,0), sun:position).
  if ship:body = Kerbin {
    wait 30.
    next().
}}
function atmo_reentry {
  lock steering to lookdirup(v(0,1,0), sun:position).
  if Altitude < SHIP:BODY:ATM:HEIGHT + 10000 {
    lock steering to srfretrograde.
    until stage:number = 1 {
      if STAGE:READY {STAGE.}
      else {wait 1.}
    }
    ev:remove("Power"). ship_utils["disable"](). wait 5.
  } else if not ev:haskey("Power") {
    ev:add("Power", ship_utils["power"]). wait 5.
  }
  if (NOT CHUTESSAFE) { unlock steering.CHUTESSAFE ON. }
  if list("Landed","Splashed"):contains(status) {
    ev:add("Power", ship_utils["power"]). wait 5.
    next().
}}
function finish {
  ship_utils["enable"]().
  deletepath("startup.ks").
  if defined(params) {
    if params:haskey("NextShip") {
      local template to KUniverse:GETCRAFT(params["NextShip"], "VAB").
      KUniverse:LAUNCHCRAFT(template).
    } else if params:haskey("SwitchToShp") {
      KUniverse:ACTIVEVESSEL(vessel(params["SwitchToShp"])).
    }
  }
  reboot.
}

      seq:add(wait_for_soi_change_kerbin@).
      seq:add(atmo_reentry@).
      seq:add(finish@).
  }
export(science_flyby).
