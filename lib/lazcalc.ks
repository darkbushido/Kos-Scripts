{

  local laz_calc is lex(
    "LAZ", LAZcalc@,
    "window", launch_window@
  ).

  FUNCTION LAZcalc {
    PARAMETER desiredAlt,desiredInc.

    LOCAL launchLatitude IS SHIP:LATITUDE.
    IF desiredAlt <= 0 {
      PRINT "Target altitude cannot be below sea level". SET launchAzimuth TO 1/0.
    }
    LOCAL launchNode TO "Ascending".
    IF desiredInc < 0 {
      SET launchNode TO "Descending".
      SET desiredInc TO ABS(desiredInc).
    }.
    IF ABS(launchLatitude) > desiredInc {
      SET desiredInc TO ABS(launchLatitude).
      HUDTEXT("Inclination impossible from current latitude, setting for lowest possible inclination.", 10, 2, 30, RED, FALSE).
    }.
    IF 180 - ABS(launchLatitude) < desiredInc {
      SET desiredInc TO 180 - ABS(launchLatitude).
      HUDTEXT("Inclination impossible from current latitude, setting for highest possible inclination.", 10, 2, 30, RED, FALSE).
    }.
    LOCAL equatorialVel IS (2 * CONSTANT():Pi * BODY:RADIUS) / BODY:ROTATIONPERIOD.
    LOCAL targetOrbVel IS SQRT(BODY:MU/ (BODY:RADIUS + desiredAlt)).
    LOCAL inertialAzimuth IS ARCSIN(MAX(MIN(COS(desiredInc) / COS(SHIP:LATITUDE), 1), -1)).
    LOCAL VXRot IS targetOrbVel * SIN(inertialAzimuth) - equatorialVel * COS(launchLatitude).
    LOCAL VYRot IS targetOrbVel * COS(inertialAzimuth).
    LOCAL Azimuth IS MOD(ARCTAN2(VXRot, VYRot) + 360, 360).
    IF launchNode = "Ascending" { RETURN Azimuth. }
    ELSE IF launchNode = "Descending" {
      IF Azimuth <= 90 RETURN 180 - Azimuth.
      ELSE IF Azimuth >= 270 RETURN 540 - Azimuth.
    }
  }
  FUNCTION launch_window {
    PARAMETER tgt.
    LOCAL lat IS SHIP:LATITUDE.
    LOCAL eclipticNormal IS VCRS(tgt:POSITION - tgt:OBT:BODY:POSITION, tgt:PROGRADE:FOREVECTOR):NORMALIZED.
    LOCAL planetNormal IS HEADING(0,lat):VECTOR.
    LOCAL bodyInc IS VANG(planetNormal, eclipticNormal).
    LOCAL beta IS ARCCOS(MAX(-1,MIN(1,COS(bodyInc) * SIN(lat) / SIN(bodyInc)))).
    LOCAL intersectdir IS VCRS(planetNormal, eclipticNormal):NORMALIZED.
    LOCAL intersectpos IS -VXCL(planetNormal, eclipticNormal):NORMALIZED.
    LOCAL launchtimedir IS (intersectdir * SIN(beta) + intersectpos * COS(beta)) * COS(lat) + SIN(lat) * planetNormal.
    LOCAL launchtime IS VANG(launchtimedir, SHIP:POSITION - BODY:POSITION) / 360 * BODY:ROTATIONPERIOD.
    LOCAL incl_t is tgt:obt:inclination.
    if VCRS(launchtimedir, SHIP:POSITION - BODY:POSITION)*planetNormal < 0 {
      print "VCRS is less then 0".
      set incl_t to incl_t * -1.
      SET launchtime TO BODY:ROTATIONPERIOD - launchtime.
    }
    RETURN TIME:SECONDS+launchtime.
  }
  export(laz_calc).
}
