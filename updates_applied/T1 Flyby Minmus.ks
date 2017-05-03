LIST FILES IN fileList.
for file in fileList {
  if NOT LIST("boot", "update.ks"):CONTAINS(file:name) {
    DELETEPATH(file).
  }
}
COPYPATH("0:/mission/moon_flyby.ks", "1:/startup.ks").
set params to lex(
  "TransTarget", Minmus,
  "TransInc", 178,
  "LaunchPitchExp", 0.45
).
writejson(params, "params.json").
