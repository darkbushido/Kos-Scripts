{
  local laz_calc is lex( "LAZ", LAZcalc@, "window", launch_window@ ).
  FUNCTION LAZcalc {
    PARAMETER dAlt,dInc.
    LOCAL lLat IS SHIP:LATITUDE.
    IF dAlt <= 0 { PRINT "Target altitude cannot be below sea level". SET lAz TO 1/0. }
    LOCAL lN TO "Ascending".
    IF dInc < 0 { SET lN TO "Descending".SET dInc TO ABS(dInc). }
    IF ABS(lLat) > dInc { SET dInc TO ABS(lLat). }
    IF 180 - ABS(lLat) < dInc { SET dInc TO 180 - ABS(lLat). }
    LOCAL eV IS (2 * CONSTANT():Pi * BODY:RADIUS) / BODY:ROTATIONPERIOD.
    LOCAL tOV IS SQRT(BODY:MU/ (BODY:RADIUS + dAlt)).
    LOCAL iAz IS ARCSIN(MAX(MIN(COS(dInc) / COS(SHIP:LATITUDE), 1), -1)).
    LOCAL VXRot IS tOV * SIN(iAz) - eV * COS(lLat).
    LOCAL VYRot IS tOV * COS(iAz).
    LOCAL Azimuth IS MOD(ARCTAN2(VXRot, VYRot) + 360, 360).
    IF lN = "Ascending" { RETURN Azimuth. }
    ELSE IF lN = "Descending" {
      IF Azimuth <= 90 RETURN 180 - Azimuth.
      ELSE IF Azimuth >= 270 RETURN 540 - Azimuth.
    }
  }
  FUNCTION launch_window {
    PARAMETER tgt.
    LOCAL lat IS SHIP:LATITUDE.
    LOCAL eN IS VCRS(tgt:POSITION - tgt:OBT:BODY:POSITION, tgt:PROGRADE:FOREVECTOR):NORMALIZED.
    LOCAL pN IS HEADING(0,lat):VECTOR.
    LOCAL bodyInc IS VANG(pN, eN).
    LOCAL beta IS ARCCOS(MAX(-1,MIN(1,COS(bodyInc) * SIN(lat) / SIN(bodyInc)))).
    LOCAL intersectdir IS VCRS(pN, eN):NORMALIZED.
    LOCAL intersectpos IS -VXCL(pN, eN):NORMALIZED.
    LOCAL launchtimedir IS (intersectdir * SIN(beta) + intersectpos * COS(beta)) * COS(lat) + SIN(lat) * pN.
    LOCAL launchtime IS VANG(launchtimedir, SHIP:POSITION - BODY:POSITION) / 360 * BODY:ROTATIONPERIOD.
    LOCAL incl_t is tgt:obt:inclination.
    if VCRS(launchtimedir, SHIP:POSITION - BODY:POSITION)*pN < 0 {
      print "VCRS is less then 0".
      set incl_t to incl_t * -1.
      SET launchtime TO BODY:ROTATIONPERIOD - launchtime.
    }
    RETURN TIME:SECONDS+launchtime.
  }
  export(laz_calc).
}
