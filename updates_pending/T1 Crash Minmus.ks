LIST FILES IN fileList.
for file in fileList {
  if NOT LIST("boot", "update.ks"):CONTAINS(file:name) {
    DELETEPATH(file).
  }
}
COPYPATH("0:/mission/moon_crash.ks", "1:/startup.ks").
set params to lex(
  "TransTarget", Minmus,
  "TransInc", 0,
  "TransAlt", -30000,
  "LaunchPitchExp", 0.43
).
writejson(params, "params.json").
