LIST FILES IN fileList.
for file in fileList {
  if NOT LIST("boot", "update.ks"):CONTAINS(file:name) {
    DELETEPATH(file).
  }
}
COPYPATH("0:/mission/remote_tech_moon_network.ks", "1:/startup.ks").
set params to lex(
  "LaunchAlt", 1000000,
  "SwitchToShp", "CommSat Minmus",
  "TransTarget", "CommSat Minmus-Sat-I",
  "TransType", "Vessel",
  "RenameShip", "CommSat Minmus-Sat-III",
  "OrbitOffset", 120 * 2
).
writejson(params, "params.json").
