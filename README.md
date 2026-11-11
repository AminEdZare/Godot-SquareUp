# Square Up (Godot port)

Top-down arena shooter. This is a Godot 4 port of the Unity 2018 original
(<https://github.com/AminEdZare/Unity-SquareUp>), rebuilt from that project's
scripts, prefabs and scene so it plays the same.

## Run it

1. Install **Godot 4.7** (standard build, not .NET) from <https://godotengine.org/download>.
2. Open Godot, choose **Import**, and pick `project.godot` in this folder.
3. Press **F5** (or the Play button) to run.

Or just double-click `build/Square Up.app` (the ready-made Mac build, if present).

## Make a Mac build

In Godot: **Project → Export…**, pick the **macOS** preset, then **Export Project**.
The first time, Godot will ask to download the export templates (about 1.3 GB).
The preset writes `build/Square Up.app`, a universal (Apple Silicon + Intel) app
with an ad-hoc signature: fine on your own Mac, but sharing it with other people
needs an Apple Developer ID to sign and notarize it.

## Controls

| Action | Input |
| --- | --- |
| Move | WASD / arrow keys / left stick / d-pad |
| Aim | Mouse |
| Shoot | Left mouse button (one shot per click) |
| Toggle fullscreen | F11 or Alt/Option + Enter (the game starts fullscreen) |

## Layout

```
assets/    sprites, tile sheet, font, UI theme
scenes/    one scene per Unity prefab, plus main.tscn (was SampleScene)
scripts/   GDScript, one file per behaviour
```

| Unity | Godot |
| --- | --- |
| `PlayerController.cs`, `Boundaries.cs`, `Health.cs` | `scripts/player.gd` |
| `Weapon.cs` | `scripts/weapon.gd` |
| `PlayerProjectile.cs` | `scripts/player_projectile.gd` |
| `EnemyIQ.cs` | `scripts/enemy.gd` |
| `Enemy01Proj.cs` | `scripts/enemy_projectile.gd` |
| `EnemySpawner.cs` | `scripts/enemy_spawner.gd` |
| `Score.cs`, `GameOverScreen.cs`, heart display | `scripts/hud.gd` |
| `GameController.cs` | `scripts/main.gd` |
| static `Score.scoreValue` | `scripts/game.gd` (autoload `Game`) |
| 9 ParticleSystem prefabs | `scripts/burst_effect.gd` + `scenes/effects/*.tscn` |
| Orthographic camera, size 5 | `scripts/game_camera.gd` |
| Tags `Player` / `Enemy` | Groups `player` / `enemy` |
| Layer 8 (enemies) | Physics layer 2 `enemy` (layer 1 is `player`) |

## Units

The Unity project used 100 pixels per unit, and so does this one: every
distance and speed is the Unity inspector value times 100 (player speed 5.5
became 550 px/s). All tunable numbers are exported, so they show up in the
Inspector on each scene's root node, grouped the way the Unity headers were.

## Things kept on purpose

- The gun is semi-automatic with a 0.25 s cooldown; clicks during the cooldown are dropped.
- Player shots only travel 2.5 units (0.5 s at 5 units/s).
- Enemy shots home in on you and are slightly slower than you are.
- Enemies overlap each other and do no contact damage.
- After you die the spawner stops, enemies freeze, and shots in the air hang until they time out.
- The camera is fixed and always shows 10 units of height; the play area is whatever fits on screen.

## Credits

- Game and art: AminEdZare (original Unity project linked above).
- Font: ThaleahFat by Rick Hoppmann (see `assets/fonts/ThaleahFat_Readme.pdf`).
