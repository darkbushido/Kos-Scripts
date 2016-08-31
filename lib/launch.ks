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
  parameter mission.
  parameter params.
  if params:haskey("Inclination")
    set incl_init to arcsin( cos(params["Inclination"]) /cos(SHIP:LATITUDE) ).
  else
    set incl_init to 90.

  if params:haskey("PitchExp")
    set pitch_exp to params["PitchExp"].
  else
    SET pitch_exp to 0.40.
  print incl_init.
  if params:haskey("Altitude")
    set target_alt to params["Altitude"].
  else
    set target_alt to (SHIP:BODY:ATM:HEIGHT + 10000).

  SET Kp TO 0.01. SET Ki TO 0.006. SET Kd TO 0.006.
  SET PID TO PIDLOOP(Kp, Ki, Kd, 0, 1). SET PID:SETPOINT TO target_alt.

  local PI to constant():PI.

  local v_eqrot to 2* PI * SHIP:BODY:RADIUS / SHIP:BODY:ROTATIONPERIOD.
  local v_orbit to sqrt ( SHIP:BODY:MU / target_alt).

  set dir to arctan ((v_orbit * sin(incl_init) - v_eqrot*cos(SHIP:LATITUDE) ) /( v_orbit *cos(incl_init) )  ).

  mission["remove_event"]("Power Check").
  disable_antennas().

  set_stage_fairings(mission,"ModuleProceduralFairing").
  lock steering to heading(dir,89).

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
    LOCK STEERING to heading(dir, pitch).
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
