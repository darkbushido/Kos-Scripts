
DOWNLOAD("mission_runmodes.ks").
DOWNLOAD("ship_utils.ks").
DOWNLOAD("node_functions.ks").
DOWNLOAD("collect_science.ks").

run once mission_runmodes.
run once ship_utils.
run once node_functions.
run once collect_science.

set main_sequence to list(
  lex(
    "Title", "Wait for Touchdown",
    "Function", wait_for_touchdown@
    ),
  lex(
    "Title", "Finished", 
    "Function", finished@
    )
  ).
set events to lex(
  "Collect Science", collect_science@,
  "Power Check", ensure_power@
).

function wait_for_touchdown {
  parameter mission.
  parameter params.

  if ALT:RADAR < 1
    mission["next"]().
}

set start_time to ROUND(TIME:SECOND).

run_mission(main_sequence, events).

reboot.