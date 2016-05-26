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
    "Function", launch@,
    "Params", lex("PitchExp", 0.30)
    ),
  lex(
    "Title", "Gravity Turn",
    "Function", gravity_turn@
    ),
  lex(
    "Title", "Create Parking Orbit Circularization Node",
    "Function", circularization@
    ),
  lex(
    "Title", "Execute Circularization Node",
    "Function", execute_node@
    ),
  lex(
    "Title", "Hohmann Transfer to 1100k Orbit",
    "Function", hohmann_transfer@,
    // "Params", lex("Target", VESSEL("RTCommSAT"), "Offset", 90)
    "Params", lex("altitude", 1000000)
  ),
  lex(
    "Title", "Execute Manuver Node",
    "Function", execute_node@
    ),
  lex(
    "Title", "Create Parking Orbit Circularization Node",
    "Function", circularization@
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
set events to lex().

set start_time to ROUND(TIME:SECOND).

run_mission(main_sequence, events).

REBOOT.
