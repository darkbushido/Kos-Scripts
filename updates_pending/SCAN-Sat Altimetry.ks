LIST FILES IN fileList.
for file in fileList {
  if NOT LIST("boot", "update.ks"):CONTAINS(file:name) {
    DELETEPATH(file).
  }
}
COPYPATH("0:/mission/launch_to_orbit.ks", "1:/startup.ks").
set params to lex(
  "Apa", 500000,
  "Pea", 500000,
  "INC", 90,
  "PitchExp", 0.5,
  "AutoStage", false
).
writejson(params, "params.json").
