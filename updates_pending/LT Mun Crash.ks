LIST FILES IN fileList.
for file in fileList {
  if NOT LIST("boot", "update.ks"):CONTAINS(file:name) {
    DELETEPATH(file).
  }
}
COPYPATH("0:/mission/moon_crash.ks", "1:/startup.ks").
set params to lex(
  "Body", "Mun",
  "TInc", 0,
  "Altitude", -15000,
  "PitchExp", 0.31
).
writejson(params, "params.json").
