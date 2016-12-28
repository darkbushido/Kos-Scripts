{
  local circle_nav is lex(
    "bearing", bearing@,
    "destination", destination@,
    "distance", distance@,
    "midpoint", midpoint@
  ).
  function bearing {
   parameter p1, p2.
   return mod(360+arctan2(sin(p2:lng-p1:lng)*cos(p2:lat),cos(p1:lat)*sin(p2:lat)-sin(p1:lat)*cos(p2:lat)*cos(p2:lng-p1:lng)),360).
  }
  function destination {
    parameter p1, b, d, radius.
    local lat is arcsin(sin(p1:lat)*cos((d*180)/(radius*constant():pi))+cos(p1:lat)*sin((d*180)/(radius*constant():pi))*cos(b)).
    local lng is 0.
    if abs(Lat) <> 90 {
      set lng to p1:lng+arctan2(sin(b)*sin((d*180)/(radius*constant():pi))*cos(p1:lat),cos((d*180)/(radius*constant():pi))-sin(p1:lat)*sin(lat)).
    }.
    return latlng(lat,lng).
  }
  function distance {
    parameter p1, p2, radius.
    local A is sin((p1:lat-p2:lat)/2)^2 + cos(p1:lat)*cos(p2:lat)*sin((p1:lng-p2:lng)/2)^2.
    return radius*constant():PI*arctan2(sqrt(A),sqrt(1-A))/90.
  }
  function midpoint {
    parameter p1, p2.
    local A is cos(p2:lat)*cos(p2:lng-p1:lng).
    local B is cos(p2:lat)*sin(p2:lng-P1:lng).
    return latlng(arctan2(sin(p1:lat)+sin(p2:lat),sqrt((cos(p1:lat)+resultA)^2+resultB^2)),p1:lng+arctan2(resultB,cos(p1:lat)+resultA)).
  }
  export(circle_nav).
}
