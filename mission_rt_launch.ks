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

if core:volume:exists("mission.json") {
  set mission to readjson("mission.json").
} else {
  set mission to lex("PitchExp", 0.4).
}
if mission:haskey("Target") and mission:haskey("Offset") {
  set hohmann_lex to lex(
    "Title",
    "Hohmann Transfer to " + mission["Target"] + " Orbit Offset " + mission["Offset"],
    "Function", hohmann_transfer@,
    "Params", lex("Target", VESSEL(mission["Target"]), "Offset", mission["Offset"])
  ).
} else {
  set hohmann_lex to lex(
    "Title", "Hohmann Transfer to 1100k Orbit",
    "Function", hohmann_transfer@,
    "Params", lex("altitude", 1000000)
  ).
}

set main_sequence to list(
  lex(
    "Title", "Launch PitchExp:" + mission["PitchExp"],
    "Function", launch@,
    "Params", lex("PitchExp", mission["PitchExp"])
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
  hohmann_lex,
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
