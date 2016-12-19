{
  local p is import("lib/params.ks").
  local node_exec is import("lib/node_exec.ks").
  local node_set_inc_lan is import("lib/node_set_inc_lan.ks").
  local hc is import("lib/hillclimb.ks").
  local fit is import("lib/fitness_land.ks").
  local landing to lex(
    "FlyOverTarget", fly_over_target@,
    "DeorbitNode", deorbit_node@
  ).
  function fly_over_target {
    print "Adjusting Inclination and Lan to fly over target".
    local node_lng to mod(360+Body:ROTATIONANGLE+p["LND"]["LatLng"]:LNG,360).
    node_set_inc_lan["create_node"](p["LND"]["LatLng"]:LAT, node_lng-90).
    local n to NEXTNODE.
    local t_wait_burn to n:ETA + OBT:PERIOD/4.
    local rot_angle to t_wait_burn*360/Body:ROTATIONPERIOD.
    remove n.
    node_set_inc_lan["create_node"](p["LND"]["LatLng"]:LAT, node_lng-90+rot_angle).
    node_exec["exec"](true).
  }
  function deorbit_node {
    addons:tr:settarget(p["LND"]["LatLng"]).
    local mnv_time to TIME:SECONDS + ship:orbit:period/4.
    local mnv_dv to -ship:velocity:orbit:mag/10.
    local n to node(mnv_time,0,0,mnv_dv).
    add n.
    wait 1.
    local data to list(mnv_time).
    print "refining manuver time by 60".
    set data to hc["seek"](data, fit["deorbit_fit"](p["LND"]["LatLng"],mnv_dv), 60).
    print "refining manuver time by 10".
    set data to hc["seek"](data, fit["deorbit_fit"](p["LND"]["LatLng"],mnv_dv), 10).
    print "refining manuver time by 1".
    set data to hc["seek"](data, fit["deorbit_fit"](p["LND"]["LatLng"],mnv_dv), 1).
    node_exec["exec"](true).
  }
  export(landing).
}
// print circle_distance(latlng(20,-110),ADDONS:TR:IMPACTPOS,ship:body:radius).
