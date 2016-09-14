// set airfield to LATLNG(-1.5409,-71.9099).
set airfield to LATLNG(-1.52,288.09).
// set flighttime to 6*60 +30.
// set rotation_period to kerbin:ROTATIONPERIOD.
// set circ to 2 * constant:pi * kerbin:radius.
// set sidereal_rotation_velocity to circ / rotation_period.
// set distance_traveled to sidereal_rotation_velocity * flighttime.
// set lng_adjust to (distance_traveled/circ) *360.

// lock steering to heading( LATLNG(airfield:lat, airfield:lng + lng_adjust):heading, 84.10).
lock steering to heading( airfield:heading-3, 48).
stage.
wait 10.

wait until AVAILABLETHRUST = 0.
lock steering to SRFPROGRADE.

wait 18.
stage.
wait eta:apoapsis.
stage.
lock steering to srfretrograde.
