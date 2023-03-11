<h1 align="center">
  <img src="https://user-images.githubusercontent.com/4662876/221683471-d472d9c0-7d19-4e46-a7fd-44dcfd59ebd9.png" alt="sk3ditor">
     <div><strong>sk3ditor</strong></div>
</h1>

`sk3ditor` is a handy, dandy coding Swiss army knife. It's intended to provide a seamless, hassle-free development experience. Conceptually, `sk3fditor` is a collection of coding tools, along with the Neovim editor, bundled inside a Docker container.

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

## Building sk3ditor
Build the sk3ditor image (tagged `sk3l/sk3ditor:latest`)
```
make build
```

## Running sk3ditor
Run sk3ditor with a shared mount between host `/home/kilroy/code` and `/home/kilroy/code` in the container
```
CODE_DIR=/home/kilroy/code make run
```

See the top section of `sk3ditor.dockerfile` for a list of runtime parameters

## TODO
- install packages supporting linting/fixing via Neovim ALE LSP
  - ~Python3 packages~
  - ~Javascript/Node packages~
  - ~Gopls~
  - ~Bash-related linter/fixers~
  - ~English language linters/checkers~
- add tests, CI/CD to the Docker image construction
