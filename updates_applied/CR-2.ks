LIST FILES IN fileList.
for file in fileList {
  if NOT LIST("boot", "update.ks"):CONTAINS(file:name) {
    DELETEPATH(file).
  }
}
COPYPATH("0:/mission/science_flyby.ks", "1:/startup.ks").
set params to lex(
  "Body", "Minmus",
  "Altitude", -1000,
  "PitchExp", 0.3
).
writejson(params, "params.json").
