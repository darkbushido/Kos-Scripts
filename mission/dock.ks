local mission is import("lib/mission.ks").
local ship_utils is import("lib/ship_utils.ks").
local p is import("lib/params.ks").
local lazcalc is import("lib/lazcalc.ks").
local node_exec is import("lib/node_exec.ks").
local node_set_inc_lan is import("lib/node_set_inc_lan.ks").
local hohmann is import("lib/hohmann_transfer.ks").
local hc is import("lib/hillclimb.ks").
local orbitfit is import("lib/fitness_orbit.ks").
local transfit is import("lib/fitness_transfer.ks").
local rndz is import("lib/rendezvous.ks").

print "Mission Params".
print p.
list files.
local mission_base is mission(mission_definition@).
function mission_definition {
  parameter seq, ev, next.
  SET pT TO AVAILABLETHRUST.
  ev:add("Power", ship_utils["power"]).
  SET thrott to 0.

function pre_launch {
  ev:remove("Power"). ship_utils["disable"]().
  set ship:control:pilotmainthrottle to 0.
  next().
}
function launch {
  local dir to lazcalc["LAZ"](p["L"]["Alt"], p["L"]["Inc"]).
  lock steering to heading(dir, 89).
  if notfalse(p["L"]["LAN"]) {
    print "waiting for Launch window.".
    local lan_t to lazcalc["window"](p["T"]["Target"]).
    warpto(lan_t).
    wait until time:seconds >= lan_t.
  }
  stage.
  SET TPID TO PIDLOOP(0.01, 0.006, 0.006, 0, 1).
  SET TPID:SETPOINT TO p["L"]["Alt"].
  if ship:body:atm:exists and notfalse(p["L"]["MAXQ"]) {
    print "MaxQ: " + p["L"]["MAXQ"].
    SET QPID TO PIDLOOP(0.1, 0.01, 0.01, 0, 1).
    SET QPID:SETPOINT TO p["L"]["MAXQ"].
    lock thrott to min(
      TPID:UPDATE(TIME:SECONDS, APOAPSIS),
      QPID:UPDATE(TIME:SECONDS, SHIP:Q * constant:ATMtokPa)
    ).
  } else {
    lock thrott to TPID:UPDATE(TIME:SECONDS, APOAPSIS).
  }
  lock throttle to thrott.
  wait until ship:velocity:surface:mag > 100.
  lock pct_alt to (alt:radar / p["L"]["Alt"]).
  lock target_pitch to 90 - (90* pct_alt^p["L"]["PitchExp"]).
  lock steering to heading(dir, target_pitch).
  if not ev:haskey("AutoStage") and p["L"]["AStage"] ev:add("AutoStage", ship_utils["auto_stage"]).
  next().
}
function coast_to_atm {
  if alt:radar > body:atm:height {
    set warp to 0. lock throttle to 0.
    if ev:haskey("AutoStage") ev:remove("AutoStage").
    wait 2. stage. wait 1. panels on.
    if not ev:haskey("Power") and p["O"]["Power"]
      ev:add("Power", ship_utils["power"]).
    next().
  }
}
function circularize_ap {
  local sma to ship:obt:SEMIMAJORAXIS. local ecc to ship:obt:ECCENTRICITY.
  if hasnode node_exec["exec"](true).
  else if (ecc < 0.0015) or (600000 > sma and ecc < 0.005) next().
  else node_exec["circularize"]().
}
function set_launch_inc_lan {
  if round(ship:obt:inclination,1) = p["L"]["Inc"] {
    next().
  } else {
    if notfalse(p["L"]["LAN"]) node_set_inc_lan["create_node"](p["L"]["Inc"],p["L"]["LAN"]).
    else node_set_inc_lan["create_node"](p["L"]["Inc"]).
    node_exec["exec"](true).
  }
}
function hohmann_transfer_target {
  local r1 to SHIP:OBT:SEMIMAJORAXIS.
  local r2 to p["O"]["Alt"] + SHIP:OBT:BODY:RADIUS.
  local d_time to eta:periapsis.
  if notfalse(p["T"]["Target"]) {
    set r2 TO p["T"]["Target"]:obt:semimajoraxis.
    print "Hohmann Transfer to Vessel: " + p["T"]["Target"] + " Offset: " + p["T"]["Offset"].
    set d_time to hohmann["time"](r1,r2, p["T"]["Target"],p["T"]["Offset"]).
  }
  lock steering to lookdirup(v(0,1,0), sun:position).
  hohmann["transfer"](r1,r2,d_time).
  local nn to nextnode.
  local data to list(time:seconds + nn:eta, nn:radialout, nn:normal, nn:prograde).
  if p["T"]["Target"]:istype("body") {
    for step in list(10,1,0.1) {set data to hc["seek"](data, transfit["trans_fit"](p["T"]["Target"], p["T"]["Inc"], p["T"]["Alt"]), step).}
  } else {
    for step in list(10,1,0.1) {set data to hc["seek"](data, transfit["rndvz_fit"](p["T"]["Target"]), step).}
  }
  node_exec["exec"](true).
  next().
}
function rendezvous {
  until p["T"]["Target"]:distance < 500 {
    rndz["cancel"](p["T"]["Target"]).
    rndz["approach"](p["T"]["Target"], 30).
    rndz["await_nearest"](p["T"]["Target"], 500).
  }
  rndz["cancel"](p["T"]["Target"]).
  next().
}
function dock_with_ship {
  RCS ON.
  lock rv TO ship:velocity:orbit - target:velocity:orbit.
  until rv:mag < 0.01 {
    dock["translate"](-1 * rv).
  }
  dock["translate"](V(0,0,0)).

  local tgt TO VESSEL("SkyLab - Core").
  local dp to ship:dockingports[0].
  dp:CONTROLFROM.
  local tp to get_port(tgt).

  dock["sideswipe"](tp, dp, 100, 1).
  dock["approach"](tp, dp, 100, 1).
  dock["approach"](tp, dp, 50, 1).
  dock["approach"](tp, dp, 20, 1).
  dock["approach"](tp, dp, 10, 0.5).
  dock["approach"](tp, dp, 0, 0.5).
  RCS OFF.
  next().
}
function finish {
  ship_utils["enable"]().
  deletepath("startup.ks").
  if notfalse(p["NextShip"]) {
    local template to KUniverse:GETCRAFT(p["NextShip"], "VAB"). KUniverse:LAUNCHCRAFT(template).
  } else if notfalse(p["SwitchToShp"]) { set KUniverse:ACTIVEVESSEL to p["SwitchToShp"].}
  reboot.
}
  seq:add(pre_launch@).
  seq:add(launch@).
  seq:add(coast_to_atm@).
  seq:add(circularize_ap@).
  seq:add(set_launch_inc_lan@).
  seq:add(hohmann_transfer_target@).
  seq:add(circularize_ap@).
  seq:add(rendezvous@).
  seq:add(dock_with_ship@).
  seq:add(finish@).
}
export(mission_base).