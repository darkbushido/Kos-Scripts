LIST FILES IN fileList.
for file in fileList {
  if NOT LIST("boot", "update.ks"):CONTAINS(file:name) {
    DELETEPATH(file).
  }
}
COPYPATH("0:/mission/moon_land_at_return.ks", "1:/startup.ks").
set params to lex(
  "LaunchPitchExp", 0.25,
  "LaunchMaxQ", 25,
  "TransTarget", Mun,
  "TransAlt", 150000,
  "LandLatLng", waypoint("Impact Target"):GEOPOSITION,
  "RadarOffset", 80
).
writejson(params, "params.json").
