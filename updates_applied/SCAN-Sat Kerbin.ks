LIST FILES IN fileList.
for file in fileList {
  if NOT LIST("boot", "update.ks"):CONTAINS(file:name) {
    DELETEPATH(file).
  }
}
COPYPATH("0:/mission/launch_to_orbit.ks", "1:/startup.ks").
set params to lex(
  "OrbitAlt", 450000,
  "LaunchInc", 90,
  "LaunchPitchExp", 0.28,
  "LaunchMaxQ", 30
).
writejson(params, "params.json").
