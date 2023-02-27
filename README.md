# sk3ditor - Dockerized software dev multitool 
The `sk3ditor` is a handy, dandy coding Swiss army knife. It's intended to provide a seamless, hassle-free development experience. 

**Features:**
- portable
  - runs anywhere you can put Docker and GNU Make
- convenient
  - run it without Docker knowledge using GNU MAKE commands
- smart
  - eliminates tracking differing package names for the package manager serving your host system
- configurable 
  - customize user name, editor, shell, etc

The default editor program bundled with the image (along with my config settings) is [Neovim](https://neovim.io/).

## Build it
```
make build
```

## Run it
```
make run
```

See the top section of `sk3ditor.dockerfile` for a list of runtime parameters

## TODO
- install packages supporting linting/fixing via Neovim ALE LSP
 - Python3 packages
 - Javascript/Node packages
 - Gopls
 - Bash-related linter/fixers
 - English language linters/checkers
