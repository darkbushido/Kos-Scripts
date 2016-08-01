LIST FILES IN fileList.
for file in fileList {
  if NOT LIST("boot.ks", "update.ks"):CONTAINS(file:name) {
    DELETE file.
  }
}
DOWNLOAD("mission_rt_launch.ks").
rename mission_rt_launch.ks to startup.ks.
set mission to lex("PitchExp", 0.5, "Target", "CommSat mk1a", "Offset", 90*1).
writejson(mission, "mission.json").
