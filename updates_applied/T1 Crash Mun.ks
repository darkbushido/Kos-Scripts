LIST FILES IN fileList.
for file in fileList {
  if NOT LIST("boot", "update.ks"):CONTAINS(file:name) {
    DELETEPATH(file).
  }
}
COPYPATH("0:/mission/moon_crash_at.ks", "1:/startup.ks").
set params to lex(
  "TransBody", "Mun",
  "TransInc", 0,
  "LaunchPitchExp", 0.43,
  "LandLatLng", waypoint("Site X-7S"):GEOPOSITION
).
writejson(params, "params.json").