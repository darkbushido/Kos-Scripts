set download_files to list(
  "mission_runmodes.ks",
  "ship_utils.ks",
  "atmospheric_launch.ks",
  "node_functions.ks",
  "hohmann_transfer.ks"
).
for df in download_files {DOWNLOAD("lib/" + df). RUNONCEPATH("lib/" + df).}

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
    "Title", "Execute Manuver Node",
    "Function", execute_node@
    ),
  lex(
    "Title", "Adjusting Inclination to 0",
    "Function", set_inc_lan@
    ),
  lex(
    "Title", "Execute Manuver Node",
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
set events to lex(
  "Power Check", ensure_power@
).
set events to lex(
  "Power Check", ensure_power@
).
run_mission(main_sequence, events).
REBOOT.
