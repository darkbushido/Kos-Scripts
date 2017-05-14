{
  if core:volume:exists("params.json") { set jp to readjson("params.json").}
  else { set jp to lex(). }
  function has_key { parameter k, d. if jp:haskey(k) set v to jp[k]. else set v to d. return v. }

  local trans_target to has_key("TransTarget", false).
  if trans_target:istype("Body")
    set trans_target to BODY(trans_target:name).
  else if trans_target:istype("Vessel")
    set trans_target to VESSEL(trans_target:name).
  local inc to 0.
  local lan to false.

  if notfalse(trans_target) {
    set inc to round(trans_target:obt:inclination).
    if inc <> 0
      set lan to trans_target:obt:LAN.
  }
  local lp to lex(
    "PitchExp", has_key("LaunchPitchExp", 0.35),
    "Alt", has_key("LaunchAlt", BODY:ATM:HEIGHT + 10000),
    "Inc", has_key("LaunchInc", inc),
    "LAN", has_key("LaunchLAN", lan),
    "AStage", has_key("LaunchAutoStage", true),
    "MAXQ", has_key("LaunchMaxQ", false)
  ).

  local oalt to has_key("OrbitAlt", lp["Alt"]).
  local op to lex(
    "Alt", oalt,
    "Power", has_key("OrbitPower", true),
    "AP", has_key("OrbitAP", oalt),
    "PE", has_key("OrbitPE", oalt),
    "Inc", has_key("OrbitInc", 0),
    "LAN", has_key("OrbitLAN", false)
  ).
  local transfer_params to lex(
    "Alt", has_key("TransAlt", 15000),
    "Target", trans_target,
    "Offset", has_key("OrbitOffset", 0),
    "Inc", has_key("TransInc", op["Inc"])
  ).
  if trans_target:istype("Body")
    set transfer_params["Alt"] to has_key("TransAlt", trans_target:ATM:HEIGHT + 15000).

  local lnd_lat_lng to has_key("LandLatLng", latlng(-0.097,-74.557)).
  local lnd to lex(
    "LatLng", latlng(lnd_lat_lng:lat, lnd_lat_lng:lng),
    "HSMOD", has_key("LandHSMOD", 1),
    "RadarOffset", has_key("RadarOffset", 2.2),
    "EngineSpool", has_key("EngineSpool", 0),
    "DescentSpeed", has_key("DescentSpeed", 2),
    "SurfaceSheerCap", has_key("SurfaceSheerCap", 40)
  ).
  local params to lex(
    "L", lp, "O", op, "T", transfer_params,
    "LND", lnd, "NextShip", has_key("NextShip", false),
    "SwitchToShp", has_key("SwitchToShp", false),
    "RenameShip", has_key("RenameShip", false)
  ).
  if notfalse(params["SwitchToShp"])
    set params["SwitchToShp"] to vessel(params["SwitchToShp"]).
  export(params).
}
