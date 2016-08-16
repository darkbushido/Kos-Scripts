SET LG to CONSTANT:G * (ship:body:mass / ship:body:radius ^2).
SET startTime TO 0.
set last_dv TO 0.
function execute_node {
  parameter mission.
  parameter params.

  set ts to TIME:SECONDS.

  local nn to NEXTNODE.
  if  startTime = 0 {
    set nndv to nn:DELTAV.
    local mnv_t to MNV_TIME(nndv:MAG).
    if stage_delta_v() > nndv:MAG {
      print "we have enough dV".
      SET startTime TO round(ts + nn:ETA - mnv_t/2,1).
    } else {
      print "stage does not have enough dV".
      SET startTime TO round(ts + nn:ETA - mnv_t*1.5, 1).
    }
    LOCK STEERING TO NEXTNODE:DELTAV.
  }

  if ts >= startTime {
    LOCK THROTTLE TO MAX(MIN(nn:DELTAV:MAG/20, 1),0).
  } else if abs(nndv:DIRECTION:pitch - facing:pitch) > 0.1
    OR abs(nndv:DIRECTION:yaw - facing:yaw) > 0.1 {
    wait 1.
  } else if ts < startTime - 10 {
    wait 5.
  }

  if vdot(nn:burnvector, nndv) < 0.1 {
    LOCK THROTTLE TO 0.
    UNLOCK STEERING.
    REMOVE nn.
    SET startTime TO 0.
    SET SHIP:CONTROL:PILOTMAINTHROTTLE TO 0.
    mission["next"]().
  }
}

function circularization {
  parameter mission.
  parameter params.

  if NOT params:HASKEY("Mode")
    params:ADD("Mode", "apoapsis").
  LOCAL co TO ship:orbit.
  LOCAL cobr to co:body:radius.
  if params["Mode"] = "apoapsis" {
    set cot to co:apoapsis.
    set ttb to ETA:APOAPSIS.
  } else if params["Mode"] = "pariapsis" {
    set cot to co:periapsis.
    set ttb to ETA:PERIAPSIS.
  }
  LOCAL cotcobr to (cot + cobr).
  LOCAL deltaV to 0.
  LOCAL vat TO sqrt(co:body:mu * (2 / cotcobr - 1 / (co:semimajoraxis))).
  LOCAL cv TO sqrt(co:body:mu * (1 / cotcobr)).
  ADD NODE(TIME:SECONDS + ttb, 0, 0, cv - vat).
  mission["next"]().
}



function set_inc_lan {
  // Curtasy of https://www.reddit.com/user/G_Space
  // https://www.reddit.com/r/Kos/comments/3r5pbj/set_inclination_from_orbit_script/
  parameter mission.
  parameter params.

  if params:HASKEY("Inc")
    set incl_t to params["Inc"].
  else
    set incl_t to 0.

  if params:HASKEY("LAN")
    set lan_t to params["LAN"].
  else
    set lan_t to SHIP:OBT:LAN.

  local incl_i to SHIP:OBT:INCLINATION.
  local lan_i to SHIP:OBT:LAN.

// setup the vectors to highest latitude; Transform spherical to cubic coordinates.
  local Va to V(sin(incl_i)*cos(lan_i+90),sin(incl_i)*sin(lan_i+90),cos(incl_i)).
  local Vb to V(sin(incl_t)*cos(lan_t+90),sin(incl_t)*sin(lan_t+90),cos(incl_t)).
// important to use the reverse order
  local Vc to VCRS(Vb,Va).

  local dv_factor to 1.
  //compute burn_point and set to the range of [0,360]
  local node_lng to mod(arctan2(Vc:Y,Vc:X)+360,360).
  local ship_ref to mod(obt:lan+obt:argumentofperiapsis+obt:trueanomaly,360).

  local ship_2_node to mod((720 + node_lng - ship_ref),360).
  if ship_2_node > 180 {
      print "Switching to DN".
      set dv_factor to -1.
      set node_lng to mod(node_lng + 180,360).
  }

  local node_true_anom to 360- mod(720 + (obt:lan + obt:argumentofperiapsis) - node_lng , 360 ).
  local ecc to OBT:ECCENTRICITY.
  local mr to OBT:SEMIMAJORAXIS * (( 1 - ecc^2)/ (1 + ecc*cos(node_true_anom)) ).
  local node_eta to eta_true_anom(node_lng).
  local ms to VELOCITYAT(SHIP, time+node_eta):ORBIT:MAG.
  local d_inc to arccos (vdot(Vb,Va) ).
  local dvtgt to dv_factor* (2 * (ms) * SIN(d_inc/2)).

  local inc_node to NODE(node_eta, 0, dvtgt * cos(d_inc/2), 0 - abs(dvtgt * sin(d_inc/2))).
  ADD inc_node.
  mission["next"]().
}

function eta_true_anom {
  declare local parameter tgt_lng.
  local ship_ref to mod(obt:lan+obt:argumentofperiapsis+obt:trueanomaly,360).
  local node_true_anom to (mod (720+ tgt_lng - (obt:lan + obt:argumentofperiapsis),360)).
  local node_eta to 0.
  local ecc to OBT:ECCENTRICITY.
  if ecc < 0.001 {
    set node_eta to SHIP:OBT:PERIOD * ((mod(tgt_lng - ship_ref + 360,360))) / 360.
  } else {
    local eccentric_anomaly to  arccos((ecc + cos(node_true_anom)) / (1 + ecc * cos(node_true_anom))).
    local mean_anom to (eccentric_anomaly - ((180 / (constant():pi)) * (ecc * sin(eccentric_anomaly)))).
    local time_2_anom to  SHIP:OBT:PERIOD * mean_anom /360.
    local my_time_in_orbit to ((OBT:MEANANOMALYATEPOCH)*OBT:PERIOD /360).
    set node_eta to mod(OBT:PERIOD + time_2_anom - my_time_in_orbit,OBT:PERIOD) .
  }
  return TIME:SECONDS + node_eta.
}

function remove_any_nodes {
  until not hasnode {
    remove nextnode. wait 0.01.
  }
}
