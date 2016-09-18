local mission is import("lib/mission.ks").
local ship_utils is import("lib/ship_utils.ks").
local node_exec is import("lib/node_exec.ks").
local node_set_inc_lan is import("lib/node_set_inc_lan.ks").
local hohmann is import("lib/hohmann_transfer.ks").
local lazcalc is import("lib/lazcalc.ks").
local parking_alt is BODY:ATM:HEIGHT + 10000.
local target_ecc to 0.
local target_sma to 650000.
local target_inc to 0.
local target_lan to 0.
local target_agp to 0.
local target_pe_alt to (1 - target_ecc) * target_sma
    - ship:body:radius.
local target_ap_alt to (1 + target_ecc) * target_sma
    - ship:body:radius.

if core:volume:exists("params.json") {
  set params to readjson("params.json").
}
if defined(params) {
  if params:haskey("Alt") set target_alt to params["Alt"].
  if params:haskey("ECC") set target_ecc to params["ECC"].
  if params:haskey("SMA") set target_sma to params["SMA"].
  if params:haskey("Apa") set target_ap_alt to params["Apa"].
  if params:haskey("Pea") set target_pe_alt to params["Pea"].
  if params:haskey("INC") set target_inc to params["INC"].
  if params:haskey("LAN") set target_lan to params["LAN"].
  if params:haskey("AgP") set target_agp to params["AgP"].
}

local launch_to_orbit_mission is mission(mission_definition@).
function mission_definition {
  parameter seq, ev, next.
  SET prevThrust TO AVAILABLETHRUST.
  ev:add("Power", ship_utils["power"]).
  SET PID TO PIDLOOP(0.01, 0.006, 0.006, 0, 1).
  SET PID:SETPOINT TO parking_alt.
  SET thrott to 0.

  seq:add(launch_window@).
  function launch_window {
    if not target_lan = 0
      lazcalc["LAN"](target_lan).
    next().
  }
  seq:add(prelaunch@).
  function prelaunch {
    ev:remove("Power").
    ship_utils["disable"]().
    set ship:control:pilotmainthrottle to 0.
    lock throttle to PID:UPDATE(TIME:SECONDS, APOAPSIS).
    local dir to lazcalc["LAZ"](parking_alt, target_inc).
    lock steering to heading(dir, 89).
    wait 1.
    next().
  }
  seq:add(launch@).
  function launch {
    stage. wait 5.
    lock pct_alt to alt:radar / parking_alt.
    lock target_pitch to 90 - (90* pct_alt^0.25).
    local dir to lazcalc["LAZ"](parking_alt, target_inc).
    lock steering to heading(dir, target_pitch).
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
    node_set_inc_lan["create_node"](target_inc, target_lan).
    node_exec["exec"](true).
    next().
  }
  seq:add(hohmann_transfer@).
  function hohmann_transfer {
    local r1 to SHIP:OBT:SEMIMAJORAXIS.
    local r2 TO target_sma.
    local d_time to node_set_inc_lan["true_anom"](target_agp).
    if defined(params) and params:haskey("Vessel")
      set d_time to hohmann["time"](r1,r2, params["Vessel"],params["Offset"]).
    hohmann["transfer"](r1,r2,d_time).
    node_exec["exec"](true).
    next().
  }

}
export(launch_to_orbit_mission).
