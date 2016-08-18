set download_files to list(
  "mission_runmodes.ks",
  "ship_utils.ks",
  "launch.ks",
  "node_functions.ks"
).
for df in download_files {DOWNLOAD("lib/" + df). RUNONCEPATH("lib/" + df).}

if core:volume:exists("mission.json") {
  set mission to readjson("mission.json").
} else {
  set mission to lex("PitchExp", 0.4).
}

set main_sequence to list(
  lex(
    "Title", "Launching with Pitch: " + mission["PitchExp"],
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
  lex(
    "Title", "Create Parking Orbit Circularization Node",
    "Function", circularization@
    ),
  lex(
    "Title", "Execute Circularization Node",
    "Function", execute_node@
    ),
  lex(
    "Title", "Adjusting Inclination to 0",
    "Function", set_inc_lan@
    ),
  lex(
    "Title", "Finished",
    "Function", finished@
    )
  ).
set events to lex(
  "Power Check", ensure_power@
).
run_mission(main_sequence, events).
REBOOT.
