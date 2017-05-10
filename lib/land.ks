{
  local p is import("lib/params.ks").
  local node_exec is import("lib/node_exec.ks").
  local node_set_inc_lan is import("lib/node_set_inc_lan.ks").
  local hc is import("lib/hillclimb.ks").
  local landfit is import("lib/fitness_land.ks").
  local landing to lex(
    "FlyOverTarget", fly_over_target@,
    "DeorbitNode", deorbit@,
    "OnTarget", on_target@
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
    local data to list(time:seconds + node_eta,0,0,dv).
    for step in list(10,1,0.1) {set data to hc["seek"](data, landfit["deorbit_fit"](p["LND"]["LatLng"]), step).}
  }
  function deorbit {
    addons:tr:settarget(landing_pos()).
    set Fuel_Factor to 1.25.
    // set landing_per_buffer to (50290*(TWR*Fuel_Factor)^(-2.232) + 222.1)*(0.99)^(landing_pos():terrainheight/2000).
    set landing_per_buffer to 4000.
    set R_per_landing to ship:body:radius + max(4500,landing_pos():terrainheight + landing_per_buffer).
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
    set deltaV_landing to V_apo - velocityat(ship,time:seconds + eta_node):orbit:mag.
    node_exec["make"](TIME:seconds + eta_node,  0, 0, deltaV_landing).
    node_exec["exec"](true).
  }
  function on_target {
    GEAR on.
    set errorP_h to 0.
    set Kp_h to 0.04.
    set errorD_h to 0.
    set Kd_h to 0.04.
    set ThrustSet to 0.
    set GravityTurnCorrection to 1.5/100.
    lock throttle to ThrustSet.
    set time0 to time:seconds.
    lock time1 to time:seconds - time0.
    set buffer_speed_h to 0.
    set cutoffspeed_h to 25.
    set CutOffThrottle to 0. // In percent
    set count to 1.
    set MaxCount to 5.
    set flightmode to 1.

    set align_vector to -1*landing_pos:altitudevelocity(altitude):orbit.
    lock steering to align_vector.
    print "Aligning with Surface Retrograde Preemptively".
    until VANG(ship:facing:vector,align_vector) < 1 {
    	print "Direction Angle Error = " + round(VANG(ship:facing:vector,align_vector),1) + "   "at(0,1).
    }
    clearscreen.
    set landing_eta_buffer to velocityat(ship,time:seconds + eta:periapsis):orbit:mag/(TWR*g0).
    print "Warping to " + round(landing_eta_buffer,0) + "sec before Periapsis".
    warpto(time:seconds + eta:periapsis - 1.075*landing_eta_buffer).

    set follow_mode to 1.
    lock steering to srfretrograde.
    clearscreen.
    until flightmode = 2 {
    	if follow_mode = 1 {
    		if ship:body:atm:exists {
    			if ThrustSet > 0 {
    			lock steering to Velocity_diff_direction.
    			set follow_mode to 2.
    			}
    		} else {
    			lock steering to Velocity_diff_direction.
    			set follow_mode to 2.
    			}
    	}
    	set LandingVector to VECDRAW(landing_pos:position,(altitude-landing_pos:terrainheight+25)*(landing_pos:position-R_ship):normalized,GREEN,"Landing Position",1.0,TRUE,.5).
    	set SideslipVector to VECDRAW(V(0,0,0),10*long_diff_h*long_diff_dir,GREEN,"Sideslip Component",1.0,TRUE,.5).
    	if flightmode = 1 {
    		// Main PD loop for the thrust control
    		set error1_h to error_h.
    		set dist1 to dist_diff_h.
    		set t1 to time1.
    		wait .00001.
    		set error2_h to error_h.
    		set dist2 to dist_diff_h.
    		set t2 to time1.
    		set dt to t2-t1.
    		// I like to take an average error so its not going crazy due to discrete calculations.
    		set errorP_h to .5*(error1_h+error2_h).
    		set errorD_h_test to (error2_h-error1_h)/dt.
    		//This next part is used as a running average, the Derivative term was behaving eratically thus this damps out the spikes.
    		if count < MaxCount {
    			if count < 2 {
    				set errorD_h to errorD_h_test.
    				}
    			if count >= 2 {
    				set errorD_h to (errorD_h*(count-1)+errorD_h_test)/count.
    				}
    			set count to count + 1.
    			}
    		if count >= MaxCount { set errorD_h to (errorD_h*(MaxCount-1)+errorD_h_test)/MaxCount. }
    		set ThrustSet to 1 - Kp_h*errorP_h - Kd_h*errorD_h + GravityTurnCorrection.
    		if ThrustSet > 1 { set ThrustSet to 1. }
    		if dist2 > dist1 AND ship:obt:trueanomaly < 90 { set ThrustSet to 1. }
    		// The Cut Off Thrust is used to help maximize efficiency. At 0 it is a nice smooth ramp up but if you make the fuel cut off higher it only turns on when its above this value and thus increases efficiency
    		// since the ship will be burning at a higher throttle on average (100% throttle is the most efficient but that requires some more calculations).
    		if ThrustSet < CutOffThrottle/100 { set ThrustSet to 0. }
        // This is very important. If the error ever drops below 0, it means it might crash since the
        // equation is calculated based on full thrust.
    		if errorP_h < 0 { set ThrustSet to 1. }
    		// Cut off conditions to switch to vertical landing portion of the controller
    		if speed_diff_h < 0.1 {
    			set ThrustSet to 0.
    			set flightmode to 2.
    			}
    		if (dist_diff_h > (cutoffdist_h)) AND speed_diff_h < cutoffspeed_h {
    			set ThrustSet to 0.
    			set flightmode to 2.
    			}
    	}

    	print "Horizontal Distance to Landing Site = " + round(dist_diff_h,2) + "     "at(0,0).
    	print "Speed relative to Landing Site = " + round(speed_diff_h,2) at(0,1).
    	print "MaxThrustAccHor = " + round(MaxThrustAccHor,2) at(0,2).
    	print "Vmax_h = " + round(Vmax_h,2) at(0,3).
    	print "errorP_h = " + round(errorP_h,2) + "      " at(0,4).
    	print "errorD_h = " + round(errorD_h,2) + "      " at(0,5).
    	print "ThrustSet = " + round(ThrustSet*100,2) + "%     " at(0,7).
    	print "Flightmode = " + flightmode at(0,8).
    	print "cutoffdist_h = " + round(cutoffdist_h,2) + "      " at(0,9).
    	print "Distance to target cutoff = " + round(cutoffdist_h - dist_diff_h,2) + "       " at(0,10).
    	print "follow_mode = " + follow_mode at(0,11).
    	print "long_diff_h = " + round(long_diff_h,2) + "      " at(0,12).
    }
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

  function calcedAccel {
    local currVel TO SHIP:VELOCITY:ORBIT.
    local currTime TO TIME:SECONDS.
    wait 0.02.
    local prevVel TO currVel.
    local prevTime TO currTime.
    LOCK gravitationalAcc TO SHIP:BODY:MU / (SHIP:BODY:RADIUS + SHIP:ALTITUDE)^2.
    GLOBAL acc TO V(0, 0, 0).
    SET currVel TO SHIP:VELOCITY:ORBIT.
    SET currTime TO TIME:SECONDS.
    local timeDelta TO currTime - prevTime.
    IF timeDelta <> 0 { SET acc TO (currVel - prevVel) * (1 / timeDelta) + UP:FOREVECTOR * gravitationalAcc. }
    SET prevVel TO currVel. SET prevTime TO currTime.
    return acc:mag.
  }
  function cardVel {
  	local vect IS SHIP:VELOCITY:SURFACE.
  	local eastVect is VCRS(UP:VECTOR, NORTH:VECTOR).
  	local eastComp IS scalarProj(vect, eastVect).
  	local northComp IS scalarProj(vect, NORTH:VECTOR).
  	local upComp IS scalarProj(vect, UP:VECTOR).
  	RETURN V(eastComp, upComp, northComp).
  }
  function velPitch {
  	local cardVelFlat IS V(cardVelCached:X, 0, cardVelCached:Z).
  	RETURN VANG(cardVelCached, cardVelFlat).
  }
  function velDir { return ARCTAN2(cardVelCached:X, cardVelCached:Y). }
  function scalarProj {
  	parameter a, b.
  	if b:mag = 0 { PRINT "scalarProj: Tried to divide by 0. Returning 1". RETURN 1. }
  	RETURN VDOT(a, b) * (1/b:MAG).
  }
  function terrainDist {
  	if SHIP:GEOPOSITION:TERRAINHEIGHT > 0 { RETURN SHIP:ALTITUDE - SHIP:GEOPOSITION:TERRAINHEIGHT. }
    else { RETURN SHIP:ALTITUDE. }
  }
  function geoDistance {
  	parameter geo1, geo2.
  	return (geo1:POSITION - geo2:POSITION):MAG.
  }
  function geoDir {
  	parameter geo1, geo2.
  	return ARCTAN2(geo1:LNG - geo2:LNG, geo1:LAT - geo2:LAT).
  }
  function steeringPIDs {
  	SET eastVelPID:SETPOINT TO eastPosPID:UPDATE(TIME:SECONDS, SHIP:GEOPOSITION:LNG).
  	SET northVelPID:SETPOINT TO northPosPID:UPDATE(TIME:SECONDS,SHIP:GEOPOSITION:LAT).
  	local eastVelPIDOut IS eastVelPID:UPDATE(TIME:SECONDS, cardVelCached:X).
  	local northVelPIDOut IS northVelPID:UPDATE(TIME:SECONDS, cardVelCached:Z).
  	local eastPlusNorth is MAX(ABS(eastVelPIDOut), ABS(northVelPIDOut)).//SQRT(eastVelPIDOut^2 + northVelPIDOut^2).
  	SET steeringPitch TO 90 - eastPlusNorth.
  	local steeringDirNonNorm IS ARCTAN2(eastVelPID:OUTPUT, northVelPID:OUTPUT). //might be negative
  	if steeringDirNonNorm >= 0 {
  		SET steeringDir TO steeringDirNonNorm.
  	} else {
  		SET steeringDir TO 360 + steeringDirNonNorm.
  	}
  }
  export(landing).
}
