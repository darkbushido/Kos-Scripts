LIST FILES IN fileList.
for file in fileList {
  if NOT LIST("boot", "update.ks"):CONTAINS(file:name) {
    DELETEPATH(file).
  }
}
COPYPATH("0:/mission/remote_tech_moon_uplink.ks", "1:/startup.ks").
set params to lex(
  "TransBody", "Minmus",
  "TransInc", 90,
  "OrbitInc", 90,
  "LaunchMaxQ", 20,
  "LaunchPitchExp", 0.20
).
writejson(params, "params.json").
