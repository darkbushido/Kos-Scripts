{
  function has_key {
    parameter k, d.
    if jp:haskey(k) set v to jp[k].
    else set v to d.
    return v.
  }

  if core:volume:exists("params.json") {
    set jp to readjson("params.json").
  } else {
    set jp to lex().
  }
  local tbody to body(has_key("Body", "Mun")).
  local next_ship to has_key("NextShip", false).
  local params to lex(
    "PAlt", has_key("ParkingAltitude", BODY:ATM:HEIGHT + 10000),
    "DAlt", has_key("Altitude", tbody:ATM:HEIGHT + 20000),
    "Inc", has_key("Inc", tbody:obt:inclination),
    "LAN", has_key("LAN", tbody:obt:lan),
    "TInc", has_key("TInc", 0),
    "Body", tbody,
    "PitchExp", has_key("PitchExp", 0.35)
  ).
  if next_ship
    params:add("NextShip",next_ship).
  print params.

  export(params).
}
