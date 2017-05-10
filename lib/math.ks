{
  local math is lex(
    "clamp360",clamp360@,
    "clamp180clamp180",clamp180@,
    "geo_pos_at",geo_pos_at@
  ).
  function gaussian { parameter v, t, w. return constant:e^(-1 * (v-t)^2 / (2*w^2)). }
  function gaussian2 {
    parameter v1, t1, w1, v2, t2, w2.
    return round(constant:e^(-1 * ((v1-t1)^2 / (2*w1^2) + (v2-t2)^2 / (2*w2^2))), 10).
  }
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
  	//if deg > 180 { return 360 - deg. } // always returned positive, wanted to get negative, but not sure that I'm not exploiting the bug
  	if deg180 > 180 { return deg180 - 360. }
  	return deg180.
  }
  function clamp180Positive {
  	parameter deg.
  	set deg to clamp360(deg).
  	if deg > 180 { return 360 - deg. } // provide a function that is the same as the old bugged version of clamp180
  	return deg.
  }
  function geo_pos_at {
    parameter geo, etaGeo.
    local lonShift is etaGeo * 360 / ship:body:rotationperiod.
    local geoThen is latlng(geo:lat, geo:lng - lonShift).
    return geoThen:position.
  }
  export(math).
}
