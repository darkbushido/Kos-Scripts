{
  function has_key {
    parameter k, d.
    if jp:haskey(k) set v to jp[k].
    else set v to d.
    return v.
  }
  if core:volume:exists("params.json") { set jp to readjson("params.json").}
  else { set jp to lex(). }
  local tbody to body(has_key("TransBody", "Mun")).
  local launch_params to lex(
    "PitchExp", has_key("LaunchPitchExp", 0.35),
    "Alt", has_key("LaunchAlt", BODY:ATM:HEIGHT + 10000),
    "Inc", has_key("LaunchInc", tbody:obt:inclination),
    "LAN", has_key("LaunchLAN", tbody:obt:LAN),
    "AStage", has_key("LaunchAutoStage", true)
  ).
  local orbit_params to lex(
    "Alt", has_key("OrbitAlt", launch_params["Alt"]),
    "AP", has_key("OrbitAP", launch_params["Alt"]),
    "PE", has_key("OrbitPE", launch_params["Alt"]),
    "Inc", has_key("OrbitInc", 0),
    "LAN", has_key("OrbitLAN", 0),
    "Vessel", has_key("OrbitVessel", false),
    "Offset", has_key("OrbitOffset", 0)
  ).
  local transfer_params to lex(
    "Alt", has_key("TransAlt", tbody:ATM:HEIGHT + 15000),
    "Body", tbody,
    "Inc", has_key("TransInc", tbody:obt:inclination)
  ).
  local params to lex(
    "L", launch_params,
    "O", orbit_params,
    "T", transfer_params,

    "NextShip", has_key("NextShip", false)
    // "TInc", has_key("TInc", 0),
    // "Body", tbody,

  ).
  print params.

  export(params).
}
