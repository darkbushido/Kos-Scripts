local mission is import("lib/mission.ks").
local ship_utils is import("lib/ship_utils.ks").
local node_exec is import("lib/node_exec.ks").
local node_set_inc_lan is import("lib/node_set_inc_lan.ks").
local hohmann is import("lib/hohmann_transfer.ks").
local hillclimb is import("lib/hillclimb.ks").
local fitness is import("lib/fitness_transfer.ks").
local science is import("lib/science.ks").
local lazcalc is import("lib/lazcalc.ks").
local parking_alt is BODY:ATM:HEIGHT + 10000.
local target_periapsis is 30000.
local target_inc is 178.
local pitch_exp is 0.25.
local target_body is Mun.
if core:volume:exists("params.json") {
  set params to readjson("params.json").
}
if defined(params) {
  print params.
  if params:haskey("Altitude") set target_periapsis to params["Altitude"].
  if params:haskey("Inc") set target_inc to params["Inc"].
  if params:haskey("Body") set target_body to body(params["Body"]).
  if params:haskey("PitchExp") set pitch_exp to params["PitchExp"].
}
print target_body.
local science_flyby is mission(mission_definition@).
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
    local dir to lazcalc["LAZ"](parking_alt, target_body:obt:inclination).
    lock steering to heading(dir, 88).
    next().
  }
  seq:add(launch@).
  function launch {
    local dir to lazcalc["LAZ"](parking_alt, 0).
    if not target_body:obt:inclination = 0 {
      print "waiting for launch window.".
      local lan_t to lazcalc["window"](target_body).
      warpto(lan_t).
      wait until time:seconds >= lan_t.
      set dir to lazcalc["LAZ"](parking_alt, target_body:obt:inclination).
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
    node_set_inc_lan["create_node"](target_body:obt:inclination, target_body:obt:lan).
    node_exec["exec"](true).
    next().
  }
  seq:add(hohmann_transfer@).
  function hohmann_transfer {
    local r1 to SHIP:OBT:SEMIMAJORAXIS.
    local r2 TO TARGET_BODY:obt:semimajoraxis.
    set d_time to hohmann["time"](r1,r2, TARGET_BODY).
    hohmann["transfer"](r1,r2,d_time).
    local nn to nextnode.
    local data to list(time:seconds + nn:eta, nn:radialout, nn:normal, nn:prograde).
    print "Inclination Fitness".
    set data to hillclimb["seek"](data, fitness["inclination_fit"](target_body, target_inc), 1).
    set data to hillclimb["seek"](data, fitness["inclination_fit"](target_body, target_inc), 0.1).
    print "Periapsis Fitness".
    set data to hillclimb["seek"](data, fitness["periapsis_fit"](target_body, target_periapsis), 1).
    set data to hillclimb["seek"](data, fitness["periapsis_fit"](target_body, target_periapsis), 0.1).
    node_exec["exec"](true).
    next().
  }
  seq:add(hohmann_correction@).
  function hohmann_correction {
    set ct to time:seconds + (eta:transition * 0.7).
    local data is list(0).
    set data to hillclimb["seek"](data, fitness["correction_fit"](ct, target_body, target_periapsis), 1).
    set data to hillclimb["seek"](data, fitness["correction_fit"](ct, target_body, target_periapsis), 0.1).
    local nn to nextnode.
    if nn:deltav:mag < 0.1 remove nn.
    next().
  }
  seq:add(exec_node@).
  function exec_node {
    if hasnode
      node_exec["exec"]().
    next().
  }
  seq:add(wait_for_soi_change@).
  function wait_for_soi_change {
    wait 5.
    lock steering to lookdirup(v(0,1,0), sun:position).
    if ship:body = target_body {
      wait 30.
      next().
    }
  }
  seq:add(collect_science@).
  function collect_science {
    print "Gathering Science".
    science["science"]().
    next().
  }
  seq:add(return_correction@).
  function return_correction {
    set ct to time:seconds + eta:periapsis.
    local data is list(0).
    set data to hillclimb["seek"](data, fitness["correction_fit"](ct, kerbin, 30000), 10).
    set data to hillclimb["seek"](data, fitness["correction_fit"](ct, kerbin, 30000), 1).
    set data to hillclimb["seek"](data, fitness["correction_fit"](ct, kerbin, 30000), 0.1).
    local nn to nextnode.
    if nn:deltav:mag < 0.1 remove nn.
    else node_exec["exec"]().
    next().
  }
  seq:add(collect_science@).
  seq:add(wait_for_return_soi_change@).
  function wait_for_return_soi_change {
    wait 5.
    lock steering to lookdirup(v(0,1,0), sun:position).
    if ship:body = Kerbin {
      wait 30.
      next().
    }
  }
  seq:add(atmo_reentry@).
  function atmo_reentry {
    lock steering to lookdirup(v(0,1,0), sun:position).
    if Altitude < SHIP:BODY:ATM:HEIGHT + 10000 {
      print "Entering Atmo".
      lock steering to srfretrograde.
      until stage:number = 1 {
        if STAGE:READY {STAGE.}
        else {wait 1.}
      }
      ev:remove("Power"). ship_utils["disable"](). wait 5.
    } else if not ev:haskey("Power") {
      ev:add("Power", ship_utils["power"]). wait 5.
    }
    if (NOT CHUTESSAFE) {
      unlock steering.
      CHUTESSAFE ON.
    }
    if list("Landed","Splashed"):contains(status) {
      ev:add("Power", ship_utils["power"]). wait 5.
      next().
  }}
  seq:add(finish@).
  function finish {
    deletepath("startup.ks").
    reboot.
  }
}
export(science_flyby).
