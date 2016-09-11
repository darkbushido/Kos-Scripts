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
    "Title", "Main-Engine Cutoff",
    "Function", main_engine_cutoff@
    ),
  lex(
    "Title", "Create Parking Orbit Circularization Node",
    "Function", circularization_node@
    ),
  lex(
    "Title", "Execute Circularization Node",
    "Function", execute_node@
    ),
  lex("Title", "Plane Change to match minmus",
     "Function", set_inc_lan@,
     "Params", lex("Inc", Minmus:ORBIT:INCLINATION, "LAN", Minmus:ORBIT:LAN)
   ),
 lex(
    "Title", "Execute Manuver Node",
    "Function", execute_node@
   ),
  lex(
    "Title", "Hohmann Transfer to Minmus",
    "Function", hohmann_transfer@,
    "Params", lex("Target", Minmus, "Pariapsis", 10000)
    ),
  lex("Title", "Execute Manuver Node",
    "Function", execute_node@
    ),
  lex(
    "Title", "Wait for Minmus SOI change",
    "Function", wait_for_body_change@,
    "Params", lex("Body", Minmus)
    ),
  lex(
    "Title", "Create Parking Orbit Circularization Node",
    "Function", circularization_node@,
    "Params", lex("Mode", "pariapsis")
    ),
  lex("Title", "Execute Manuver Node",
    "Function", execute_node@
    ),
  lex(
    "Title", "Hohmann Transfer to Minmus alt",
    "Function", hohmann_transfer@,
    "Params", lex("altitude", 100000)
    ),
  lex("Title", "Execute Manuver Node",
    "Function", execute_node@
    ),
  lex(
    "Title", "Create Parking Orbit Circularization Node",
    "Function", circularization_node@,
    "Params", lex("Mode", "pariapsis")
    ),
  lex(
    "Title", "Execute Manuver Node",
    "Function", execute_node@
    ),
  lex(
    "Title", "Plane Change to match minmus",
    "Function", set_inc_lan@,
    "Params", lex("Inc", 94.9, "LAN", 84.7)
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
  "Power Check", ensure_power@
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
