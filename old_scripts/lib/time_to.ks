FUNCTION timeToImpact {
  parameter test_node is false.
  set impactTimeList to LIST(0,0).

  if test_node
    set nn to NEXTNODE.
  else
    set nn to ship.

  // return 0 if no impact
  IF nn:OBT:PERIAPSIS > 0
    RETURN 0.
  // tolerance (in seconds)
  LOCAL tol IS 0.1.
  // initialize variables
  LOCAL terrainHeight IS 0.
  LOCAL orbitAlt IS 1.
  LOCAL timeOffset IS 0.
  // one time setup if impact time not previously found (requires many iterations, slow)
  IF impactTimeList[0] = 0 {
    HUDTEXT("Initializing, may take several seconds.",2,50,2,WHITE,FALSE).
    SET WARP TO 0.
    // start from time to altitude = 1/2 body's radius (worst case terrain height)
    IF ALTITUDE > (BODY:RADIUS / 2) SET timeOffset TO timeToAltitude(BODY:RADIUS / 2, test_node).
    UNTIL orbitAlt < terrainHeight {
      SET terrainHeight TO SHIP:BODY:GEOPOSITIONOF(POSITIONAT(SHIP,TIME:SECONDS + timeOffset)):TERRAINHEIGHT.
      SET orbitAlt TO SHIP:BODY:ALTITUDEOF(POSITIONAT(SHIP,TIME:SECONDS + timeOffset)).
      SET timeOffset TO timeOffset + 2.
    }
    SET timeOffset TO timeOffset - 20.
  }
  // Start from a bit before previously found impact time if exists to speed things up significantly
  ELSE SET timeOffset TO (impactTimeList[0] - 5*(TIME:SECONDS - impactTimeList[1])).
  // Loop to find impact time accurately
  UNTIL orbitAlt < terrainHeight {
    SET terrainHeight TO SHIP:BODY:GEOPOSITIONOF(POSITIONAT(SHIP,TIME:SECONDS + timeOffset)):TERRAINHEIGHT.
    SET orbitAlt TO SHIP:BODY:ALTITUDEOF(POSITIONAT(SHIP,TIME:SECONDS + timeOffset)).
    SET timeOffset TO timeOffset + tol.
  }
  RETURN LIST(timeOffset - tol, TIME:SECONDS + (timeOffset - tol)).
}

FUNCTION timeToAltitude {
  PARAMETER alt.
  parameter test_node is false.
  if test_node
    set nn to nextnode.
  else
    set nn to ship.
  // return 0 if never reach altitude
  IF alt < nn:obt:PERIAPSIS OR alt > nn:obt:APOAPSIS RETURN 0.
  // query constants
  LOCAL ecc IS SHIP:OBT:ECCENTRICITY.
  IF ecc = 0 SET ecc TO 0.00001. // ensure no divide by 0
  LOCAL sma IS nn:OBT:SEMIMAJORAXIS.
  LOCAL desiredRadius IS alt + SHIP:BODY:RADIUS.
  LOCAL currentRadius IS SHIP:ALTITUDE + SHIP:BODY:RADIUS.
  // Step 1: get true anomaly (bounds required for numerical errors near apsides)
  LOCAL desiredTrueAnomalyCos IS MAX(-1, MIN(1, ((sma * (1-ecc^2) / desiredRadius) - 1) / ecc)).
  LOCAL currentTrueAnomalyCos IS MAX(-1, MIN(1, ((sma * (1-ecc^2) / currentRadius) - 1) / ecc)).
  // Step 2: calculate eccentric anomaly
  LOCAL desiredEccentricAnomaly IS ARCCOS((ecc+desiredTrueAnomalyCos) / (1 + ecc*desiredTrueAnomalyCos)).
  LOCAL currentEccentricAnomaly IS ARCCOS((ecc+currentTrueAnomalyCos) / (1 + ecc*currentTrueAnomalyCos)).
  // Step 3: calculate mean anomaly
  LOCAL desiredMeanAnomaly IS desiredEccentricAnomaly - ecc  * SIN(desiredEccentricAnomaly).
  LOCAL currentMeanAnomaly IS currentEccentricAnomaly - ecc  * SIN(currentEccentricAnomaly).
  IF ETA:APOAPSIS > ETA:PERIAPSIS
    SET currentMeanAnomaly TO 360 - currentMeanAnomaly.

  IF alt < SHIP:ALTITUDE
    SET desiredMeanAnomaly TO 360 - desiredMeanAnomaly.
  ELSE IF alt > SHIP:ALTITUDE AND ETA:APOAPSIS > ETA:PERIAPSIS
    SET desiredMeanAnomaly TO 360 + desiredMeanAnomaly.
  // Step 4: calculate time difference via mean motion
  LOCAL meanMotion IS 360 / SHIP:OBT:PERIOD. // in deg/s
  RETURN (desiredMeanAnomaly - currentMeanAnomaly) / meanMotion.
}
