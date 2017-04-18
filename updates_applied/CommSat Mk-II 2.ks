LIST FILES IN fileList.
for file in fileList {
  if NOT LIST("boot", "update.ks"):CONTAINS(file:name) {
    DELETEPATH(file).
  }
}
COPYPATH("0:/mission/remote_tech_network.ks", "1:/startup.ks").
set params to lex(
  "LaunchPitchExp", 0.5,
  "OrbitPower", false,
  "OrbitAlt", 750000,
  "TransTarget", vessel("CommSat Mk-I"),
  "OrbitOffset", -120 * 2
).
writejson(params, "params.json").
