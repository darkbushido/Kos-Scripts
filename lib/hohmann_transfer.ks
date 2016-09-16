{
  local hohmann_transfer to lex(
    "transfer", transfer@,
    "time", transfer_time@
  ).
  function transfer {
    parameter r1, r2, d_time is eta:apoapsis.
    local my_dV to sqrt (ship:BODY:MU/r1) * (sqrt((2* r2)/(r1 + r2)) - 1).
    local nn TO NODE(time:seconds+d_time, 0, 0, my_dV).
    ADD nn.
    lock steering to nn:DELTAV.
  }
  function transfer_time {
    parameter r1, r2, trgt, offset is 0.
    local tt to constant():pi * sqrt((((r1 + r2)^3)/(8*ship:BODY:MU))).
    local pa to (180*(1-(sqrt(((r1 + r2)/(2*r2))^3)))).
    local aa to mod(360 + (trgt:LONGITUDE + offset) - SHIP:LONGITUDE,360) .
    local da to (mod(360 + aa - pa,360)).
    local sa to  360/SHIP:OBT:PERIOD.
    local ta to  360/trgt:OBT:PERIOD.
    local d_ang to sa - ta.
    return da/d_ang.
  }
  export(hohmann_transfer).
}
