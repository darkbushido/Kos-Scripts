LIST FILES IN fileList.
for file in fileList {
  if NOT LIST("boot", "update.ks"):CONTAINS(file:name) {
    DELETEPATH(file).
  }
}
COPYPATH("0:/mission/dock_with_target.ks", "1:/startup.ks").
set params to lex(
  "OrbitAlt", 200000,
  "LaunchPitchExp", 0.25,
  "LaunchMaxQ", 40,
  "TransTarget", vessel("T1 Docking Test 3")
).
writejson(params, "params.json").
