LIST FILES IN fileList.
for file in fileList {
  if NOT LIST("boot", "update.ks"):CONTAINS(file:name) {
    DELETEPATH(file).
  }
}
COPYPATH("0:/mission/launch_to_orbit.ks", "1:/startup.ks").
set params to lex(
  "LaunchPitchExp", 0.27,
  "LaunchMaxQ", 25
).
writejson(params, "params.json").
