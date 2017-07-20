{
  local p is import("lib/params.ks").
  local cn is import("lib/circle_nav.ks").
  local node_exec is import("lib/node_exec.ks").
  local node_set_inc_lan is import("lib/node_set_inc_lan.ks").
  local hc is import("lib/hillclimb.ks").
  local landfit is import("lib/fitness_land.ks").
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
  }
  function deorbit {
    addons:tr:settarget(p["LND"]["LatLng"]).
    if ship:body:atm:exists
      set landing_per_buffer to p["LND"]["RAlt"].
    else
      set landing_per_buffer to 2000.
    set R_per_landing to ship:body:radius + max(4500,p["LND"]["LatLng"]:terrainheight + landing_per_buffer).
    set SMA_landing to (R_ship():mag + R_per_landing)/2.
    set ecc_landing to (R_ship():mag - R_per_landing)/(R_ship():mag + R_per_landing).
    set V_apo to sqrt(((1-ecc_landing)*ship:body:MU)/((1+ecc_landing)*SMA_landing)).
    set TimePeriod_landing to 2*(constant:pi)*sqrt((SMA_landing^3)/(ship:body:mu)).
    set prev_dist_h to dist_diff_h().
    wait 0.1.
    set curr_dist_h to dist_diff_h().
    set delta_dist_h to curr_dist_h - prev_dist_h.
    if delta_dist_h > 0 {
      set eta_node to (TimePeriod_landing/2*position_speed_h())/speed_diff_h() + ((constant:pi)*R_ship():mag-dist_diff_h())/speed_diff_h().
        if eta_node < 60 {
          set eta_node to (TimePeriod_landing/2*position_speed_h())/speed_diff_h() + ((constant:pi)*R_ship():mag-dist_diff_h()+(constant:pi)*R_ship():mag)/speed_diff_h().
        }
    } else {
      set eta_node to (TimePeriod_landing/2*position_speed_h())/speed_diff_h() + ((constant:pi)*R_ship():mag+dist_diff_h())/speed_diff_h().
    }
    set deltaV to V_apo - velocityat(ship,time:seconds + eta_node):orbit:mag.
    local data to list(round(TIME:seconds + eta_node,2), 0, 0, deltaV).
    if ship:body:atm:exists {
      node_exec["make"](data).
      local wait_t to TIME:seconds + 5.
      wait until TIME:seconds > wait_t OR addons:tr:hasImpact.
      local dist to round(cn["distance"](addons:tr:impactpos, p["LND"]["LatLng"], ship:body:radius),2).
      local circ to ship:body:radius * constant():PI *2.
      local diff to dist/circ.
      local offset to ship:obt:period * diff * 1.1.
      set data[0] to data[0] + offset * 1.05.
      node_exec["clean"](). node_exec["make"](data).
      local wait_t to TIME:seconds + 5.
      wait until TIME:seconds > wait_t OR addons:tr:hasImpact.
      local dist2 to round(cn["distance"](addons:tr:impactpos, p["LND"]["LatLng"], ship:body:radius),2).
      if dist2 > dist {
        print "Overshoot, Trying the other way".
        set data[0] to data[0] - offset * 2.
        node_exec["clean"](). node_exec["make"](data).
      }
    } else {
      for step in list(10,1,0.1) {set data to hc["seek"](data, landfit["deorbit_fit"](p["LND"]["LatLng"]), step).}
    }
    node_exec["exec"](true).
  }
  function g0 { return ship:body:mu/(ship:body:radius)^2. }
  function TWR { return availablethrust/(mass*g0()). }
  function landing_pos { return latlng(p["LND"]["LatLng"]:lat,p["LND"]["LatLng"]:lng). }
  function R_ship { return ship:body:position. }
  function GravUP { return (-1)*(ship:body:mu)/((R:mag)^2).}
  function angle_diff_h { return VANG(-R_ship(), landing_pos():position - R_ship()). }
  function dist_diff_h { return (angle_diff_h()/360) * 2 * constant:pi()*R_ship():mag. }
  function velocity_h_norm { return VCRS(VCRS(R_ship(),ship:velocity:orbit),R_ship()):normalized. }
  function speed_h { return VDOT(velocity_h_norm(),ship:velocity:orbit). }
  function speed_diff_h { return speed_h()-landing_pos():altitudevelocity(altitude):orbit:mag. }
  function long_diff_dir { return VCRS(landing_pos():position,R_ship()):normalized. }
  function long_diff_h { return VDOT(long_diff_dir(),ship:velocity:surface). }
  function position_speed_h { return landing_pos():altitudevelocity(altitude):orbit:mag. }
  function Velocity_diff_direction { return (-1*(ship:velocity:orbit - landing_pos():altitudevelocity(altitude):orbit + long_diff_h()*long_diff_dir())):direction. }
  function MaxThrustAccHor { return -1*VDOT(Velocity_h_norm(),availablethrust/mass*srfretrograde:vector). }
  function truealt { return altitude - landing_pos:terrainheight. }
  function touchdown_time { return (-verticalspeed - sqrt(verticalspeed^2 - 4*(-0.5*g0())*truealt()))/(-1*g0()). }
  function cutoffdist_h { return speed_diff_h()*touchdown_time(). }
  function Vmax_h { return sqrt(MAX(0,2*(dist_diff_h)*MaxThrustAccHor)). }
  function error_h { return Vmax_h() - speed_diff_h(). }

  export(landing).
}
