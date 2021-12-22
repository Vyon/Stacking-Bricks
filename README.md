# Stacking Bricks
Stacking Bricks is a game made by @Vyon or VyonEXE, majority of this code isn't in the cleanest state but I urge you to take a gander through it and use what you would like.

## Game Jam Information
Host: foshes (SuperJoshiePartyAnimal123)
Discord: https://discord.gg/p22kRd42
Theme: The Tower

## Background Information
There are 2 versions of this game the original client only version and the version that is most similar to an actual game. The current release uses OOP to easily manage game sessions.

## Client Player Breakdown
This game is made with OOP, the script will create the game object and start the game when the "control" button is clicked. This makes it a bit nicer to play. In v1 the game automatically played itself which I would think is not very fun. To make updating UI elements a little bit easier I decided to approach with signals. If you haven't dealt with custom signals and want to learn how, "Signal.lua" is the place for you.
Anyway I have some game events like Starting, Ending, Chance, and Height. These events are used for updating the UI elements quickly and only when necessary. As far as sounds go the little module for that has some normal things that load but I also have some music that goes hard :)

## 12/21/2021 release
Switched the game from only being client sided to having a mix of both, I also added the ability to save data using "ProfileService". Caching was added to easily manage the session object. To conclude this release's notes a daily reward system was implemented, the system increases the value of the reward based on how many days the player has logged in.