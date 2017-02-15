set g0 to ship:body:mu/(ship:body:radius)^2.
set TWR to availablethrust/(mass*g0).
set Fuel_Factor to 1.25.

lock steering to srfretrograde.
set landing_pos to waypoint("Impact Target"):GEOPOSITION.

set buffer_speed_h to 0.
set cutoffspeed_h to 25.
//set landing_eta_buffer to 100.
set CutOffThrottle to 0. // In percent
set MaxCount to 5.

lock R_ship to ship:body:position.
lock angle_diff_h to VANG(-R_ship, landing_pos:position - R_ship).
lock dist_diff_h to (angle_diff_h/360)*2*(constant:pi)*R_ship:mag.
lock Velocity_h_norm to VCRS(VCRS(R_ship,ship:velocity:orbit),R_ship):normalized.
lock Speed_h to VDOT(Velocity_h_norm,ship:velocity:orbit).
lock speed_diff_h to Speed_h-landing_pos:altitudevelocity(altitude):orbit:mag.
lock long_diff_dir to VCRS(landing_pos:position,R_ship):normalized.
lock long_diff_h to VDOT(long_diff_dir,ship:velocity:surface).
lock Velocity_diff_direction to (-1*(ship:velocity:orbit - landing_pos:altitudevelocity(altitude):orbit + long_diff_h*long_diff_dir)):direction.
clearscreen.
// End of error commenting section.
// This is the heart of the function. The max horizontal acceleration is calculated as if the rocket is always in surface retrograde.
// Maintaining surface retrograde maximizes efficiency when landing
// Vmax_h is the maximum speed a ship can be traveling at its current distance to the target such that at full thrust it will reach the target with 0 velocity (aka suicide burn)
// Vmax_h assumes the thrust is constant but updates it to the current max horizontal acceleration and uses a PD loop to deal with the changing TWR
lock MaxThrustAccHor to -1*VDOT(Velocity_h_norm,availablethrust/mass*srfretrograde:vector).
lock truealt to altitude - landing_pos:terrainheight.
lock touchdown_time to (-verticalspeed - sqrt(verticalspeed^2 - 4*(-0.5*g0)*truealt))/(-1*g0).
lock cutoffdist_h to speed_diff_h*touchdown_time.
//set buffer_dist to 93.75.
set buffer_dist to 0.
lock Vmax_h to sqrt(MAX(0,2*(dist_diff_h - buffer_dist)*MaxThrustAccHor)).
// Standard PD loop parameters
lock error_h to Vmax_h - speed_diff_h.
set errorP_h to 0.
set Kp_h to 0.04.
set errorD_h to 0.
set Kd_h to 0.04.
set ThrustSet to 0.
set GravityTurnCorrection to 1.5/100.
lock throttle to ThrustSet.
set time0 to time:seconds.
lock time1 to time:seconds - time0.
set count to 1.
set flightmode to 1.
// Just a nice helping orientation so that your ship is already close to ready to go when it is done warping to the periapsis
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
	// A visual aid to show where the ship is supposed to land.
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
		if count >= MaxCount {

			set errorD_h to (errorD_h*(MaxCount-1)+errorD_h_test)/MaxCount.
			}

		set ThrustSet to 1 - Kp_h*errorP_h - Kd_h*errorD_h + GravityTurnCorrection.

		if ThrustSet > 1 {
			set ThrustSet to 1.
			}
		if dist2 > dist1 AND ship:obt:trueanomaly < 90 {
			set ThrustSet to 1.
			}
		// The Cut Off Thrust is used to help maximize efficiency. At 0 it is a nice smooth ramp up but if you make the fuel cut off higher it only turns on when its above this value and thus increases efficiency
		// since the ship will be burning at a higher throttle on average (100% throttle is the most efficient but that requires some more calculations).
		if ThrustSet < CutOffThrottle/100 {
			set ThrustSet to 0.
			}
		if errorP_h < 0 {
			set ThrustSet to 1. // This is very important. If the error ever drops below 0, it means it might crash since the
								// equation is calculated based on full thrust.
			}
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
