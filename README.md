# PROS for Zed

PROS, brought to the GPU-accelerated Zed editor.

## Installation

The installer sets up the PROS CLI, ARM toolchain, VEXCOM, and Zed task templates.

```sh
curl -fsSL "https://raw.githubusercontent.com/skzidev/pros-for-zed/refs/heads/main/install.sh" | sh
```

> [!NOTE]
> These tasks have only been tested on Linux, and the install script only works on Linux (and maybe MacOS, although it has not been tested).


## Usage

Install the Zed task definitions by running this command in your PROS project directory:

```sh
pros-zed init
```

Optionally, you can add keybinds for these tasks [as described here](https://zed.dev/docs/tasks#custom-keybindings-for-tasks).

It currently has commands for:
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
