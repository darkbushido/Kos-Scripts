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
    "Title", "Finished",
    "Function", finished@
    )
  ).
set events to lex().

set start_time to ROUND(TIME:SECOND).

run_mission(main_sequence, events).
