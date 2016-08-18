function wait_for_soi_change {
  parameter mission.
  parameter params.

  if ship:body = params["Body"]
    mission["next"]().
  else
    wait 5.
}
