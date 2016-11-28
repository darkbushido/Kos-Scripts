LIST FILES IN fileList.
for file in fileList {
  if NOT LIST("boot", "update.ks"):CONTAINS(file:name) {
    DELETEPATH(file).
  }
}
COPYPATH("0:/mission/moon_flyby.ks", "1:/startup.ks").
set params to lex(
  "Body", "Minmus",
  "Altitude", 15000,
  "TInc", 178,
  "PitchExp", 0.43
).
writejson(params, "params.json").
