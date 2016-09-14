local mission is import("lib/mission.ks").
local transfer is import("lib/transfer.ks").
local TARGET_ALTITUDE is 750000.
local freeze is transfer["freeze"].

local rt_network_mission is mission(mission_definition@).
function mission_definition {
  parameter seq, ev, next.

  seq:add(prelaunch@).
  function prelaunch {
    set ship:control:pilotmainthrottle to 0.
    lock throttle to 1.
    lock steering to heading(90, 90).
    wait 1.
    next().
  }

  seq:add(launch@).
  function launch {
    stage. wait 5.
    lock pct_alt to alt:radar / TARGET_ALTITUDE.
    lock target_pitch to -115.23935 * pct_alt^0.4095114 + 88.963.
    lock steering to heading(90, target_pitch).
    next().
  }

  seq:add(meco@).
  function meco {
    if apoapsis > TARGET_ALTITUDE {
      lock throttle to 0.
      lock steering to prograde.
      next().
    }
  }

  seq:add(circularize@).
  function circularize {
    if alt:radar > body:atm:height {
      transfer["seek"](
        freeze(time:seconds + eta:apoapsis),
        freeze(0), freeze(0), 0, { parameter mnv. return -mnv:orbit:eccentricity. }).
      transfer["exec"](true).
      wait 0. stage. wait 0.
      panels on.
      next().
    }
  }

}

export(rt_network_mission).
