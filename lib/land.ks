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
    local r1 to SHIP:OBT:SEMIMAJORAXIS.
    local r2 TO SHIP:OBT:BODY:RADIUS.
    local transfer_time to constant():pi * sqrt((((r1 + r2)^3)/(8*ship:BODY:MU))).
    local phase_angle to (180*(1-(sqrt(((r1 + r2)/(2*r2))^3)))).
    local actual_angle to mod(360 + (coordinates:LNG) - SHIP:LONGITUDE,360) .
    local d_angle to (mod(360 + actual_angle - phase_angle,360)).
    local ship_ang to  360/SHIP:OBT:PERIOD.
    local tgt_ang to  360/SHIP:BODY:ROTATIONPERIOD.
    local d_ang to ship_ang - tgt_ang.
    local d_time to d_angle/d_ang.
    // local my_dV to sqrt (ship:BODY:MU/r1) * (sqrt((2* r2)/(r1 + r2)) - 1).
    local my_dV to -SHIP:VELOCITY:SURFACE:MAG.
    local nn TO NODE(time:seconds+d_time, 0, 0, my_dV).
    ADD nn.
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
