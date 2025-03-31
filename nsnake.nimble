# Package

version       = "0.1.0"
author        = "Loïc Bartoletti"
description   = "A terminal-based Snake game written in Nim using illwill for curses-style graphics"
license       = "MIT"
srcDir        = "src"
bin           = @["nsnake"]


# Dependencies

requires "nim >= 2.2.0"
requires "illwill"
