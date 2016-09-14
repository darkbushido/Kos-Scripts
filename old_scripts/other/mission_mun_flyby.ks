
DOWNLOAD("mission_runmodes.ks").
DOWNLOAD("ship_utils.ks").
DOWNLOAD("atmospheric_launch.ks").
DOWNLOAD("node_functions.ks").
DOWNLOAD("hohmann_transfer.ks").
run once mission_runmodes.
run once ship_utils.
run once atmospheric_launch.
run once node_functions.
run once hohmann_transfer.
set main_sequence to list(
  lex(
    "Title", "Launch",
    "Function", launch@
    ),
  lex(
    "Title", "Gravity Turn",
    "Function", gravity_turn@
    ),
  lex(
    "Title", "Circularize at Parking Orbit",
    "Function", circularization@
    ),
  lex(
     "Title", "Execute Circularization Node",
     "Function", execute_node@
    ),
  lex(
    "Title", "Hohmann Transfer to Mun",
    "Function", hohmann_transfer@,
    "Params", lex("Target", Mun)
  ),
  lex(
     "Title", "Execute Manuver Node",
     "Function", execute_node@
    ),
  lex(
    "Title", "Wait for Mun SOI change",
    "Function", wait_for_body_change@,
    "Params", lex("Body", Mun)
    ),
  lex(
    "Title", "Wait for Kerbin SOI change",
    "Function", wait_for_body_change@,
    "Params", lex("Body", Kerbin)
    ),
  lex(
    "Title", "Create Parking Orbit Circularization Node",
    "Function", circularization@,
    "Params", lex("Mode", "pariapsis")
    ),
  lex(
     "Title", "Execute Manuver Node",
     "Function", execute_node@
    ),
  lex(
    "Title", "Hohmann Transfer to Kerbin",
    "Function", hohmann_transfer@,
    "Params", lex("altitude", 150000)
    ),
  lex(
     "Title", "Execute Manuver Node",
     "Function", execute_node@
    ),
  lex(
    "Title", "Create Parking Orbit Circularization Node",
    "Function", circularization@,
    "Params", lex("Mode", "pariapsis")
    ),
  lex(
     "Title", "Execute Manuver Node",
     "Function", execute_node@
    ),
  lex(
    "Title", "Finished",
    "Function", finished@
    )
  ).
set events to lex(
  // "Power Check", ensure_power@
).

function wait_for_body_change {
  parameter mission.
  parameter params.

  if ship:body = params["Body"]
    mission["next"]().
}

function lock_to_retrograde {
  parameter mission.
  parameter params.

  lock steering to SHIP:SRFRETROGRADE.
  mission["next"]().
}

set start_time to ROUND(TIME:SECOND).

run_mission(main_sequence, events).
