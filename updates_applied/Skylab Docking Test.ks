LIST FILES IN fileList.
for file in fileList {
  if NOT LIST("boot", "update.ks"):CONTAINS(file:name) {
    DELETEPATH(file).
  }
}
COPYPATH("0:/mission/dock.ks", "1:/startup.ks").
set params to lex(
  "LaunchPitchExp", 0.3,
  "TransTarget", vessel("SkyLab - Core")
).
writejson(params, "params.json").
