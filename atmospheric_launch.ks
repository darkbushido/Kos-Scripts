set st to 0.
lock throttle to st.
set start_turn to FALSE.
function set_stage_fairings {
  parameter mission.
  parameter module_name.
  if SHIP:MODULESNAMED(module_name):LENGTH > 0 {
    set fs to 100.
    for fm in SHIP:MODULESNAMED(module_name) {
      if fm:PART:STAGE < fs {
        set fs to fm:PART:STAGE.
      }
    }
    mission["add_event"]("Stage Fairings: " + fs, stage_fairings@).
  }
}

function launch {
  parameter mission.
  parameter params.
  if params:haskey("TargetHeading")
    set th to 90 - params["TargetHeading"].
  else
    set th to 90.

  if params:haskey("PitchExp")
    set pitch_exp to params["PitchExp"].
  else
    SET pitch_exp to 0.40.
  print th.
  if params:haskey("TargetAltitude")
    set ta to params["TargetAltitude"].
  else
    set ta TO BODY:ATM:HEIGHT + 10000.

  SET Kp TO 0.01. SET Ki TO 0.006. SET Kd TO 0.006.
  SET PID TO PIDLOOP(Kp, Ki, Kd, 0, 1). SET PID:SETPOINT TO ta.

  disable_antennas().

  set_stage_fairings(mission,"ModuleProceduralFairing").
  lock STEERING to heading(th, 90).
  set st to 1.
  if AVAILABLETHRUST = 0 {
    STAGE.
  }
  mission["add_event"]("Auto Stage", auto_stage@).
  mission["next"]().
}
function gravity_turn {
  parameter mission.
  parameter params.

  if ALTITUDE > 1000 AND start_turn = FALSE {
    set start_turn to TRUE.
    LOCK pitch to 90.0 - (90.0 * (alt:radar / ta)^pitch_exp).
    LOCK STEERING to heading(th, pitch).
    mission["add_event"]("Update Throttle", update_throttle@).
  } else if ALTITUDE > BODY:ATM:HEIGHT {
    if stage_delta_v() < 75 {
      STAGE. WAIT 1.
    }
    panels on.
    mission["remove_event"]("Update Throttle").
    mission["add_event"]("Power Check", ensure_power@).
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
    mission["remove_event"]("Stage Fairings").
  }

}
