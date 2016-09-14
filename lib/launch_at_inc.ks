set st to 0.
lock throttle to st.
set start_turn to FALSE.
function set_stage_fairings {
  parameter mission.
  parameter module_name.
  if SHIP:MODULESNAMED(module_name):LENGTH > 0 {
    set fs to 100.
    for fm in SHIP:MODULESNAMED(module_name) {
      if fm:PART:STAGE < fs
        set fs to fm:PART:STAGE.
    }
    mission["add_event"]("Stage Fairings: " + fs, stage_fairings@).
  }
}
function launch {
  parameter mission, params.

  SET pitch_exp to 0.40.
  if params:haskey("PitchExp")
    set pitch_exp to params["PitchExp"].

  set target_alt to (SHIP:BODY:ATM:HEIGHT + 10000).
  if params:haskey("Altitude")
    set target_alt to params["Altitude"].

  set init_incl to 90.
  if params:haskey("Inclination") {
    set lazcalc_data to LAZcalc_init(target_alt, params["Inclination"]).
    set init_incl to LAZcalc(lazcalc_data).
  }

  if params:haskey("Body") {
    set lazcalc_data to LAZcalc_init(target_alt, params["Body"]:obt:Inclination).
    set init_incl to LAZcalc(lazcalc_data).
    print "Waiting for Launch Window".
    warpto(launchwindow(params["Body"])).
  }

  SET Kp TO 0.01. SET Ki TO 0.006. SET Kd TO 0.006.
  SET PID TO PIDLOOP(Kp, Ki, Kd, 0, 1). SET PID:SETPOINT TO target_alt.

  mission["remove_event"]("Power Check").
  disable_antennas().

  set_stage_fairings(mission,"ModuleProceduralFairing").
  lock steering to heading(init_incl,85).

  set st to 1.
  if AVAILABLETHRUST = 0 {
    STAGE.
  }
  mission["remove_event"]("Drop Empty Tanks").
  mission["add_event"]("Auto Stage", auto_stage@).
  mission["next"]().
}
function gravity_turn {
  parameter mission.
  parameter params.
  if ALTITUDE > 1000 AND start_turn = FALSE {
    set start_turn to TRUE.
    LOCK pitch to 90.0 - (90.0 * (alt:radar / target_alt)^pitch_exp).
    LOCK STEERING to heading(init_incl, pitch).
    mission["add_event"]("Update Throttle", update_throttle@).
  } else if ALTITUDE > BODY:ATM:HEIGHT {
    if stage_delta_v() < 75
      STAGE. WAIT 1.
    panels on.
    mission["remove_event"]("Update Throttle").
    mission["add_event"]("Power Check", ensure_power@).
    mission["add_event"]("Drop Empty Tanks", drop_empty_tanks@).
    lock throttle to 0.
    mission["next"]().
  }
}

function update_throttle {
  parameter mission.
  set st TO PID:UPDATE(TIME:SECONDS, APOAPSIS).
}
function stage_fairings {
  parameter mission.

  if fs = (STAGE:NUMBER - 1) AND alt:radar > (BODY:ATM:HEIGHT - 1000) {
    STAGE.
    panels on.
    mission["remove_event"]("Stage Fairings: " + fs).
  }
}

FUNCTION launchWindow {
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
  if VCRS(launchtimedir, SHIP:POSITION - BODY:POSITION)*planetNormal < 0 {
      SET launchtime TO BODY:ROTATIONPERIOD - launchtime.
  }
  RETURN TIME:SECONDS+launchtime.
}
