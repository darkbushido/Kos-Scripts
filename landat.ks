set radarOffset to alt:radar.

parameter destination is latlng(-0.096,-74.6225).
// Geoposition for the VAB.  This latitude-longitude pair is nicely above the
// helipad.
set vablat to destination:lat.
set vablon to destination:lng.
set vabel to destination:terrainheight * 1.25.

lock vabtarget to latlng(vablat,vablon):altitudeposition(vabel).
set apexalt to vabel * 1.25.
set vabflat to latlng(vablat,vablon):altitudeposition(ship:altitude).
set apexgeo to ship:body:geopositionof(0.8*vabflat).
lock aimpoint to apexgeo:altitudeposition(apexalt).
set debugarrow1 to vecdraw(v(0,0,0),aimpoint,RGB(1,0,0),"Fly To",1.0, TRUE).
set debugarrow3 to vecdraw(v(0,0,0),v(0,0,0),rgb(0,0.25,0.1),"Ballistic Injection",5.0,TRUE).
lock throttle to 0.

until (ship:availablethrust > 0) {
   print "No thrust, staging.".
   stage.
   wait 1.
}
set ship:control:pilotmainthrottle to 0.

set g to ship:body:mu/ship:body:radius^2 - (constant():pi/3600/3)^2*ship:body:radius.
lock twr to ship:availablethrust/ship:mass/g. // current maximum TWR

// For an infinte TWR vehicle, we would perform one single impulsive burn to put us
// on the right ballistic trajectory.  However, this works very badly at finite TWR,
// where the burn has a considerable duration and the position-at-end is different
// than the position-at-beginning.  We want a compromise thrust, such that at the
// end of the maneuver we're on target, and we can get this via a fixed-point iteration.

// Function 1: Given a ship position, find the impulsive thrust necessary to put us on
// track for apex-above-vab

declare function apexthrust {
   parameter pos. // Input position, use v(0,0,0) for the current ship location

   set diff to aimpoint - pos. // Difference between input position and the eventual apex
   set diffz to vdot(diff,up:forevector). // Difference projected vertically
   set diffx to diff - up:forevector*vdot(diff,up:forevector). // Difference projected horizontally

   // Only the vertical velocity is affected by gravity, so we'll determine that first; it will
   // set our time-to-apex and thus constrain the necessary horizontal velocity.

   // z-velocity necessary is sqrt(2*g*dz), and preserve sign of dz in output
   if (diffz > 0) {
      set vz to sqrt(2*g*diffz).
   } else { // We're a bit high.
      // The below formula is not physical, but it is an odd-sign extension of "below-target."
      // Undoubtedly there is a better way to handle this.
      set vz to -sqrt(-2*g*diffz).
   }
   // Time to get there is vz / g
   set dt to abs(vz) / g.
   // x-velocity is then diffx / dt.
   set vx to diffx / dt.

   return vz*up:forevector + vx.
}

// Function 2: For an input delta-v, compute the actual position and final velocity after
// executing the burn at current 100% throttle.
declare function posafter {
   parameter vel. // Input velocity
   set dt to vel:mag/(twr*g). // Time taken for burn
   set accel to vel / dt - g*ship:up:forevector. // True acceleration

   // Now, simple physics: the end position is 0.5*a*t^2
   set outpos to 0.5 * accel * dt^2.
   // ... and the end velocity is a * t.
   set outvel to dt * accel.
   return list(outpos,outvel).
}

set ithrust to apexthrust(v(0,0,0)).

// Iterate.  This causes a noticeable lag, but it is pre-launch so we have time.
from {local iter is 0.} until iter = 50 step {set iter to iter + 1.} do {
   // Find where our vessel will be after executing the current candidate burn.
   set endstate to posafter(ithrust).
   set endpos to endstate[0]. // Ending position
   set endvel to endstate[1]. // Ending velocity

   // Our increment is given by the velocity we need at end-position to get to the
   // ballistic arc, less the velocity we will have at the end-position.
   set incthrust to apexthrust(endpos)  - endvel.

   // Add a portion of this thrust increment to our trial value.  A factor of 0.1
   // works experimentally, but this is a conservative choice.  Other, nicer
   // iterations are possible that will converge more quickly.  In particular, this
   // does not account for the change in burn also affecting the final position,
   // as well as the final velocity.
   set ithrust to ithrust + 0.1*incthrust.

   // Draw the acceleration arrow in the direction of our guess so far.
   set debugarrow3:vec to ithrust:normalized.

   // Note there is no 'wait' here, as no physics is happening.
}

// Calculate our injection burn time
set dt to ithrust:mag/(twr*g).

print "Thrusting for " + round(dt,2) + " seconds".
set starttime to time.
lock steering to lookdirup(ithrust,ship:facing:upvector).
lock throttle to 1.

// Complete half of the burn with no feedback whatsoever, beyond the locked steering.
until (time > 0.5*dt + starttime) {
   set debugarrow1:vec to aimpoint.
   set debugarrow3:vec to ithrust:normalized.
   wait 0.25.
}

function avgMaxVertDecel {						// Maximum vertical deceleration possible (m/s^2)
	local srfspeed is ship:velocity:surface:mag.
	if srfspeed = 0
		return 0.
	local maxAccel is ship:availablethrust / ship:mass.
	local verticalComponent is -ship:verticalspeed / srfspeed.
	return maxAccel * (2 * verticalComponent + 1) / 3 - g. 		// verticalComponent is increased to account for the fact
}									// that the rocket points more directly downwards over time

lock throttle to 0.
clearscreen.
lock trueRadar to alt:radar - radarOffset.				// Offset radar to get distance from gear to ground
lock g to body:mu / body:radius^2.					// Gravity (m/s^2)
lock stopDist to ship:verticalspeed^2 / (2 * avgMaxVertDecel()).	// The distance the burn will require
lock idealThrottle to stopDist / trueRadar.				// Throttle required for perfect hoverslam
lock impactTime to trueRadar / abs(ship:verticalspeed).			// Time until impact, used for landing gear

WAIT UNTIL ship:verticalspeed < -1.
	hudtext("Preparing for hoverslam...", 5, 2, 50, white, false).
	rcs on.
	brakes on.
	lock steering to srfretrograde.
	when impactTime < 3 then gear on.

WAIT UNTIL trueRadar < stopDist.
	hudtext("Performing hoverslam", 5, 2, 50, white, false).
	lock throttle to idealThrottle.

WAIT UNTIL ship:verticalspeed > -0.01.
	hudtext("Hoverslam completed. Stabilising...", 5, 2, 50, white, false).
	lock throttle to 0.
	lock steering to up.						// Use the RCS for stability
	wait 5.
	rcs off.
	hudtext("Done!", 5, 2, 50, white, false).
