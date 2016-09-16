 cvcz set st to 0.
lock throttle to st.
set start_turn to FALSE.
function set_stage_fairings {
  parameter m, mn.
  if SHIP:MODULESNAMED(mn):LENGTH > 0 {
    set fs to 100.
    for fm in SHIP:MODULESNAMED(mn) {
      if fm:PART:STAGE < fs
        set fs to fm:PART:STAGE.
    }
    m["add_event"]("Stage Fairings: " + fs, stage_fairings@).
  }
}
function launch {
  parameter m, p.
  SET pe to 0.40.
  if p:haskey("PitchExp")
    set pe to p["PitchExp"].
  set ta to (SHIP:BODY:ATM:HEIGHT + 10000).
  if p:haskey("Altitude")
    set ta to p["Altitude"].
  SET Kp TO 0.01. SET Ki TO 0.006. SET Kd TO 0.006.
  SET PID TO PIDLOOP(Kp, Ki, Kd, 0, 1). SET PID:SETPOINT TO target_alt.
  m["remove_event"]("Power Check").
  disable_antennas().
  set_stage_fairings(mission,"ModuleProceduralFairing").
  lock steering to heading(90,85).
  set st to 1.
  if AVAILABLETHRUST = 0 {
    STAGE.
  }
  m["remove_event"]("Drop Empty Tanks").
  m["add_event"]("Auto Stage", auto_stage@).
  m["next"]().
}
function gravity_turn {
  parameter m, p.
  if ALTITUDE > 1000 AND start_turn = FALSE {
    set start_turn to TRUE.
    LOCK pitch to 90.0 - (90.0 * (alt:radar / ta)^pe).
    LOCK STEERING to heading(90, pitch).
    mission["add_event"]("Update Throttle", update_throttle@).
  } else if ALTITUDE > BODY:ATM:HEIGHT {
    if stage_delta_v() < 75
      STAGE. WAIT 1.
    panels on.
    m["remove_event"]("Update Throttle").
    m["add_event"]("Power Check", ensure_power@).
    m["add_event"]("Drop Empty Tanks", drop_empty_tanks@).
    lock throttle to 0.
    m["next"]().
  }
}
function update_throttle {
  parameter m.
  set st TO PID:UPDATE(TIME:SECONDS, APOAPSIS).
}
function stage_fairings {
  parameter m.

  if fs = (STAGE:NUMBER - 1) AND alt:radar > (BODY:ATM:HEIGHT - 1000) {
    STAGE.
    panels on.
    m["remove_event"]("Stage Fairings: " + fs).
  }
}
