set download_files to list(
  "launch.ks",
  "collect_science.ks",
  "hohmann_transfer.ks",
  "hohmann_transfer_return.ks",
  "mission_runmodes.ks",
  "node_functions.ks",
  "soi_change.ks",
  "ship_utils.ks"
).
for df in download_files {
  DOWNLOAD("lib/" + df).
  RUNONCEPATH("lib/" + df).
}

if core:volume:exists("mission.json") {
  set mission to readjson("mission.json").
} else {
  set mission to lex("PitchExp", 0.4).
}

if mission:haskey("Body")
  set target_body to BODY(mission["Body"]).
else
  set target_body to Mun.

if mission:haskey("Altitude")
  set target_alt to mission["Altitude"].
else
  set target_alt to BODY:ATM:HEIGHT + 10000.

set hohmann_lex to lex(
  "Title",
  "Hohmann Transfer to " + mission["Body"],
  "Function", hohmann_transfer@,
  "Params", lex("Body", target_body, "Altitude", target_alt)
).

set main_sequence to list(
  lex(
    "Title", "Launch with Pitch: " + mission["PitchExp"],
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
    "Title", "Match " + target_body:name + " Inclination and LAN",
    "Function", set_inc_lan@,
    "Params", lex("Inc", target_body:OBT:INCLINATION ,"LAN", target_body:OBT:LAN)
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
    "Title", "Wait for SOI Change (" + target_body:name + ")",
    "Function", wait_for_soi_change@,
    "Params", lex("Body", target_body)
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
    "Title", "Collect Science",
    "Function", collect_science@
  ),
  lex(
    "Title", "Hohmann Transfer Return",
    "Function", hohmann_transfer_return@
  ),
  lex(
    "Title", "Execute Manuver Node",
    "Function", execute_node@
    ),
  lex(
    "Title", "Wait for SOI Change (Kerbin)",
    "Function", wait_for_soi_change@,
    "Params", lex("Body", Kerbin)
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
