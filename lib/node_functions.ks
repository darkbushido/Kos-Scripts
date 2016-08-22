SET LG to CONSTANT:G * (ship:body:mass / ship:body:radius ^2).
SET startTime TO 0.
set last_dv TO 0.
set oldwp to 0.
set oldwarp to warp.
set message to "".
set oldmessage to "".
function execute_node {
  parameter mission.
  parameter params.

  execute_node_raw(mission, params).
  if not hasnode
    mission["next"]().
}
function execute_node_raw {
  parameter mission.
  parameter params.

  if params:haskey("Auto Stage")
    mission["add_event"]("Auto Stage", auto_stage@).

  set ts to TIME:SECONDS.

  if params:haskey("Warp")
    set activate_warp to params["Warp"].
  else
    set activate_warp to false.

  local nn to NEXTNODE.
  if  startTime = 0 {
    set nndv to nn:DELTAV.
    local mnv_t to MNV_TIME(nndv:MAG).
    if stage_delta_v() > nndv:MAG {
      print "we have enough dV".
      SET startTime TO round(ts + nn:ETA - mnv_t/2,1).
    } else {
      local dvf to 1 + (stage_delta_v() / nndv:MAG).
      print "stage does not have enough dV " + dvf.
      SET startTime TO round(ts + nn:ETA - ((mnv_t *dvf)/2) , 1).
    }
    LOCK STEERING TO nn:DELTAV.
  }

  if ts >= startTime {
    LOCK THROTTLE TO MAX(MIN(nn:DELTAV:MAG/10, 1),0).
  } else  if VANG(SHIP:FACING:VECTOR, nn:BURNVECTOR) > 2 {
    set message to "Waiting to Align, Alignment Error: " + ROUND(VANG(SHIP:FACING:VECTOR, nn:BURNVECTOR), 2).
    if activate_warp = true {
      set warp to 0.
      set oldwarp to warp.
    }
    wait 1.
  } else if ts < startTime - 30 {
    if activate_warp = true {
      local rt to (startTime - 30) - ts.
      local wp to 0.
      if rt > 100000 { set wp to 7. }
      else if rt > 10000  { set wp to 6. }
      else if rt > 1000   { set wp to 5. }
      else if rt > 100    { set wp to 4. }
      else if rt > 50     { set wp to 3. }
      else if rt > 10     { set wp to 2. }
      else if rt > 5      { set wp to 1. }
      if wp <> oldwp OR warp <> wp {
        set warp to wp.
        wait 0.1.
        set oldwp to wp.
        set oldwarp to warp.
      }
      wait 0.1.
    } else { wait 5.}
  }

  if vdot(nn:burnvector, nndv) < 0.1 {
    LOCK THROTTLE TO 0.
    UNLOCK STEERING.
    REMOVE nn.
    mission["remove_event"]("Auto Stage").
    SET startTime TO 0.
    SET SHIP:CONTROL:PILOTMAINTHROTTLE TO 0.
  }
}

function manuver_alt_verification {
  parameter mission.
  parameter params.

  LOCK STEERING TO RETROGRADE.

  if params:haskey("Body")
    local target_body to params["Body"].
  else
    local target_body to Mun.
  if params:haskey("Delay")
    local node_delay to params["Delay"].
  else
    local node_delay to 300.
  if params:haskey("Altitude")
    local target_alt is params["Altitude"].
  else
    local target_alt is 35000.
  if params:haskey("Direction")
    local d to params["Direction"].
  else
    local d to "Out".

  if not ship:obt:hasnextpatch {
    set nn to NODE(time:seconds + 600, 0, 0, 1).
    add nn.

    until nn:obt:hasnextpatch {
      print nn:PROGRADE + " " + APOAPSIS.
      if APOAPSIS < target_body:altitude {
        set nn:PROGRADE to nn:PROGRADE + 0.01.
      } else {
        set nn:PROGRADE to nn:PROGRADE - 0.01.
      }
    }
  }

  if ship:obt:hasnextpatch {
    set manuver_time to ship:obt:nextpatcheta + 60.
    if not HASNODE {
      set nn to NODE(time:seconds + (manuver_time/4)*3, 0, 0, 1).
      add nn.
    }

    local lock current_alt to ORBITAT(SHIP,time+manuver_time):PERIAPSIS.

    until abs (current_alt - target_alt) < 1000 {
      print nn:PROGRADE + " " + current_alt.
      if current_alt < target_alt {
        set nn:PROGRADE to nn:PROGRADE + 0.01.
      } else {
        set nn:PROGRADE to nn:PROGRADE - 0.01.
      }
    }
  }

  mission["next"]().
}

function circularization {
  parameter mission.
  parameter params.

  if HASNODE {
    execute_node_raw(mission, params).
  } else if ship:obt:SEMIMAJORAXIS > 100000 and ship:obt:ECCENTRICITY < 0.001 {
    mission["next"]().
  } else if ship:obt:SEMIMAJORAXIS > 50000 and ship:obt:ECCENTRICITY < 0.005 {
    mission["next"]().
  } else {
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
  }
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
