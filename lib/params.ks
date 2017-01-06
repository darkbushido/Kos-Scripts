{
  if core:volume:exists("params.json") { set jp to readjson("params.json").}
  else { set jp to lex(). }
  function has_key { parameter k, d. if jp:haskey(k) set v to jp[k]. else set v to d. return v. }
  local tbody to body(has_key("TransBody", "Mun")).
  local lp to lex(
    "PitchExp", has_key("LaunchPitchExp", 0.35),
    "Alt", has_key("LaunchAlt", BODY:ATM:HEIGHT + 10000),
    "Inc", has_key("LaunchInc", tbody:obt:inclination),
    "LAN", has_key("LaunchLAN", tbody:obt:LAN),
    "CareAboutLan", has_key("CareAboutLan", not (tbody = Mun)),
    "AStage", has_key("LaunchAutoStage", true),
    "MAXQ", has_key("LaunchMaxQ", false)
  ).
  local oalt to has_key("OrbitAlt", lp["Alt"]).
  local op to lex(
    "Alt", oalt,
    "AP", has_key("OrbitAP", oalt),
    "PE", has_key("OrbitPE", oalt),
    "Inc", has_key("OrbitInc", lp["Inc"]),
    "LAN", has_key("OrbitLAN", lp["LAN"]),
    "Vessel", has_key("OrbitVessel", false),
    "Offset", has_key("OrbitOffset", 0)
  ).
  if notfalse(op["Vessel"])
    set op["Vessel"] to vessel(op["Vessel"]).
  local transfer_params to lex(
    "Alt", has_key("TransAlt", tbody:ATM:HEIGHT + 15000),
    "Body", tbody,
    "Inc", has_key("TransInc", tbody:obt:inclination)
  ).
  local lndp to lex(
    "LatLng", has_key("LandLatLng", latlng(-0.097,-74.557)),
    "HSMOD", has_key("LandHSMOD", 1),
    "RadarOffset", has_key("RadarOffset", 2.2),
    "EngineSpool", has_key("EngineSpool", 0),
    "DescentSpeed", has_key("DescentSpeed", 2),
    "SurfaceSheerCap", has_key("SurfaceSheerCap", 40)
  ).
  local params to lex(
    "L", lp, "O", op, "T", transfer_params,
    "LND", lndp, "NextShip", has_key("NextShip", false),
    "SwitchToShp", has_key("SwitchToShp", false)
  ).
  if notfalse(params["SwitchToShp"])
    set params["SwitchToShp"] to vessel(params["SwitchToShp"]).
  export(params).
}
