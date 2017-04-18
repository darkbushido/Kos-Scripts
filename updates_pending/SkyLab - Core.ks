LIST FILES IN fileList.
for file in fileList {
  if NOT LIST("boot", "update.ks"):CONTAINS(file:name) {
    DELETEPATH(file).
  }
}
COPYPATH("0:/mission/remote_tech_network.ks", "1:/startup.ks").
set params to lex(
  "LaunchPitchExp", 0.31,
  "OrbitAlt", 500000,
  "LaunchMaxQ", 30
  // "NextShip", "CommSat Mk-I"
).
writejson(params, "params.json").
