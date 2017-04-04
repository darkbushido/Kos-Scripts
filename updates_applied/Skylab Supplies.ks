LIST FILES IN fileList.
for file in fileList {
  if NOT LIST("boot", "update.ks"):CONTAINS(file:name) {
    DELETEPATH(file).
  }
}
COPYPATH("0:/mission/kerbal_rescue_high.ks", "1:/startup.ks").
set params to lex(
  "LaunchPitchExp", 0.26,
  "LaunchMaxQ", 30,
  "TransTarget", vessel("SkyLab - Core")
).
writejson(params, "params.json").
