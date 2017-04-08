{
  local hohmann_transfer to lex(
    "transfer", transfer@, "time", transfer_time@
  ).
  function transfer {
    parameter r1, r2, tt is eta:periapsis.
    local dv to sqrt(ship:BODY:MU/r1) * (sqrt((2* r2)/(r1 + r2)) - 1).
    local n TO NODE(time:seconds+tt, 0, 0, dv).
    ADD n.
  }
  function transfer_time {
    parameter r1, r2, trgt, offset is 0.
    local tt to constant():pi * sqrt((((r1 + r2)^3)/(8*ship:BODY:MU))).
    local pa to mod(3600 + (180*(1-(sqrt(((r1 + r2)/(2*r2))^3)))), 360).
    local trgt_unv_lon to trgt:obt:lan + trgt:obt:argumentofperiapsis + trgt:obt:trueanomaly.
    local ship_unv_lon to SHIP:obt:lan + SHIP:obt:argumentofperiapsis + SHIP:obt:trueanomaly.
    local aa to mod(3600 + (trgt_unv_lon + offset) - ship_unv_lon, 360).
    // local aa to mod(3600 + (trgt:LONGITUDE + offset) - SHIP:LONGITUDE,360).
    local da to mod(3600 + aa - pa, 360).
    local sav to  360/SHIP:OBT:PERIOD. local tav to 360/trgt:OBT:PERIOD.
    local d_ang to sav - tav.
    local ut to da/d_ang.
    if ut < 0
      set ut to ut + (trgt:OBT:PERIOD*ship:OBT:PERIOD)/abs(trgt:OBT:PERIOD-ship:OBT:PERIOD).
    return ut.
  }
  export(hohmann_transfer).
}
