LIST FILES IN fileList.
for file in fileList {
  if NOT LIST("boot", "update.ks"):CONTAINS(file:name) {
    DELETEPATH(file).
  }
}
COPYPATH("0:/mission/moon_land_at.ks", "1:/startup.ks").
set params to lex(
  "LaunchPitchExp", 0.28,
  "TransTarget", Mun,
  "TransInc", 0,
  "TransAlt", 100000,
  "LaunchMaxQ", 25,
  "LandLatLng", waypoint("Impact Target"):GEOPOSITION
).
writejson(params, "params.json").
