{
  local p is import("lib/params.ks").
  local node_exec is import("lib/node_exec.ks").
  local node_set_inc_lan is import("lib/node_set_inc_lan.ks").
  local hc is import("lib/hillclimb.ks").
  local fit is import("lib/fitness_land.ks").
  local landing to lex(
    "FlyOverTarget", fly_over_target@,
    "DeorbitNode", deorbit@
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
    if nextnode:deltav:mag > 1 { node_exec["exec"](true). }
    else { remove nextnode.}
    print "Creating deorbit node".
    local ship_ref to mod(obt:lan+obt:argumentofperiapsis+obt:trueanomaly,360).
    local ship_2_node to mod((720 + node_lng+rot_angle - ship_ref),360).
    local node_eta to ship_2_node*OBT:PERIOD/360.
    local dv to -SHIP:VELOCITY:SURFACE:MAG/2.
    if BODY:ATM:EXISTS { set dv to dv/10. }
    if node_eta < OBT:PERIOD/8 { set node_eta to node_eta + OBT:PERIOD.}
    local nd to NODE(time:seconds + node_eta,0,0,dv).
    ADD nd.
  }
  function deorbit {
    addons:tr:settarget(p["LND"]["LatLng"]).
    if not HASNODE { add node(time:seconds + OBT:PERIOD,0,0,-SHIP:VELOCITY:SURFACE:MAG/2). }
    local nd to NEXTNODE.
    local data to list(time:seconds + nd:eta, nd:radialout, nd:normal, nd:prograde).
    print "refining manuver time by 10".
    set data to hc["seek"](data, fit["deorbit_fit"](p["LND"]["LatLng"]), 10).
    print "refining manuver time by 1".
    set data to hc["seek"](data, fit["deorbit_fit"](p["LND"]["LatLng"]), 1).
    node_exec["exec"](true).
  }
  export(landing).
}
