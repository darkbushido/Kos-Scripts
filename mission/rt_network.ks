local mission is import("lib/mission.ks").
local ship_utils is import("lib/ship_utils.ks").
local node_exec is import("lib/node_exec.ks").
local node_set_inc_lan is import("lib/node_set_inc_lan.ks").
local hohmann is import("lib/hohmann_transfer.ks").
local hillclimb is import("lib/hillclimb.ks").
local fitness is import("lib/fitness_orbit.ks").
local parking_alt is 80000.
local target_alt is 750000.
if core:volume:exists("params.json") {
  set params to readjson("params.json").
}
if defined(params) and params:haskey("Altitude")
  set target_alt to params["Altitude"].

print target_alt.
local rt_network_mission is mission(mission_definition@).
function mission_definition {
  parameter seq, ev, next.
  SET prevThrust TO AVAILABLETHRUST.
  ev:add("Power", ship_utils["power"]).
  SET PID TO PIDLOOP(0.01, 0.006, 0.006, 0, 1).
  SET PID:SETPOINT TO parking_alt.
  SET thrott to 0.

  seq:add(prelaunch@).
  function prelaunch {
    ev:remove("Power").
    ship_utils["disable"]().
    set ship:control:pilotmainthrottle to 0.
    lock throttle to PID:UPDATE(TIME:SECONDS, APOAPSIS).
    lock steering to heading(90, 89).
    wait 1.
    next().
  }
  seq:add(launch@).
  function launch {
    stage. wait 5.
    lock pct_alt to alt:radar / parking_alt.
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
    } else if (ecc < 0.0015) or (sma < 70000 and ecc < 0.005) {
      next().
    } else {
      node_exec["circularize"]().
    }
  }
  seq:add(hohmann_transfer@).
  function hohmann_transfer {
    local r1 to SHIP:OBT:SEMIMAJORAXIS.
    local r2 TO target_alt + SHIP:OBT:BODY:RADIUS.
    local d_time to eta:apoapsis.
    if defined(params) and params:haskey("Vessel")
      set d_time to hohmann["time"](r1,r2, params["Vessel"],params["Offset"]).
    hohmann["transfer"](r1,r2,d_time).
    local nn to nextnode.
    local t to time:seconds + nn:eta.
    local data is list(nn:prograde).
    print "Hillclimbing".
    set data to hillclimb["seek"](data, fitness["apoapsis_fit"](t, target_alt), 0.1).
    set data to hillclimb["seek"](data, fitness["apoapsis_fit"](t, target_alt), 0.01).
    node_exec["exec"](true).
    next().
  }
  seq:add(circularize@).
  seq:add(set_inc_lan@).
  function set_inc_lan {
    node_set_inc_lan["create_node"]().
    node_exec["exec"](true).
    next().
  }
  seq:add(finish@).
  function finish {
    deletepath("startup.ks").
    reboot.
  }
}
export(rt_network_mission).
