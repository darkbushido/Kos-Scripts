LIST FILES IN fileList.
for file in fileList {
  if NOT LIST("boot.ks", "update.ks"):CONTAINS(file:name) {
    DELETE file.
  }
}
DOWNLOAD("mission_launch.ks").
rename mission_launch.ks to startup.ks.
