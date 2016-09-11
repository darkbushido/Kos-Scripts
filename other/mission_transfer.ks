DOWNLOAD("mission_runmodes.ks").
run once mission_runmodes.
DOWNLOAD("ship_utils.ks").
run once ship_utils.
DOWNLOAD("node_functions.ks").
run once node_functions.
DOWNLOAD("collect_science.ks").
run once collect_science.
set main_sequence to list(
  // lex("Title", "Plane Change to match minmus",
  //  "Function", set_inc_lan@,
  //  "Params", lex("Inc", Minmus:ORBIT:INCLINATION, "LAN", Minmus:ORBIT:LAN)
  //  ),
  // lex(
  //  "Title", "Execute Plane Change Node",
  //  "Function", execute_next_node@
  //  ),
  // lex(
  //   "Title", "Hohmann Transfer to Minmus",
  //   "Function", hohmann_node@,
  //   "Params", lex("Body", Minmus, "Pariapsis", 10000)
  // ),
  // lex(
  //   "Title", "Execute Hohmann Transfer Node",
  //   "Function", execute_next_node@
  //   ),
  // lex(
  //   "Title", "Wait for Minmus SOI change",
  //   "Function", wait_for_body_change@,
  //   "Params", lex("Body", Minmus)
  //   ),
  // lex(
  //   "Title", "Create Parking Orbit Circularization Node",
  //   "Function", circularization_node@,
  //   "Params", lex("Mode", "pariapsis")
  //   ),
  // lex(
  //   "Title", "Execute Parking Orbit Circularization Node",
  //   "Function", execute_next_node@
  //   ),
  // lex(
  //   "Title", "Hohmann Transfer to Minmus alt",
  //   "Function", hohmann_node@,
  //   "Params", lex("altitude", 100000)
  //   ),
  // lex(
  //   "Title", "Execute Hohmann Transfer Node",
  //   "Function", execute_next_node@
  //   ),
  // lex(
  //   "Title", "Create Parking Orbit Circularization Node",
  //   "Function", circularization_node@,
  //   "Params", lex("Mode", "pariapsis")
  //   ),
  // lex(
  //   "Title", "Execute Parking Orbit Circularization Node",
  //   "Function", execute_next_node@
  //   ),
    lex("Title", "Plane Change to match minmus",
    "Function", set_inc_lan@,
    "Params", lex("Inc", 94.9, "LAN", 84.7)
    ),
  lex(
    "Title", "Execute Plane Change Node",
    "Function", execute_next_node@
    ),
  lex(
    "Title", "Finished",
    "Function", finished@
    )
  ).
set events to lex(
  // "Collect Science", collect_science@,
  "Power Check", ensure_power@
).

function wait_for_body_change {
  parameter mission.
  parameter params.

  if ship:body = params["Body"]
    mission["next"]().
}

set start_time to ROUND(TIME:SECOND).

run_mission(main_sequence, events).

reboot.
