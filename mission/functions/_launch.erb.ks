function launch {
  local dir to lazcalc["LAZ"](parking_alt, 0).
  if not target_body:obt:inclination = 0 {
    print "waiting for launch window.".
    local lan_t to lazcalc["window"](target_body).
    warpto(lan_t).
    wait until time:seconds >= lan_t.
    set dir to lazcalc["LAZ"](parking_alt, target_body:obt:inclination).
  }
  stage. wait 10.
  lock pct_alt to (alt:radar / parking_alt).
  lock target_pitch to 90 - (90* pct_alt^pitch_exp).
  lock steering to heading(dir, target_pitch).
  if not ev:haskey("AutoStage")
    ev:add("AutoStage", ship_utils["auto_stage"]).
  next().
}
