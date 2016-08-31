function atmospheric_reentry {
  parameter mission.
  parameter params.

  lock steering to srfretrograde.

  if Altitude < SHIP:BODY:ATM:HEIGHT {
    until stage:number = 0 {
      if STAGE:READY {
        WAIT 1. STAGE. WAIT 1.
      } else {
        wait 1.
      }
    }
    mission["remove_event"]("Power Check").
    disable_antennas().
    wait 5.
  } else {
    mission["add_event"]("Power Check", ensure_power@).
    wait 5.
  }
  if (NOT CHUTESSAFE) {
    CHUTESSAFE ON.
  } else if chutes {
    mission["next"]().
  }
}

local landing_phase is 0.
function deorbit_to_position {
  parameter mission.
  parameter params.
  if params:haskey("LandAt")
    set coordinates to params["LandAt"].
  else
    set coordinates to latlng(0,0).

  if hasnode {
    execute_node_raw(mission, params).
    if not hasnode
      set landing_phase to landing_phase +1.
  } else if landing_phase = 0 {
    print "Adjusting orbit to fly over target".
    local node_lng to mod(360+Body:ROTATIONANGLE+coordinates:LNG,360).
    set_inc_lan_raw(coordinates:Lat,node_lng-90).
    local my_node to NEXTNODE.
    local t_wait_burn to my_node:ETA + OBT:PERIOD/4.
    local rot_angle to t_wait_burn*360/Body:ROTATIONPERIOD.
    remove my_node.
    set_inc_lan_raw(coordinates:Lat,node_lng-90+rot_angle).
  } else if landing_phase = 1 {
    print "Setting Up DeOrbit Burn".

    local node_lng to mod(360+Body:ROTATIONANGLE+coordinates:LNG,360).

    set_inc_lan_raw(coordinates:LAT,node_lng-90).
    local my_node to NEXTNODE.
    // change node_eta to adjust for rotation:
    local t_wait_burn to my_node:ETA + OBT:PERIOD/4.

    local rot_angle to t_wait_burn*360/Body:ROTATIONPERIOD.
    remove my_node.
    set_inc_lan_raw(coordinates:LAT,node_lng-90+rot_angle).
    remove nextnode.

    local ship_ref to mod(obt:lan+obt:argumentofperiapsis+obt:trueanomaly,360).
    local ship_2_node to mod((720 + node_lng+rot_angle - ship_ref),360).
    local node_eta to ship_2_node*OBT:PERIOD/360.

    local my_node to NODE(time:seconds + node_eta,0,0,-SHIP:VELOCITY:SURFACE:MAG).
    ADD my_node.

    local tti to timeToImpact(true)[1] - (time:seconds + my_node:eta).
    remove my_node.
    local p2 to SHIP:BODY:GEOPOSITIONOF(POSITIONAT(SHIP,tti)).
    local distance to circle_distance(coordinates, p2, body:radius).
    local old_distance to constant:pi() * 2 * body:radius.

    local my_node to NODE(time:seconds + node_eta,0,0,-SHIP:VELOCITY:SURFACE:MAG).
    ADD my_node.

  } else if landing_phase > 1 {
    print "Finished with DeOrbit Burn".
    set landing_phase to 0.
    mission["next"]().
  }
  wait 0.1.
}

set suice_burn_setup to false.
function suicide_burn {
  parameter mission.
  parameter params.

  if not suice_burn_setup {
    lock steering to srfretrograde.
    SET thrott TO 0.
    LOCK THROTTLE TO thrott.
    set PID to PIDLOOP(0.1, 0.06, 0.06, 0, 1).
    set PID:SETPOING to -0.5.
    set suice_burn_setup to true.
  } else if time_to_impact(1) <= MNV_TIME(-ship:verticalspeed) {
    set warp to 0.
    print "Starting Burn".
    until ship:status = "Landed" {
      SET GEAR TO ALT:RADAR<1000.
      SET LIGHTS TO GEAR.
      set thrott to pid:update(time:seconds, SHIP:VERTICALSPEED).
    }
    LOCK THROTTLE to 0.
    set suice_burn_setup to false.
    mission["next"]().
  }
}
