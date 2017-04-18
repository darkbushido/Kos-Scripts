LIST FILES IN fileList.
for file in fileList {
  if NOT LIST("boot", "update.ks"):CONTAINS(file:name) {
    DELETEPATH(file).
  }
}
COPYPATH("0:/mission/remote_tech_moon_uplink.ks", "1:/startup.ks").
set params to lex(
  "LaunchPitchExp", 0.4,
  "LaunchMaxQ", 25,
  "TransTarget", Minmus,
  "TransInc", 90,
  "OrbitInc", 90,
  "OrbitLAN", false,
  "OrbitAlt", 50000,
  "TransAlt", 50000
).
writejson(params, "params.json").
