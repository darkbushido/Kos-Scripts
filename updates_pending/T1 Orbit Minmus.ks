LIST FILES IN fileList.
for file in fileList {
  if NOT LIST("boot", "update.ks"):CONTAINS(file:name) {
    DELETEPATH(file).
  }
}
COPYPATH("0:/mission/moon_orbit_return.ks", "1:/startup.ks").
set params to lex(
  "TransTarget", Minmus,
  "TransInc", 0,
  "LaunchPitchExp", 0.43
).
writejson(params, "params.json").
