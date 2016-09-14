LIST FILES IN fileList.
for file in fileList {
  if NOT LIST("boot", "update.ks"):CONTAINS(file:name) {
    DELETEPATH(file).
  }
}
COPYPATH("0:/mission/rt_network.ks", "1:/startup.ks").
set p to lex("PitchExp", 0.35).
writejson(p, "params.json").
