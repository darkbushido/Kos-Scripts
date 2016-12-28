{
  local p is import("lib/params.ks").
  local node_exec is import("lib/node_exec.ks").
  local node_set_inc_lan is import("lib/node_set_inc_lan.ks").
  local hc is import("lib/hillclimb.ks").
  local fit is import("lib/fitness_land.ks").
  local landing to lex(
    "FlyOverTarget", fly_over_target@,
    "DeorbitNode", deorbit@,
    "TTI", timeToImpact@
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
    local nd to NODE(time:seconds + node_eta,0,0,dv).
    ADD nd.
  }
  function deorbit {
    addons:tr:settarget(p["LND"]["LatLng"]).
    if not HASNODE { add node(time:seconds + OBT:PERIOD,0,0,-SHIP:VELOCITY:SURFACE:MAG/2). }
    local nd to NEXTNODE.
    local data to list(time:seconds + nd:eta, nd:radialout, nd:normal, nd:prograde).
    print "refining manuver time by 10".
    set data to hc["seek"](data, fit["deorbit_fit"](p["LND"]["LatLng"]), 10).
    print "refining manuver time by 1".
    set data to hc["seek"](data, fit["deorbit_fit"](p["LND"]["LatLng"]), 1).
    node_exec["exec"](true).
  }
  function timeToImpact {
    parameter impactTimeList is list(0,0).
    IF SHIP:OBT:PERIAPSIS > 0 { RETURN 0. }
    LOCAL tol IS 0.1.
    LOCAL terrainHeight IS 0.
    LOCAL orbitAlt IS 1.
    LOCAL timeOffset IS 0.
    IF impactTimeList[0] = 0
    {
      HUDTEXT("Initializing, may take several seconds.",2,50,2,WHITE,FALSE).
      SET WARP TO 0.
      IF ALTITUDE > (BODY:RADIUS / 2) SET timeOffset TO timeToAltitude(BODY:RADIUS / 2).
      UNTIL orbitAlt < terrainHeight
      {
        SET terrainHeight TO SHIP:BODY:GEOPOSITIONOF(POSITIONAT(SHIP,TIME:SECONDS + timeOffset)):TERRAINHEIGHT.
        SET orbitAlt TO SHIP:BODY:ALTITUDEOF(POSITIONAT(SHIP,TIME:SECONDS + timeOffset)).
        SET timeOffset TO timeOffset + 2.
      }.
      SET timeOffset TO timeOffset - 20.
    }
    ELSE SET timeOffset TO (impactTimeList[0] - 5*(TIME:SECONDS - impactTimeList[1])).
    UNTIL orbitAlt < terrainHeight
    {
      SET terrainHeight TO SHIP:BODY:GEOPOSITIONOF(POSITIONAT(SHIP,TIME:SECONDS + timeOffset)):TERRAINHEIGHT.
      SET orbitAlt TO SHIP:BODY:ALTITUDEOF(POSITIONAT(SHIP,TIME:SECONDS + timeOffset)).
      SET timeOffset TO timeOffset + tol.
    }.
    set impactTimeList to LIST(timeOffset - tol, TIME:SECONDS).
    RETURN impactTimeList[0].
  }
  function timeToAltitude {
    parameter alt.
    IF alt < SHIP:PERIAPSIS OR alt > SHIP:APOAPSIS RETURN 0.
    LOCAL ecc IS SHIP:OBT:ECCENTRICITY.
    IF ecc = 0 SET ecc TO 0.00001. // ensure no divide by 0
    LOCAL sma IS SHIP:OBT:SEMIMAJORAXIS.
    LOCAL desiredRadius IS alt + SHIP:BODY:RADIUS.
    LOCAL currentRadius IS SHIP:ALTITUDE + SHIP:BODY:RADIUS.
    LOCAL desiredTrueAnomalyCos IS MAX(-1, MIN(1, ((sma * (1-ecc^2) / desiredRadius) - 1) / ecc)).
    LOCAL currentTrueAnomalyCos IS MAX(-1, MIN(1, ((sma * (1-ecc^2) / currentRadius) - 1) / ecc)).
    LOCAL desiredEccentricAnomaly IS ARCCOS((ecc+desiredTrueAnomalyCos) / (1 + ecc*desiredTrueAnomalyCos)).
    LOCAL currentEccentricAnomaly IS ARCCOS((ecc+currentTrueAnomalyCos) / (1 + ecc*currentTrueAnomalyCos)).
    LOCAL desiredMeanAnomaly IS desiredEccentricAnomaly - ecc  * SIN(desiredEccentricAnomaly).
    LOCAL currentMeanAnomaly IS currentEccentricAnomaly - ecc  * SIN(currentEccentricAnomaly).
    IF ETA:APOAPSIS > ETA:PERIAPSIS { SET currentMeanAnomaly TO 360 - currentMeanAnomaly. }
    IF alt < SHIP:ALTITUDE { SET desiredMeanAnomaly TO 360 - desiredMeanAnomaly. }
    ELSE IF alt > SHIP:ALTITUDE AND ETA:APOAPSIS > ETA:PERIAPSIS { SET desiredMeanAnomaly TO 360 + desiredMeanAnomaly.}
    LOCAL meanMotion IS 360 / SHIP:OBT:PERIOD. // in deg/s
    RETURN (desiredMeanAnomaly - currentMeanAnomaly) / meanMotion.
  }
  export(landing).
}
