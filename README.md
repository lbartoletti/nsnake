# nsnake
<a href="https://codeberg.org/lbartoletti/nsnake">
    <img alt="Get it on Codeberg" src="https://get-it-on.codeberg.org/get-it-on-blue-on-white.png" height="60" align="right">
</a>

[![Issue Tracker](https://img.shields.io/badge/Issue_tracker-Codeberg-blue.svg)](https://codeberg.org/lbartoletti/nsnake/issues) 

A terminal-based Snake game written in Nim using illwill for curses-style graphics.

The main repository is on [codeberg](https://codeberg.org/lbartoletti/nsnake),
which is where the issue tracker may be found and where contributions are accepted.

Read-only mirrors exist on [sourcehut](https://git.sr.ht/~lbartoletti/nsnake)
and [github](https://github.com/lbartoletti/nsnake).

## Features

- Classic Snake gameplay in your terminal
- vim-style controls (hjkl) and arrow keys support
- High score tracking
- Cross-platform support (Windows, macOS, Linux)
- Configurable game settings
- Smooth terminal graphics using illwill

## Installation

You can install nsnake using Nimble:

```bash
nimble install nsnake
```

## Dependencies

- Nim (>= 2.0.0)
- illwill

## Usage

After installation, simply run:

```bash
nsnake
```

### Controls

- Move Up: `↑` or `k`
- Move Down: `↓` or `j`
- Move Left: `←` or `h`
- Move Right: `→` or `l`
- Restart Game: `r`
- Quit: `q` or `Esc`

## High Scores

The game automatically saves your high score in a configuration file:

- Windows: `%APPDATA%\nsnake.ini`
- macOS: `~/Library/Application Support/nsnake.ini`
- Unix/Linux: `~/.local/share/nsnake.ini`

## Building from Source

To build from source:

```bash
git clone https://github.com/lbartoletti/nsnake.git
cd nsnake
nimble build
```

## License

This project is released under the MIT License. See the LICENSE file for details.

## Contributing

Contributions are welcome! Please feel free to submit a Pull Request.

## Author

- lbartoletti (Loïc Bartoletti)

## Acknowledgments

- Thanks to the creators of illwill for providing the terminal graphics library
- Inspired by the classic Snake game
