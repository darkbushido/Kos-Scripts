LIST FILES IN fileList.
for file in fileList {
  if NOT LIST("boot", "update.ks"):CONTAINS(file:name) {
    DELETEPATH(file).
  }
}
COPYPATH("0:/mission/science_orbit.ks", "1:/startup.ks").
set params to lex(
  "Body", "Mun",
  "PitchExp", 0.30
).
writejson(params, "params.json").
