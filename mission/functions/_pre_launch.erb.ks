function pre_launch {
  ev:remove("Power").
  ship_utils["disable"]().
  set ship:control:pilotmainthrottle to 0.
  lock throttle to PID:UPDATE(TIME:SECONDS, APOAPSIS).
  local dir to lazcalc["LAZ"](parking_alt, target_body:obt:inclination).
  lock steering to heading(dir, 88).
  next().
}
