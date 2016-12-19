sas off.

set RADAR_GROUND_HEIGHT to 6.4. //Set this too high and you get negative sqrt and crash.
                                //Set this too low and you slam into the ground.
set DESCENT_SPEED to 2. // fudgey number. higher is faster
set JET_SPOOL_TIME to 0. // aproximate number of seconds the jet spools.
set SURFACE_SHEAR_CAP to 40. //how many meters per second before we just lock to 45 degrees
                             //higher means less aggressive reactions to sideways movement.
set pt to TIME:SECONDS. //previous time
set pv to 0. //previous velocity
until false {
    wait 0.1.
    CLEARSCREEN.
    set surfaceShear to vxcl(up:forevector, velocity:surface).
    if surfaceShear:MAG > SURFACE_SHEAR_CAP { SET surfaceShear:MAG to SURFACE_SHEAR_CAP. }
    set desiredVelocity to -sqrt(alt:radar-RADAR_GROUND_HEIGHT)*DESCENT_SPEED.
    set velocityChange to desiredVelocity-ship:verticalspeed.
    set dt to TIME:SECONDS - pt.
    set dv to ((velocityChange - pv)/dt)*JET_SPOOL_TIME.
    set baseThrottle to (ship:mass*9.87/ship:maxthrust).
    set adjustmentThrottle to (velocityChange+dv)/3.

    print "Target Descent Speed: " + round(desiredVelocity, 2).
    print "Diff From Target    : " + round(velocityChange, 2).
    print "Diff Rate Of Change : " + round(dv, 2).
    print "Surface Shear Speed : " + round(surfaceShear:mag, 2).
    print "Neutral Throttle    : " + round(baseThrottle, 2).
    print "Adjustment Throttle : " + round(adjustmentThrottle, 2).

    lock throttle to adjustmentThrottle + baseThrottle + surfaceShear:mag/SURFACE_SHEAR_CAP.
    lock steering to lookdirup(up:forevector*SURFACE_SHEAR_CAP-surfaceShear, facing:topvector).

    set pt to TIME:SECONDS.
    set pv to velocityChange.
}
// copypath("0:/vtolland.ks", "1:").
// run vtolland.
