local mission is import("lib/mission.ks").
local ship_utils is import("lib/ship_utils.ks").
local node_exec is import("lib/node_exec.ks").
local node_set_inc_lan is import("lib/node_set_inc_lan.ks").
local hohmann is import("lib/hohmann_transfer.ks").
local hillclimb is import("lib/hillclimb.ks").
local fitness is import("lib/fitness_orbit.ks").
local parking_alt is 80000.
local target_alt is 900000.
if core:volume:exists("params.json") {
  set params to readjson("params.json").
}
if defined(params) and params:haskey("Altitude")
  set target_alt to params["Altitude"].

print "Target Altitude: " + target_alt.
local rt_network_mission is mission(mission_definition@).
function mission_definition {
  parameter seq, ev, next.

  seq:add(wait_until_only_core@).
  function wait_until_only_core {
    LIST PROCESSORS IN ALL_PROCESSORS.
    if ALL_PROCESSORS:length = 1 {
      next().
    }
    else {
      print "Waiting until only Core".
      wait 10.
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
  seq:add(set_inc_lan@).
  function set_inc_lan {
    node_set_inc_lan["create_node"]().
    node_exec["exec"](true).
    next().
  }
  seq:add(hohmann_transfer@).
  function hohmann_transfer {
    local r1 to SHIP:OBT:SEMIMAJORAXIS.
    local r2 TO target_alt + SHIP:OBT:BODY:RADIUS.
    local d_time to eta:apoapsis.
    if defined(params) and params:haskey("Vessel") {
      set target_vessel to vessel(params["Vessel"]).
      set d_time to hohmann["time"](r1,r2, target_vessel,params["Offset"]).
    }
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
  seq:add(finish@).
  function finish {
    deletepath("startup.ks").
    reboot.
  }
}
export(rt_network_mission).
