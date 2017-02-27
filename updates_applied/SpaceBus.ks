LIST FILES IN fileList.
for file in fileList {
  if NOT LIST("boot", "update.ks"):CONTAINS(file:name) {
    DELETEPATH(file).
  }
}
COPYPATH("0:/mission/kerbal_rescue_low.ks", "1:/startup.ks").
set params to lex(
  "LaunchPitchExp", 0.28,
  "OrbitAlt", 120000,
  "TransTarget", vessel("Elbald's Heap")

).
writejson(params, "params.json").
