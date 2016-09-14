SET startTime TO 0.
set oldwp to 0.
set oldwarp to warp.
function execute_node {
  parameter mission.
  parameter params.

  execute_node_raw(mission, params).
  if not hasnode
    mission["next"]().
}
function execute_node_raw {
  parameter mission.
  parameter params.

  if params:haskey("Auto Stage")
    mission["add_event"]("Auto Stage", auto_stage@).

  set ts to TIME:SECONDS.

  if params:haskey("Warp")
    set activate_warp to params["Warp"].
  else
    set activate_warp to false.

  local nn to NEXTNODE.
  if  startTime = 0 {
    set nndv to nn:DELTAV.
    local mnv_t to MNV_TIME(nndv:MAG).
    if stage_delta_v() > nndv:MAG {
      print "we have enough dV".
      SET startTime TO round(ts + nn:ETA - mnv_t/2,1).
    } else {
      print "stage does not have enough dV".
      SET startTime TO round(ts + nn:ETA - (mnv_t * .6) , 1).
    }
    LOCK STEERING TO nn:DELTAV.
  }

  if ts >= startTime {
    LOCK THROTTLE TO MAX(MIN(nn:DELTAV:MAG/10, 1),0).
  } else if VANG(SHIP:FACING:VECTOR, nn:BURNVECTOR) > 4 {
    if activate_warp = true {
      set warp to 0.
      set oldwarp to warp.
    }
    wait 1.
  } else if ts < startTime - 30 {
    if activate_warp = true {
      local rt to (startTime - 30) - ts.
      local wp to 0.
      if rt > 100000 { set wp to 7. }
      else if rt > 10000  { set wp to 6. }
      else if rt > 1000   { set wp to 5. }
      else if rt > 100    { set wp to 4. }
      else if rt > 50     { set wp to 3. }
      else if rt > 10     { set wp to 2. }
      else if rt > 5      { set wp to 1. }
      if wp <> oldwp OR warp <> wp {
        set warp to wp.
        wait 0.1.
        set oldwp to wp.
        set oldwarp to warp.
      }
      wait 0.1.
    } else { wait 5.}
  }

  if vdot(nn:burnvector, nndv) < 0.1 {
    LOCK THROTTLE TO 0.
    UNLOCK STEERING.
    REMOVE nn.
    mission["remove_event"]("Auto Stage").
    SET startTime TO 0.
    SET SHIP:CONTROL:PILOTMAINTHROTTLE TO 0.
  }
}
