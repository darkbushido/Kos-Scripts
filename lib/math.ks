{
  local math is lex(
    "clamp360",clamp360@,
    "clamp180clamp180",clamp180@,
    "geo_pos_at",geo_pos_at@,
    "circle_distance",circle_distance@
  ).
  function clamp360 {
  	parameter deg360.
  	if (abs(deg360) > 360) { set deg360 to mod(deg360, 360). }
  	until deg360 > 0 {
  		set deg360 to deg360 + 360.
  	}
  	return deg360.
  }
  function clamp180 {
  	parameter deg180.
  	set deg180 to clamp360(deg180).
  	if deg180 > 180 { return deg180 - 360. }
  	return deg180.
  }
  function clamp180Positive {
  	parameter deg.
  	set deg to clamp360(deg).
  	if deg > 180 { return 360 - deg. }
  	return deg.
  }
  function geo_pos_at {
    parameter etaGeo, geo.
    local lonShift is etaGeo * 360 / ship:body:rotationperiod.
    local geoThen is latlng(geo:lat, geo:lng - lonShift).
    return geoThen.
  }
  function circle_distance {
    parameter p1, p2, radius. //...around a body of this radius. (note: if you are flying you may want to use ship:body:radius + altitude).
    local A is sin((p1:lat-p2:lat)/2)^2 + cos(p1:lat)*cos(p2:lat)*sin((p1:lng-p2:lng)/2)^2.
    return radius*constant():PI*arctan2(sqrt(A),sqrt(1-A))/90.
  }
  export(math).
}
