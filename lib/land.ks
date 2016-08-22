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
function land_at_position{
  parameter mission.
  parameter params.

  if params:haskey("Lat")
    set lat to params["Lat"].
  else
    set lat to 0.

  if params:haskey("Lng")
    set lng to params["Lng"].
  else
    set lng to 0.


	local coordinates to latlng(lat,lng).
	stop_at(coordinates).
	do_suecide_burn(coordinates).
	local d_target to round((SHIP:GEOPOSITION:POSITION - coordinates:POSITION):MAG,1).
	print "We landed "+d_target +" m from our target".
}

function stop_at{
	parameter spot.

	local node_lng to mod(360+Body:ROTATIONANGLE+spot:LNG,360).

	set_inc_lan_i(spot:LAT,node_lng-90,false).
	local my_node to NEXTNODE.
	// change node_eta to adjust for rotation:
	local t_wait_burn to my_node:ETA + OBT:PERIOD/4.

	local rot_angle to t_wait_burn*360/Body:ROTATIONPERIOD.
	remove my_node.
	set_inc_lan_i(spot:LAT,node_lng-90+rot_angle,false).
	run_node().

	local ship_ref to mod(obt:lan+obt:argumentofperiapsis+obt:trueanomaly,360).
	local ship_2_node to mod((720 + node_lng+rot_angle - ship_ref),360).
	local node_eta to ship_2_node*OBT:PERIOD/360.
	local my_node to NODE(time:seconds + node_eta,0,0,-SHIP:VELOCITY:SURFACE:MAG).
	ADD my_node.

	run_stopping_node(spot).
}
