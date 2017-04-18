LIST FILES IN fileList.
for file in fileList {
  if NOT LIST("boot", "update.ks"):CONTAINS(file:name) {
    DELETEPATH(file).
  }
}
COPYPATH("0:/mission/moon_orbit.ks", "1:/startup.ks").
set params to lex(
  "TransTarget", Minmus,
  "TransInc", 90,
  "TransAlt", 50000,
  "OrbitInc", 90,
  "OrbitAlt", 100000,
  "LaunchPitchExp", 0.35
).
writejson(params, "params.json").
