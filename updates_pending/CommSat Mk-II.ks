LIST FILES IN fileList.
for file in fileList {
  if NOT LIST("boot", "update.ks"):CONTAINS(file:name) {
    DELETEPATH(file).
  }
}
COPYPATH("0:/mission/remote_tech_network.ks", "1:/startup.ks").
set params to lex(
  "LaunchPitchExp", 0.5,
  "OrbitAlt", 750000,
  "OrbitVessel", "CommSat Mk-I",
  "OrbitOffset", 120 * 2
).
writejson(params, "params.json").
