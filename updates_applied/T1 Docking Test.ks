LIST FILES IN fileList.
for file in fileList {
  if NOT LIST("boot", "update.ks"):CONTAINS(file:name) {
    DELETEPATH(file).
  }
}
COPYPATH("0:/mission/launch_to_orbit.ks", "1:/startup.ks").
set params to lex(
  "OrbitAlt", 200000,
  "LaunchPitchExp", 0.26,
  "LaunchMaxQ", 30,
  "NextShip", "T1 Docking Test"
).
writejson(params, "params.json").
