set download_files to list(
  "hohmann_transfer.ks","launch.ks","mission_runmodes.ks","node_execute.ks",
  "node_circularization.ks","node_set_inc_lan.ks","ship_utils.ks").
for df in download_files {
  if not exists("1:/lib" + df)
    COPYPATH("0:/lib/" + df, "1:/lib/" + df).
  RUNONCEPATH("1:/lib/" + df).
}

if core:volume:exists("mission.json") {
  set mission to readjson("mission.json").
} else {
  set mission to lex("PitchExp", 0.4).
}

if mission:haskey("Vessal") and mission:haskey("Offset") {
  set hohmann_lex to lex(
    "Title","Hohmann Transfer to " + mission["Vessal"] + " Orbit Offset " + mission["Offset"],
    "Function", hohmann_transfer@,"Params", lex("Vessal", VESSEL(mission["Vessal"]), "Offset", mission["Offset"])
  ).
} else {
  set hohmann_lex to lex("Title", "Hohmann Transfer to 750k Orbit",
    "Function", hohmann_transfer@,"Params", lex("Altitude", 750000)
  ).
}

set main_sequence to list(
  lex("Title", "Launch PitchExp:" + mission["PitchExp"],
    "Function", launch@,"Params", lex("PitchExp", mission["PitchExp"])),
  lex("Title", "Gravity Turn","Function", gravity_turn@),
  lex("Title", "Create Parking Orbit Circularization Node","Function",circularization@,"Params",lex("Warp",true)),
  hohmann_lex,
  lex("Title", "Execute Manuver Node (Warp)","Function", execute_node@,"Params",lex("Warp",true)),
  lex("Title", "Create Parking Orbit Circularization Node","Function",circularization@,"Params",lex("Warp",true)),
  lex("Title", "Adjusting Inclination to 0","Function", set_inc_lan@),
  lex("Title", "Execute Manuver Node (Warp)","Function", execute_node@,"Params",lex("Warp",true)),
  lex("Title", "Finished","Function", finished@)
).
set events to lex(
  "Power Check", ensure_power@
).
run_mission(main_sequence, events).
REBOOT.
