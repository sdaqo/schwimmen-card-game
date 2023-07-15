# Schwimmen Card Game & Server

This card game is based of a popular german & austrian card game called [Schwimmen](https://en.wikipedia.org/wiki/Schwimmen) (eng. swimming) and can be played offline or online.


https://github.com/sdaqo/schwimmen-card-game/assets/63876564/8f41e4e3-4527-4db8-9842-468975cafd91





## Game Setup

### Using the Binary
-  Download the latest binary release for your platform (note: files with -java at the end include Java 17, download them if you dont have Java 17 installed)
- Extract the archive and start the game.

### Using Processing
- Download & Install [processing4](https://processing.org/download)
- Clone this repo
- Open the Processing Project (the card_game folder) in processing4 and run or build it. You can also use the [`processing-java`](https://github.com/processing/processing/wiki/Command-Line) cli tool to run/build the project.

### Custom Music
If you want to listen to music put some into the `data/music` folder. In game click on Toggle Music to Start it. If you use mp3 files you have to wait a bit after clicking toggle muic as it takes some time tos decode the mp3. It is recommended to not use mp3 but wav or aif.

## Server Setup
As with the Game Setup, get the binary from the releases or build it yourself with processing4.

To Start the Server:
```shell
# Optionally customize these environment variables to change the default port and host

# For Linux:
export SCHWIMMEN_PORT=1111
export SCHWIMMEN_HOST="127.0.0.1"

# For Windows:
set SCHWIMMEN_PORT=1111
set SCHWIMMEN_HOST="127.0.0.1"

./card_game-server
```
