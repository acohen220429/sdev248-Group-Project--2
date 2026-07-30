Tiles in the Background map are for visuals only, and are not able to
be interacted with.

ForegroundTileMap has all of the platforms that the player will interact
with during gameplay. The wood blocks, both stone bloacks, and the plain
grey block are all on Navigation Layer 0 as well as Physics Layer 0 for
player interatcions

A Custom Data Layer for the ForegroundTileMap has been set with a custom
*int* variable called PowerUpType. As of now the coin tile is set to 1,
the key tile to 2, and the closed chest to 3.
