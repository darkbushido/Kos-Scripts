{
  local orbit_math is lex(
  ).

  function GetTAFromULonAopLanInc {
      parameter
          ulon, // universal longitude
          aop, // argument of periapsis
          lan, // longitude of ascending node
          inc. // inclination
      local angleProj is clamp360(ulon - lan). // angle between ascending node and the projection of position on equatorial plane
      local phi is arctan(tan(angleProj)/cos(inc)). // central angle, returns quadrant 1 or quadrant 4
      if (phi < 0 and angleProj < 180) { // move from quadrant 4 to quadrant 2
          set phi to phi + 180.
      }
      else if phi > 0 and angleProj > 180 { // move from quadrant 1 to quadrant 3
          set phi to phi + 180.
      }
      local ta is clamp360(phi - aop). // true anomaly
      return ta.
  }
  function getUniversalLonFromTA {
      parameter ves, ta.
          // If you wanted to, you could use AoP, LAN, and Inc as parameters instead
      local angle is ves:orbit:argumentofperiapsis + ta.
      local ret is ves:orbit:lan + arctan(cos(ves:orbit:inclination) * tan(angle)).
      if cos(angle) < 0 set ret to ret + 180.
      return clamp360(ret).
  }

}
