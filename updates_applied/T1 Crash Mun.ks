LIST FILES IN fileList.
for file in fileList {
  if NOT LIST("boot", "update.ks"):CONTAINS(file:name) {
    DELETEPATH(file).
  }
}
COPYPATH("0:/mission/moon_crash.ks", "1:/startup.ks").
set params to lex(
  "TransTarget", Mun,
  "TransInc", 0,
  "LaunchPitchExp", 0.30,
  "TransAlt", -(Mun:radius/2),
  "LaunchMaxQ", 30
).
writejson(params, "params.json").
