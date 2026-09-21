# Architecture

`SkeeBoard.score_m` maps a landing on the board plane to 100/50/40/30/20/10 or miss. Holes are tested in descending value. The 10 bed is the remaining in-play rectangle.

`SkeeEngine.apply_landing` keys on `ball_id` so one ball cannot score twice. Classic and precision consume nine balls. Timed uses a 60s clock.

The 3D roll is cinematic. The recorded score is the intended landing after aim noise.
