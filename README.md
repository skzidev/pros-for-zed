# PROS for Zed

This is a high-performance alternative to the VSCode PROS extension, meant to bring PROS to the GPU-accelerated Zed editor.

It currently has commands for
- Building
- Uploading
- Building & Uploading
- Force building (overrides build skipping)
- Cleaning
- Renaming a robot
- Taking a screenshot of the Brain screen
- Opening the Brain's terminal
- Running the current program
- Stopping the current program

> [!NOTE]
> These tasks have only been tested on Linux.
> These tasks expect the VSCode PROS extension to be installed and a toolchain installed with that extension. Using with an externally-installed toolchain means you cannot use the configuration script.

## Prerequisites: 
- the Zed editor.
- PROS for VSCode and the toolchain installed by it
You can get away with not having the extension, as long as its toolchain is installed and configured. These macros just use the toolchain.
- the PROS CLI
required for most commands and interacting with the V5 brain.
- A Python interpreter

## Installation

1. Clone into this repository with `git clone https://github.com/skzidev/pros-for-zed.git` (or just download the tasks.json and configuration script in the same folder)
2. Run the configuration script with `python ./configure.py`
3. Assuming you have the toolchain installed, the configuration script should pick up on it and change `tasks.json`. This step hardcodes the path into `tasks.json` so that Zed can find the toolchain
4. Copy/paste `tasks.json` into a new `.zed` subfolder in your project directory
5. Open your project with Zed. You can run the commands with `Alt+Shift+T`, or by using the command palette and typing `spawn task`, then pressing enter.

Optionally, you can add keybinds for these tasks [as described here](https://zed.dev/docs/tasks#custom-keybindings-for-tasks)
