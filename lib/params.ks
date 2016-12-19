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
    "CareAboutLan", has_key("CareAboutLan", not (tbody = Mun)),
    "AStage", has_key("LaunchAutoStage", true)
  ).
  local orbit_params to lex(
    "Alt", has_key("OrbitAlt", launch_params["Alt"]),
    "AP", has_key("OrbitAP", launch_params["Alt"]),
    "PE", has_key("OrbitPE", launch_params["Alt"]),
    "Inc", has_key("OrbitInc", launch_params["Inc"]),
    "LAN", has_key("OrbitLAN", launch_params["LAN"]),
    "Vessel", has_key("OrbitVessel", false),
    "Offset", has_key("OrbitOffset", 0)
  ).
  local transfer_params to lex(
    "Alt", has_key("TransAlt", tbody:ATM:HEIGHT + 15000),
    "Body", tbody,
    "Inc", has_key("TransInc", tbody:obt:inclination)
  ).
  local landing_params to lex(
    "LatLng", has_key("LandLatLng", latlng(-0.097,-74.557)),
    "HSMOD", has_key("LandHSMOD", 1),
    "RadarOffset", has_key("RadarOffset", 2.2),
    "EngineSpool", has_key("EngineSpool", 0),
    "DescentSpeed", has_key("DescentSpeed", 2),
    "SurfaceSheerCap", has_key("SurfaceSheerCap", 40)
  ).
  local params to lex(
    "L", launch_params,
    "O", orbit_params,
    "T", transfer_params,
    "LND", landing_params,
    "NextShip", has_key("NextShip", false)
  ).

  export(params).
}
