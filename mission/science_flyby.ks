local mission is import("lib/mission.ks").
local ship_utils is import("lib/ship_utils.ks").
local node_exec is import("lib/node_exec.ks").
local node_set_inc_lan is import("lib/node_set_inc_lan.ks").
local hohmann is import("lib/hohmann_transfer.ks").
local PARKING_ALTITUDE is BODY:ATM:HEIGHT + 10000.
local TARGET_BODY is Mun.
if core:volume:exists("params.json") {
  set params to readjson("params.json").
}
if defined(params) {
  if params:haskey("Altitude")
    set TARGET_ALTITUDE to params["Altitude"].
  if params:haskey("Body")
    set TARGET_BODY to body(params["Body"])
}
  and params:haskey("Altitude")
  set TARGET_ALTITUDE to params["Altitude"].

local science_flyby is mission(mission_definition@).
function mission_definition {
  parameter seq, ev, next.
  SET prevThrust TO AVAILABLETHRUST.
  ev:add("Power", ship_utils["power"]).
  SET PID TO PIDLOOP(0.01, 0.006, 0.006, 0, 1).
  SET PID:SETPOINT TO PARKING_ALTITUDE.
  SET thrott to 0.

  seq:add(prelaunch@).
  function prelaunch {
    ev:remove("Power").
    ship_utils["disable"]().
    set ship:control:pilotmainthrottle to 0.
    lock throttle to PID:UPDATE(TIME:SECONDS, APOAPSIS).
    lock steering to heading(90, 90).
    wait 1.
    next().
  }
  seq:add(launch@).
  function launch {
    stage. wait 5.
    lock pct_alt to (alt:radar / PARKING_ALTITUDE).
    lock target_pitch to 90 - (90* pct_alt^0.35).
    lock steering to heading(90, target_pitch).
    if not ev:haskey("AutoStage")
      ev:add("AutoStage", ship_utils["auto_stage"]).
    next().
  }
  seq:add(coast_to_atm@).
  function coast_to_atm {
    if alt:radar > body:atm:height {
      unlock throttle.
      set throttle to 0.
      if not ev:haskey("Power")
        ev:add("Power", ship_utils["power"]).
      if ev:haskey("AutoStage")
        ev:remove("AutoStage").
      wait 0. stage. wait 0.
      panels on.
      next().
    }
  }
  seq:add(circularize@).
  function circularize {
    local sma to ship:obt:SEMIMAJORAXIS.
    local ecc to ship:obt:ECCENTRICITY.
    if hasnode {
      node_exec["exec"](true).
    } else if (ecc < 0.001) or (sma < 70000 and ecc < 0.005) {
      next().
    } else {
      node_exec["circularize"]().
    }
  }
  seq:add(set_inc_lan@).
  function set_inc_lan {
    node_set_inc_lan["node"]().
    node_exec["exec"](true).
    next().
  }
  // seq:add(hohmann_transfer@).
  // function hohmann_transfer {
  //   local r1 to SHIP:OBT:SEMIMAJORAXIS.
  //   local r2 TO TARGET_ALTITUDE + SHIP:OBT:BODY:RADIUS.
  //   local d_time to eta:apoapsis.
  //   if defined(params) and params:haskey("Body")
  //     set d_time to hohmann["time"](r1,r2, params["Body"]).
  //   hohmann["transfer"](r1,r2,d_time).
  //   node_exec["exec"](true).
  //   next().
  // }
  // seq:add(circularize@).

}
export(science_flyby).
