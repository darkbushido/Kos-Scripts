LIST FILES IN fileList.
for file in fileList {
  if NOT LIST("boot", "update.ks"):CONTAINS(file:name) {
    DELETEPATH(file).
  }
}
COPYPATH("0:/mission/moon_land_at.ks", "1:/startup.ks").
set params to lex(
  "LaunchPitchExp", 0.36,
  "TransTarget", Minmus,
  "TransInc", 0,
  "TransAlt", 50000,
  "OrbitAlt", 50000,
  "LandLat", 0,
  "LandLng", 84
).
writejson(params, "params.json").
