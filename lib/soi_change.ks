function wait_for_soi_change {
  parameter mission.
  parameter params.
  lOCK STEERING to LOOKDIRUP(SUN:NORTH:VECTOR, FACING:TOPVECTOR).

  if ship:body = params["Body"] {
    set warp to 0.
    wait 1.
    mission["next"]().
  } else {
    wait 5.
  }
}
