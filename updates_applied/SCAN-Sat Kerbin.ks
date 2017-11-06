LIST FILES IN fileList.
for file in fileList {
  if NOT LIST("boot", "update.ks"):CONTAINS(file:name) {
    DELETEPATH(file).
  }
}
COPYPATH("0:/mission/launch_to_orbit.ks", "1:/startup.ks").
set params to lex(
  "OrbitAlt", 427812,
  "LaunchInc", 80.7,
  "LaunchPitchExp", 0.2,
  "LaunchGTAlt", 6000,
  "LaunchMaxQ", 30
).
writejson(params, "params.json").
