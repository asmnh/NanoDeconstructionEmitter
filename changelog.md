# Changelog

## 0.1.0

- First implementation of deconstruction emitter that uses nanobots for executing deconstruction orders in range.
- Deconstruction cost set up to be 1 ammo per every entity + 1 ammo per every item stack inside entity.
- Range set to base of 100 with +25 per every level of nanobot range.
- Pooling speed set to 2/s, each level of nanobot speed adding 10%.
- Recipe set to 8 steel chests + 5 nano emitters + 20 electronic circuits.
- Mining/picking up deconstruction emitter will give you back only steel chests, both nano emitters and electronic circuits are lost.
- Tiles marked for deconstruction are ignored by deconstruction emitter. You have to tear down your sacred paths manually.
- Graphics are modified Nanobots interface.