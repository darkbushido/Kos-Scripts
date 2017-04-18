LIST FILES IN fileList.
for file in fileList {
  if NOT LIST("boot", "update.ks"):CONTAINS(file:name) {
    DELETEPATH(file).
  }
}
COPYPATH("0:/mission/dock_with_target.ks", "1:/startup.ks").
set params to lex(
  "LaunchAlt", 120000,
  "LaunchPitchExp", 0.20,
  "LaunchMaxQ", 25,
  "TransTarget", vessel("SkyLab - Core")
).
writejson(params, "params.json").
