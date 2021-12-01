# Stacking Bricks
Stacking Bricks is a game made by @Vyon or VyonEXE, majority of this code isn't in the cleanest state but I urge you to take a gander through it and use what you would like.

## Game Jam Information
Host: foshes (SuperJoshiePartyAnimal123)
Discord: https://discord.gg/p22kRd42
Theme: The Tower

## Background Information
The game is completely client sided and before anyone tries to complain about me doing that there is no data that is saved and each individual player interacts with only themselves as far as gameplay goes. The server size is 50 so people can hangout and chat in the servers but they don't have to be in each others way.

## Source breakdown
This game is made with OOP the script will create the game object and start the game when the "control" button is clicked. This makes it a little bit easier to play in v1 the game automatically played itself which I would think is not very fun. To make updating UI elements a little bit easier I decided to approach with signals. If you haven't dealt with custom signals and want to learn how "Signal.lua" is the place for you.
Anyway I have some game events like Starting, Ending, Chance, and Height. These events are used for updating the UI elements quickly and only when necessary. As far as sounds go the little module for that has some normal things that load but I also have some other things :)