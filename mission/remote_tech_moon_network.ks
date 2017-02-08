local mission is import("lib/mission.ks").
local ship_utils is import("lib/ship_utils.ks").
local p is import("lib/params.ks").
local node_exec is import("lib/node_exec.ks").
local node_set_inc_lan is import("lib/node_set_inc_lan.ks").
local hohmann is import("lib/hohmann_transfer.ks").
local hc is import("lib/hillclimb.ks").
local orbitfit is import("lib/fitness_orbit.ks").
print "Mission Params".
print p.
list files.
local mission_base is mission(mission_definition@).
function mission_definition {
  parameter seq, ev, next.
  SET pT TO AVAILABLETHRUST.
  ev:add("Power", ship_utils["power"]).
  SET thrott to 0.

function wait_until_only_core {
  LIST PROCESSORS IN ALL_PROCESSORS.
  if ALL_PROCESSORS:length = 1 {
    if notfalse(p["RenameShip"]) {
      set ship:name to p["RenameShip"].
    }
    next().
  } else {
    ev:remove("Power").
    print "Waiting until only Core". wait 30.
  }
}
function wait_until_active_vessel {
  if ship:name = KUniverse:ACTIVEVESSEL:name {
    if notfalse(p["RenameShip"]) {
      set ship:name to p["RenameShip"].
    }
    next().
  } else {
    ev:remove("Power").
    print "Waiting until Active Vessel". wait 30.
  }
}
function set_orbit_inc_lan {
  if p["O"]["CareAboutLan"] node_set_inc_lan["create_node"](p["O"]["Inc"],p["L"]["LAN"]).
  else node_set_inc_lan["create_node"](p["O"]["Inc"]).
  local nn to nextnode.
  if nn:deltav:mag < 0.1 remove nn.
  else node_exec["exec"](true).
  next().
}
function circularize_ap {
  local sma to ship:obt:SEMIMAJORAXIS. local ecc to ship:obt:ECCENTRICITY.
  if hasnode node_exec["exec"](true).
  else if (ecc < 0.0015) or (600000 > sma and ecc < 0.005) next().
  else node_exec["circularize"]().
}
function hohmann_transfer {
  local r1 to SHIP:OBT:SEMIMAJORAXIS. local r2 TO p["O"]["Alt"] + SHIP:OBT:BODY:RADIUS.
  local d_time to eta:periapsis.
  if notfalse(p["O"]["Vessel"]) set d_time to hohmann["time"](r1,r2, p["O"]["Vessel"],p["O"]["Offset"]).
  hohmann["transfer"](r1,r2,d_time). local nn to nextnode.
  local t to time:seconds + nn:eta. local data is list(nn:prograde).
  print "Hillclimbing".
  set data to hc["seek"](data, orbitfit["apo_fit"](t, p["O"]["Alt"]), 0.1).
  set data to hc["seek"](data, orbitfit["apo_fit"](t, p["O"]["Alt"]), 0.01).
  node_exec["exec"](true). next().
}
function finish {
  ship_utils["enable"]().
  deletepath("startup.ks").
  if notfalse(p["NextShip"]) {
    local template to KUniverse:GETCRAFT(p["NextShip"], "VAB"). KUniverse:LAUNCHCRAFT(template).
  } else if notfalse(p["SwitchToShp"]) { set KUniverse:ACTIVEVESSEL to p["SwitchToShp"].}
  reboot.
}
  seq:add(wait_until_only_core@).
  seq:add(wait_until_active_vessel@).
  seq:add(set_orbit_inc_lan@).
  seq:add(set_orbit_inc_lan@).
  seq:add(circularize_ap@).
  seq:add(hohmann_transfer@).
  seq:add(circularize_ap@).
  seq:add(finish@).
}
export(mission_base).
