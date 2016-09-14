@LAZYGLOBAL OFF.

CORE:PART:GETMODULE("kOSProcessor"):DOEVENT("Open Terminal").

// set Terminal:HEIGHT to 72.
// set Terminal:WIDTH to 48.

wait 2.


//switch to script

//@LAZYGLOBAL OFF.
// Variablen
LOCAL mun_orbit to 12.
LOCAL shipname to "Mun Return 1".
LOCAL incl to 0.
set target to Mun.
// Code

set SHIP:NAME to shipname.
print SHIP:NAME.

copy lib_auto from 0.
copy lib_nav2 from 0.
copy lib_lander from 0.
copy lib_transfer from 0.
copy launch from 0.

run lib_nav2.
run lib_lander.
run lib_transfer.
print "init Completed".

wait 5.
run launch(incl).

clearscreen.

match_plane(Mun).
run_node().
hm_trans(Mun,(mun_orbit),"prograde").
run_node().

// we are now at the target SOI
// WARPTO(ETA:TRANSITION + 60).

wait until ship:body = Mun.

set_altitude (ETA:PERIAPSIS,mun_orbit).
run_node().
set_altitude (ETA:PERIAPSIS,mun_orbit).
run_node().

land_at_position(1,150).

// Do science stuff
wait 2.

local P TO SHIP:PARTSNAMED("SensorBarometer")[0].
local M TO P:GETMODULE("ModuleScienceExperiment").
M:DEPLOY.
print "Barometer Complete".
wait 1.
local P TO SHIP:PARTSNAMED("SensorThermometer")[0].
local M TO P:GETMODULE("ModuleScienceExperiment").
M:DEPLOY.
print "Thermometer Complete".
wait 1.

local P TO SHIP:PARTSNAMED("science.module")[0].
local M TO P:GETMODULE("ModuleScienceExperiment").
M:DEPLOY.
print "Science Container Complete".
wait 1.

local P TO SHIP:PARTSNAMED("GooExperiment")[0].
local M TO P:GETMODULE("ModuleScienceExperiment").
M:DEPLOY.
print "Goo Container Complete".
wait 1.


// return home.
set ignore_autostage to true.

run launch(0).
gear off.
RCS off.

hm_return().
run_node().


// Kerbin reentry
// warpfor(ETA:TRANSITION + 60).
// warpfor(ETA:PERIAPSIS - 150).
wait until ship:body = Kerbin.

RCS on.
lock steering to retrograde.

wait until ETA:PERIAPSIS < 120.
PANELS off.

wait 1.
lock THROTTLE to 1.0.

wait until SHIP:LIQUIDFUEL < 0.1 OR SHIP:ALTITUDE < 60000.
lock THROTTLE to 0.
lock steering to prograde.
wait 5.
RCS off.
wait until SHIP:ALTITUDE < 18000.
RCS on.
lock steering to retrograde.
wait 4.
unlock steering.
RCS off.

wait until ALT:RADAR < 1000.

gear on.
local chuteList to LIST().
local partlist to LIST().
//Gets all of the parts on the craft
LIST PARTS IN partList.
FOR item IN partList {

    LOCAL moduleList TO item:MODULES.
    FOR module IN moduleList {
        IF module = "RealchuteModule" {
            chuteList:ADD(item).

        }.

    }.

}
FOR chute IN chuteList {

	if chute:GETMODULE("RealchuteModule"):HASEVENT("Deploy Chute") {
	chute:GETMODULE("RealchuteModule"):DOEVENT("Deploy Chute").
	}
}
