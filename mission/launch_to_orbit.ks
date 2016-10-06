local mission is import("lib/mission.ks").
local ship_utils is import("lib/ship_utils.ks").
local node_exec is import("lib/node_exec.ks").
local node_set_inc_lan is import("lib/node_set_inc_lan.ks").
local hohmann is import("lib/hohmann_transfer.ks").
local lazcalc is import("lib/lazcalc.ks").
local hillclimb is import("lib/hillclimb.ks").
local fitness is import("lib/fitness_orbit.ks").
local parking_alt is BODY:ATM:HEIGHT + 10000.
local target_ecc to 0.
local target_sma to 650000.
local target_inc to 0.
local target_agp to 0.
local pitch_exp to 0.35.
local target_pe_alt to (1 - target_ecc) * target_sma - ship:body:radius.
local target_ap_alt to (1 + target_ecc) * target_sma - ship:body:radius.

if core:volume:exists("params.json") {
  set params to readjson("params.json").
}
if defined(params) {
  print params.
  if params:haskey("Alt") set target_alt to params["Alt"].
  if params:haskey("ECC") set target_ecc to params["ECC"].
  if params:haskey("SMA") set target_sma to params["SMA"].
  if params:haskey("Apa") set target_ap_alt to params["Apa"].
  if params:haskey("Pea") set target_pe_alt to params["Pea"].
  if params:haskey("INC") set target_inc to params["INC"].
  if params:haskey("LAN") set target_lan to params["LAN"].
  if params:haskey("AgP") set target_agp to params["AgP"].
  if params:haskey("PitchExp") set pitch_exp to params["PitchExp"].
}

local launch_to_orbit_mission is mission(mission_definition@).
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
    local dir to lazcalc["LAZ"](parking_alt, target_inc).
    lock steering to heading(dir, 88).
    next().
  }
  seq:add(launch@).
  function launch {
    local dir to lazcalc["LAZ"](parking_alt, target_inc).
    if not target_inc = 0 {
      set dir to lazcalc["LAZ"](parking_alt, target_inc).
      print dir.
    }
    stage. wait 10.
    lock pct_alt to (alt:radar / parking_alt).
    lock target_pitch to 90 - (90* pct_alt^pitch_exp).
    lock steering to heading(dir, target_pitch).
    if not ev:haskey("AutoStage")
      ev:add("AutoStage", ship_utils["auto_stage"]).
    next().
  }
  seq:add(coast_to_atm@).
  function coast_to_atm {
    if alt:radar > body:atm:height {
      set warp to 0.
      lock throttle to 0.
      if not ev:haskey("Power")
        ev:add("Power", ship_utils["power"]).
      if ev:haskey("AutoStage")
        ev:remove("AutoStage").
      wait 2. stage. wait 1.
      panels on.
      next().
    }
  }
  seq:add(circularize_ap@).
  function circularize_ap {
    local sma to ship:obt:SEMIMAJORAXIS.
    local ecc to ship:obt:ECCENTRICITY.
    if hasnode node_exec["exec"](true).
    else if (ecc < 0.0015) or (600000 > sma and ecc < 0.005) next().
    else node_exec["circularize"]().
  }
  seq:add(set_inc_lan@).
  function set_inc_lan {
    if not defined(target_lan)
      set target_lan to SHIP:OBT:LAN.
    node_set_inc_lan["create_node"](target_inc, target_lan).
    node_exec["exec"](true).
    next().
  }
  seq:add(adjust_apoapsis@).
  function adjust_apoapsis {
    local d_time to time:seconds + eta:periapsis.
    local data to list(d_time, 0, 0, 0).
    set data to hillclimb["seek"](data, fitness["apoapsis_fit"](d_time, target_ap_alt), 1).
    set data to hillclimb["seek"](data, fitness["apoapsis_fit"](d_time, target_ap_alt), 0.1).
    node_exec["exec"](true).
    next().
  }
  seq:add(adjust_periapsis@).
  function adjust_periapsis {
    local d_time to time:seconds + eta:periapsis.
    local data to list(d_time, 0, 0, 0).
    set data to hillclimb["seek"](data, fitness["periapsis_fit"](d_time, target_pe_alt), 1).
    set data to hillclimb["seek"](data, fitness["periapsis_fit"](d_time, target_pe_alt), 0.1).
    node_exec["exec"](true).
    next().
  }
  seq:add(finish@).
  function finish {
    deletepath("startup.ks").
    reboot.
  }


}
export(launch_to_orbit_mission).
