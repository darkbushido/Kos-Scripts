LIST FILES IN fileList.
for file in fileList {
  if NOT LIST("boot", "update.ks"):CONTAINS(file:name) {
    DELETEPATH(file).
  }
}
COPYPATH("0:/mission/remote_tech_moon_uplink.ks", "1:/startup.ks").
set params to lex(
  "TransBody", "Mun",
  "TransInc", 90,
  "OrbitInc", 90,
  "LaunchPitchExp", 0.25
).
writejson(params, "params.json").
