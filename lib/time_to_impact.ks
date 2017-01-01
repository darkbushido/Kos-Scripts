{
  local tti to lex(
    "TTI", timeToImpact@
  ).
  function timeToImpact {
    parameter impactTimeList is list(0,0).
    IF SHIP:OBT:PERIAPSIS > 0 { RETURN 0. }
    LOCAL tol IS 0.1.
    LOCAL tH IS 0.
    LOCAL oA IS 1.
    LOCAL timeOffset IS 0.
    IF impactTimeList[0] = 0
    {
      HUDTEXT("Initializing, may take several seconds.",2,50,2,WHITE,FALSE).
      SET WARP TO 0.
      IF ALTITUDE > (BODY:RADIUS / 2) SET timeOffset TO timeToAltitude(BODY:RADIUS / 2).
      UNTIL oA < tH
      {
        SET tH TO SHIP:BODY:GEOPOSITIONOF(POSITIONAT(SHIP,TIME:SECONDS + timeOffset)):terrainheight.
        SET oA TO SHIP:BODY:ALTITUDEOF(POSITIONAT(SHIP,TIME:SECONDS + timeOffset)).
        SET timeOffset TO timeOffset + 2.
      }.
      SET timeOffset TO timeOffset - 20.
    }
    ELSE SET timeOffset TO (impactTimeList[0] - 5*(TIME:SECONDS - impactTimeList[1])).
    UNTIL oA < tH
    {
      SET tH TO SHIP:BODY:GEOPOSITIONOF(POSITIONAT(SHIP,TIME:SECONDS + timeOffset)):terrainheight.
      SET oA TO SHIP:BODY:ALTITUDEOF(POSITIONAT(SHIP,TIME:SECONDS + timeOffset)).
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
    LOCAL dR IS alt + SHIP:BODY:RADIUS.
    LOCAL cR IS SHIP:ALTITUDE + SHIP:BODY:RADIUS.
    LOCAL dTAC IS MAX(-1, MIN(1, ((sma * (1-ecc^2) / dR) - 1) / ecc)).
    LOCAL cTAC IS MAX(-1, MIN(1, ((sma * (1-ecc^2) / cR) - 1) / ecc)).
    LOCAL dEA IS ARCCOS((ecc+dTAC) / (1 + ecc*dTAC)).
    LOCAL cEA IS ARCCOS((ecc+cTAC) / (1 + ecc*cTAC)).
    LOCAL dMA IS dEA - ecc  * SIN(dEA).
    LOCAL cMA IS cEA - ecc  * SIN(cEA).
    IF ETA:APOAPSIS > ETA:PERIAPSIS { SET cMA TO 360 - cMA. }
    IF alt < SHIP:ALTITUDE { SET dMA TO 360 - dMA. }
    ELSE IF alt > SHIP:ALTITUDE AND ETA:APOAPSIS > ETA:PERIAPSIS { SET dMA TO 360 + dMA.}
    LOCAL meanMotion IS 360 / SHIP:OBT:PERIOD. // in deg/s
    RETURN (dMA - cMA) / meanMotion.
  }
  export(tti).
}
