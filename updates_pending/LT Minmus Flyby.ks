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
  "PitchExp", 0.27
).
writejson(params, "params.json").
