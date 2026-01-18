#!/usr/bin/env python3

if(__name__ != "__main__"):
	print("please run as main script")
	exit(1)

print("this script will (by default) uses the PROS toolchain installed by the PROS VSCode extension.")
r = input("do you have this toolchain installed? ")
if(r.lower() not in ["y", "n", "yes", "no"]):
	print(f"unknown response '{r}'. aborting.")
	exit(1)

def no_toolchain():
	# TODO install toolchain
	print("this script does not yet support installing the PROS toolchain. sorry!")
	print("please install the PROS toolchain through VSCode first.")
	exit(1)

if r == 'n' or r == 'no':
	no_toolchain()

import os
from pathlib import Path

platformToCodepath = {
	"linux": f"{Path.home()}/.config/Code/User/globalStorage/sigbots.pros/install/pros-toolchain-linux/bin",
	"win32": f"{Path.home()}\\AppData\\Roaming\\Code\\User\\globalStorage\\sigbots.pros\\install\\pros-toolchain-win\\bin"
	# no macos yet.
}

from sys import platform

codepath = platformToCodepath[platform]
if codepath == None:
	print("unknown platform. sorry!")
	exit(1)

print(f"looking for toolchain in {codepath}")

if not Path(os.path.join(codepath, "arm-none-eabi-gcc")).is_file():
	print('did not find toolchain. please install it through the PROS VSCode extension or this script when support is added.')
	exit(1)


if(platform == "win32"):
	codepath += ";" + os.getenv("path", "C:\\Windows\\System32")
elif(platform == "linux"):
	codepath += ":/usr/bin"

import json

with open("./tasks.json", "r+") as f:
	tasks = json.load(f)
	for task in tasks:
		if("env" not in task):
			continue
		task["env"]["PATH"] = task["env"]["PATH"].replace("{TOOLCHAIN_PATH}", codepath)
	f.seek(0)
	json.dump(tasks, f)

print("configuration successful")
print("now, use 'tasks.json' in your PROS project. Place it in {ProjectRoot}/.zed/tasks.json")