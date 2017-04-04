{
  local rendezvous is lex(
    "steer", steer@,
    "approach", approach@,
    "cancel", cancel@,
    "await_nearest", await_nearest@
  ).
  function steer {
    parameter vector.
    lock steering TO vector.
    wait until vang(ship:facing:forevector, vector) < 2.
  }
  function approach {
    parameter craft, speed.
    lock relativeVelocity TO craft:velocity:orbit - ship:velocity:orbit.
    steer(craft:position). lock steering TO craft:position.
    lock maxAccel TO ship:MAXTHRUST / ship:MASS.
    lock throttle TO min(1, ABS(speed - relativeVelocity:mag) / maxAccel).
    wait until relativeVelocity:mag > speed - 0.1.
    lock throttle TO 0.
    lock steering TO relativeVelocity.
  }
  function cancel {
    parameter craft.
    lock relativeVelocity TO craft:velocity:orbit - ship:velocity:orbit.
    steer(relativeVelocity). lock steering TO relativeVelocity.
    lock maxAccel TO ship:MAXTHRUST / ship:MASS.
    lock throttle TO min(1, relativeVelocity:mag / maxAccel).
    wait until relativeVelocity:mag < 0.5.
    lock throttle TO 0.
  }
  function await_nearest {
    parameter craft, minDistance.
    until 0 {
      SET lastDistance TO craft:distance.
      wait 0.5.
      IF craft:distance > lastDistance OR craft:distance < minDistance { BREAK. }
    }
  }
  export(rendezvous).
}
