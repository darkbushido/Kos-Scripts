{
  local hohmann_transfer to lex(
    "transfer", transfer@, "time", transfer_time@
  ).
  function transfer {
    parameter r1, r2, tt is eta:periapsis.
    local dv to sqrt (ship:BODY:MU/r1) * (sqrt((2* r2)/(r1 + r2)) - 1).
    local n TO NODE(time:seconds+tt, 0, 0, dv).
    ADD n.
  }
  function transfer_time {
    parameter r1, r2, trgt, offset is 0.
    local tt to constant():pi * sqrt((((r1 + r2)^3)/(8*ship:BODY:MU))).
    local pa to (180*(1-(sqrt(((r1 + r2)/(2*r2))^3)))).
    local aa to mod(360 + (trgt:LONGITUDE + offset) - SHIP:LONGITUDE,360).
    local da to (mod(360 + aa - pa,360)).
    local sa to  360/SHIP:OBT:PERIOD. local ta to 360/trgt:OBT:PERIOD.
    local d_ang to sa - ta.
    return da/d_ang.
  }
  export(hohmann_transfer).
}
