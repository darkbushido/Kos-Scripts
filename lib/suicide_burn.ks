{
  local p is import("lib/params.ks").
  local burn is lex(
    "SuicideBurn", suicide_burn@
  ).
  function suicide_burn {
    sas off.
    set pt to TIME:SECONDS.
    set pv to 0.

    until list("Landed","Splashed"):contains(ship:status) {
      wait 0.1.
      set surfaceShear to vxcl(up:forevector, velocity:surface).
      if surfaceShear:MAG > p["LND"]["SurfaceSheerCap"] { SET surfaceShear:MAG to p["LND"]["SurfaceSheerCap"]. }
      set desiredVelocity to -sqrt(alt:radar-p["LND"]["RadarOffset"])*p["LND"]["DescentSpeed"].
      set velocityChange to desiredVelocity-ship:verticalspeed.
      set dt to TIME:SECONDS - pt.
      set dv to ((velocityChange - pv)/dt)*p["LND"]["DescentSpeed"].
      set baseThrottle to (ship:mass*9.87/ship:maxthrust).
      set adjustmentThrottle to (velocityChange+dv)/3.

      lock throttle to adjustmentThrottle + baseThrottle + surfaceShear:mag/p["LND"]["SurfaceSheerCap"].
      lock steering to lookdirup(up:forevector*p["LND"]["SurfaceSheerCap"]-surfaceShear, facing:topvector).

      set pt to TIME:SECONDS.
      set pv to velocityChange.
    }
  }
  export(burn).
}
