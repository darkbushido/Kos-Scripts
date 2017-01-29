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
    set landing_pos to p["LND"]["LatLng"].
    set g0 to ship:body:mu/(ship:body:radius)^2.
    set TWR to availablethrust/(mass*g0).
    set Fuel_Factor to 1.25.
    set landing_per_buffer to (50290*(TWR*Fuel_Factor)^(-2.232) + 222.1)*(0.955)^(landing_pos:terrainheight/2500).
    lock R_ship to ship:body:position.
    lock angle_diff_h to VANG(-R_ship, landing_pos:position - R_ship).
    lock dist_diff_h to (angle_diff_h/360)*2*(constant:pi)*R_ship:mag.
    lock Velocity_h_norm to VCRS(VCRS(R_ship,ship:velocity:orbit),R_ship):normalized.
    lock Speed_h to VDOT(Velocity_h_norm,ship:velocity:orbit).
    lock position_speed_h to landing_pos:altitudevelocity(altitude):orbit:mag.
    lock speed_diff_h to Speed_h-position_speed_h.
    set R_per_landing to ship:body:radius + max(4500,landing_pos:terrainheight + landing_per_buffer).
    set SMA_landing to (R_ship:mag + R_per_landing)/2.
    set ecc_landing to (R_ship:mag - R_per_landing)/(R_ship:mag + R_per_landing).
    set V_apo to sqrt(((1-ecc_landing)*ship:body:MU)/((1+ecc_landing)*SMA_landing)).
    set TimePeriod_landing to 2*(constant:pi)*sqrt((SMA_landing^3)/(ship:body:mu)).
    set prev_dist_h to dist_diff_h.
    wait 0.1.
    set curr_dist_h to dist_diff_h.
    set delta_dist_h to curr_dist_h - prev_dist_h.
    if delta_dist_h > 0 {
      set eta_node to (TimePeriod_landing/2*position_speed_h)/speed_diff_h + ((constant:pi)*R_ship:mag-dist_diff_h)/speed_diff_h.
        if eta_node < 60 {
          set eta_node to (TimePeriod_landing/2*position_speed_h)/speed_diff_h + ((constant:pi)*R_ship:mag-dist_diff_h+(constant:pi)*R_ship:mag)/speed_diff_h.
        }
    } else {
      set eta_node to (TimePeriod_landing/2*position_speed_h)/speed_diff_h + ((constant:pi)*R_ship:mag+dist_diff_h)/speed_diff_h.
    }
    set deltaV_landing to V_apo - velocityat(ship,time:seconds + eta_node):orbit:mag.

    // if not HASNODE { add node(time:seconds + OBT:PERIOD,0,0,-SHIP:VELOCITY:SURFACE:MAG/2). }
    // local nd to NEXTNODE.
    // local data to list(time:seconds + nd:eta, nd:radialout, nd:normal, nd:prograde).
    // print "refining manuver time by 10".
    // set data to hc["seek"](data, fit["deorbit_fit"](p["LND"]["LatLng"]), 10).
    // print "refining manuver time by 1".
    // set data to hc["seek"](data, fit["deorbit_fit"](p["LND"]["LatLng"]), 1).
    node_exec["exec"](true).
  }
  export(landing).
}
