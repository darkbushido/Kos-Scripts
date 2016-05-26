// set airfield to LATLNG(-1.5409,-71.9099).
set airfield to LATLNG(-1.1,-71.8).
lock steering to heading( airfield:heading, 84.15).
stage.
wait 10.

wait until AVAILABLETHRUST = 0.
lock steering to SRFPROGRADE.
stage.
wait 18.

wait eta:apoapsis.
lock steering to srfretrograde.
