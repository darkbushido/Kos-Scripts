// /r/kos challenge: Land on the VAB!
// by /u/majromax

// Step zero -- some useful constants.

// The "tare altitude" is the radar altimeter value associated with us landing.
// Since all the vessels are single-stage, the initial radar reading will also
// be the final radar reading.
set tare_altitude to alt:radar.

// Geoposition for the VAB.  This latitude-longitude pair is nicely above the
// helipad.
set vablat to -(5.0 + 48.0/60)/60.
set vablon to -(74.0 + (37.0 + 06.0/60)/60).
set vabel to 200.0.

lock vabtarget to latlng(vablat,vablon):altitudeposition(vabel).

// The first stage is to launch the vessel into a ballistic trajectory, with an apex
// somewhat above the level of the VAB.  If the vessel had infinite TWR and could turn
// instantaneously, it would be most efficient to launch such that the apex was *at*
// the VAB, then use an impulsive lateral burn to stop.

// KSP vessels don't work like that, especially those provided for this challenge.
// To work with real constraints, the apex of the trajectory should be somewhat above
// and "before" the VAB, such that we can "hover" in.

// It would be most efficient for the apex of the ballistic arc to be at precisely
// the VAB, but it's impossible to slow and stop so quickly.  Instead, we'll move
// the apex back 50% of the way, then "hover mode" for the remainder.

// Since I can't be bothered to hand-specify coordinates, we'll set the desired
// ballistic apex as the halfway point (horizontally) between the launchpad and
// VAB, with an apex altitude of 250m.
set apexalt to 250.

// Vector towards the VAB at current altitude, such that it has no vertical component.
// This is 'set' rather than 'locked' because it is only used below, pre-launch.
set vabflat to latlng(vablat,vablon):altitudeposition(ship:altitude).

// Geoposition of the desired ballistic apex
set apexgeo to ship:body:geopositionof(0.5*vabflat).

// Vector to the ballistic apex.  This is referred to throughout flight, so it must
// be defined as a 'lock' since these positions are all relative to the moving ship.
lock aimpoint to apexgeo:altitudeposition(apexalt).


// Illustration arrows.

// Debugarrow 1 points towards our ultimate destination above the VAB.
set debugarrow1 to vecdraw(v(0,0,0),aimpoint,RGB(1,0,0),"Fly To",1.0, TRUE).
// Debugarrow 2 (now deleted) would have pointed horizontally towards the destination.
// Debugarrow 3 points in the direction of our desired thrust/acceleration.
set debugarrow3 to vecdraw(v(0,0,0),v(0,0,0),rgb(0,0.25,0.1),"Ballistic Injection",5.0,TRUE).

// Set zero throttle, stage until we have available thrust.
lock throttle to 0.

until (ship:availablethrust > 0) {
   print "No thrust, staging.".
   stage.
   wait 1.
}

set ship:control:pilotmainthrottle to 0.

// Get gravitational parameter.  This definition accounts for planetary rotation because
// early development was conducted in debug mode with 'hack gravity' (to slow everything
// down), and there the centrifugal force is about half the strength of gravitational
// acceleration.
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


// Now, conduct the fixed-point iteration.  This cycles between the above functions
// to settle on a finite-time burn that injects the vessel onto the pre-specified ballistic
// arc.

// As an initial guess, take the delta-v necessary if the ship had infinite TWR.
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

// Now, begin revising the trajectory in-flight.  This is necessary because the vessel
// is changing its characteristics (increasing TWR) and because the first half of the burn
// was undobutedly not executed perfectly.  In particular the "easy" mode ship has a terrible
// time steering to the injection point, due to a combination of low torque and decidedly
// imperfect cooked steering.
print "Revising ballistic trajectory in-flight".

// End the iterative revision when the apopapsis is above 90% of its desired value.
until (ship:apoapsis > 0.9 * apexalt) {

   // This is the same iteration as the launch-calculation, only run for 10
   // iterations rather than 50 and accounting for the current ship velocity.

   // This loop *will* take more than one physics tick to complete.  That's okay,
   // as the ballistic injection is only approximate.
   from {local iter is 0.} until iter = 10 step {set iter to iter + 1.} do {
      set othrust to apexthrust(v(0,0,0)).
      set endstate to posafter(othrust).
      set endpos to endstate[0].
      set endvel to endstate[1].
      set incthrust to apexthrust(endpos)  - endvel.
      set othrust to (othrust + 0.25*incthrust).
   }
   // The magic "ithrust" is only set after the iteration, since it is also
   // used to control the cooked steering.  Updating it above would cause
   // wildly incorrect behaviour if (when) a physics tick split the loop.
   set ithrust to othrust - ship:velocity:surface.

   // Update the arrows.
   set debugarrow1:vec to aimpoint.
   set debugarrow3:vec to ithrust:normalized.
   wait 0.05. // Force a physics tick to happen here.
}

// Stage 2 is to "hover" towards the VAB, maintaining altitude above the VAB whilst
// steadily losing horizontal velocity to halt above the target.

set ithrottle to 1.
set want_accel to ship:up:forevector.
lock isteering to lookdirup(want_accel,ship:facing:upvector).
lock steering to isteering.
lock throttle to ithrottle.
clearscreen.
// The hovering proceeds until the vessel is nearly stopped above the target, then
// the control switches to a "kill velocity" mode whith much less reference to the
// original target.  This ensures a landing with low lateral velocity and no tipping.
set killspeed to false.

// Re-label arrow3, since it's no longer ballistic injection
set debugarrow3:label to "Desired acceleration".
until (killspeed and alt:radar < 1+tare_altitude) {

   // This loop works in two parts.  The first and more important part controls vertical altitude
   // and speed, since crashing into the VAB is bad.

   // This is *not* a PID controller, it is a feed-forward controller.  We calculate the vertical
   // acceleration (net) necessary for the ship to come to a vertical halt at the target altitude
   // in 5 seconds (picked out of a hat).

   // The raw formula is x_fin = x_start + v_y*t + a/s*t^2, where a is vertical acceleration net
   // of gravity; gravity is added back in to give the desired engine output.  This value is
   // limited to not go below positive 0.2 because asking for a negative acceleration is counterproductive
   // (we can just fall) and to constrain the desired final steering
   set want_az to ship:up:forevector*max(0.2*g,g+((vabel-ship:altitude)-ship:verticalspeed*5)*2/25.0).

   // Part 2 is to set the desired horizontal acceleration.

   // Get the horizontal difference to target by removing the vertical component.
   set diff_x to vabtarget - ship:up:forevector*vdot(ship:up:forevector,vabtarget).

   // "Colinear speed" is the component of our velocity that is already on a line to or away
   // from this target.  (Hopefully to.)
   set colinear_speed to diff_x:normalized*vdot(diff_x:normalized,ship:velocity:surface).

   // "Normal speed" is the component of our velocity at right-angles to the target.  We don't
   // want to have much of this.
   set normal_speed to ship:velocity:surface - ship:up:forevector*ship:verticalspeed - colinear_speed.

   // If there were no horizontal acceleration, what would our time-to-target be (based on colinear
   // velocity only)?
   set timetotarget to diff_x:mag/max(vdot(colinear_speed,diff_x:normalized),0.01).

   // If we're in killing-speed mode *or* we're slow and close to the target, kill speed and
   // pay little attention to the target.
   if (killspeed or (diff_x:mag < 5 and colinear_speed:mag < 1)) {
      // Set horizontal acceleration to -10% of current horizontal speed, plus a very small component
      // towards the target to possibly arrest drift.
      set want_ax to -0.1*colinear_speed - 0.1*normal_speed + 0.05*diff_x:normalized*min(1,diff_x:mag).
      set hmode to "KILLING SPEED".
      set killspeed to true.  // "Latch" this mode -- it's permanent until final descent.
      // Reset the desired elevation to the actual terrain height, so that the vertical-acceleration
      // component begins a controlled descent.
      set vabel to ship:geoposition:terrainheight+tare_altitude.
   }
   else if (timetotarget > 20.0 ) {
      // If we have a long time to target, we don't want rapid deceleration in the horizontal.  In fact,
      // we may even want to speed up.  To do that, we will calculate the "needed to slow down" acceleration,
      // then add a limited correction towards the target (1 m/s^2 at 30 seconds to target).

      // Cruder "accelerate towards target, then flip to deceleration" attempts create very jumpy steering
      // that the easy-mode ship can't properly address, in turn leading to very undesired overhsoot.
      set want_ax to max(min((timetotarget-20)/10,1),0)*colinear_speed:normalized.

      // See the next bit for this formula explained.
      set want_ax to want_ax -1.1*(colinear_speed:mag)*colinear_speed/2/diff_x:mag - normal_speed/3.
      set hmode to "ACCELERATING TO SPEED".
   } else { // Otherwise accelerate with constant ax to arrive on target
      // We want to find the acceleration necessary to reach a horizontal stop *when at the target*.
      // Again, we can go back to basic physics, with Vf^2 = Vi^2 + 2 a dx.  Here, dx is the distance
      // to target, a is the acceleration we need, Vi^2 is the current (colinear) speed, and Vf is 0.

      // We'll multiply that by a small amount to create an "overdamped" slowdown that takes a wee bit
      // longer but doesn't overshoot.  There's certainly room to optmize here.
      set want_ax to -1.1*(colinear_speed:mag)*colinear_speed/2/diff_x:mag - normal_speed/3.
      set hmode to "ACCELERATING TO TARGET".
   }

   // Combine the horizontal and vertical accelerations to our net result.

   // However, these are not of equal importance: the vertical acceleration is more important,
   // so if we're going to demand more thrust then we have we want that to have priority.

   // Vector identity: the horizontal acceleration is given by want_ax:mag*want_ax:normalized.
   // We will reduce the effective magnitude to sqrt((g*twr)^2-want_az:mag^2) so that the net
   // length of the accelration vector is limited to g*twr, which is available acceleration.
   set want_accel to want_az + max(sqrt(min(0,(g*twr)^2-want_az:mag^2)),want_ax:mag)*want_ax:normalized.

   // Set the throttle to the desired output; this will throttle down when necessary.
   set ithrottle to want_accel:mag/(g*twr).

   // Update arrows and print out diagnostic information.
   set debugarrow1:vec to vabtarget.
   set debugarrow3:vec to want_accel:normalized.
   print "Vx_colinear is " + round(colinear_speed:mag,2) + "        " at (0,0).
   print "Estimated time to target is " + round(timetotarget,2) + "        " at (0,1).
   print "Vx_normal is " + round(normal_speed:mag,2) + "            " at (0,2).
   print "Need " + round(want_az:mag,2) + " m/s^2 aceeleration in vertical       " at (0,3).
   print "Want " + round(want_ax:mag,2) + " m/s^2 acceleration in horizontal     " at (0,4).
   print hmode + "             " at (0,5).
   print "Radar altimeter: " + round(alt:radar,2) + "            " at (0,6).
   wait 0.1. // Force a physics tick.
}

// After the above loop is done, we're in "kill speed" mode and are less than 1m above the
// ground.  We're coming in for landing!
print "Final descent in progress" at (0,7).

// Lock steering to up, to help prevent any landing-related tipovers.
lock steering to lookdirup(ship:up:forevector,ship:facing:upvector).
// Lock the throttle to 0.5g, to ensure descent but at a measured rate.
lock throttle to 0.5/twr.

// Wait until landed; the ship will bounce slightly.
wait until ship:verticalspeed > 0.

// Close down throttle.
lock throttle to 0.
set ship:control:pilotmainthrottle to 0.
set endtime to time.

// Finished!
print "Ascent complete in " + round(endtime:seconds-starttime:seconds,2) + " seconds" at (0,8).
