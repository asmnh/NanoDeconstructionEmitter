require("prototypes.deconstruction-emitter")

local effects = data.raw.technology["nano-range-2"].effects
effects[#effects + 1] = {type = "unlock-recipe", recipe="nanobot-deconstruction-emitter"}
