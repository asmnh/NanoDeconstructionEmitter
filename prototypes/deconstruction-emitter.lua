local warehouseItem = table.deepcopy(data.raw.item["roboport-interface"])

warehouseItem.name = "nanobot-deconstruction-emitter"
warehouseItem.order = "a[nanobot-deconstruction-beacon]"
warehouseItem.place_result = "nanobot-deconstruction-emitter"

-- angels licensing is ND, so we're just making it as container based on steel chests instead of using warehouse graphics and recipe

local warehouseContainer = {
    type = "container",
    name = "nanobot-deconstruction-emitter",
    icon = "__NanobotDeconstructionEmitter__/graphics/icons/deconstruction-emitter.png",
    icon_size = 32,
    inventory_size = 384,
    minable = {hardness = 0.2, mining_time = 15, result = "steel-chest", amount = 8},
    max_health = 500,
    corpse = "small-remnants",
    collision_box = {{-0.9, -0.9}, {0.9, 0.9}},
    selection_box = {{-1, -1}, {1, 1}},
    dying_explosion = "medium-explosion",
    picture = {
        filename = "__NanobotDeconstructionEmitter__/graphics/entity/deconstruction-emitter.png",
        scale = .50,
        priority = "medium",
        width = 256,
        height = 448,
        apply_projection = false,
        animation_speed = .15,
        frame_count = 32,
        line_length = 8,
        shift = {0.4, -2.0}
    },
    animation = {
        filename = "__NanobotDeconstructionEmitter__/graphics/entity/deconstruction-emitter.png",
        scale = .50,
        priority = "medium",
        width = 256,
        height = 448,
        apply_projection = false,
        animation_speed = .15,
        frame_count = 32,
        line_length = 8,
        shift = {0.4, -2.0}
    },
    base = nil,
    base_animation =
    {
        filename = "__NanobotDeconstructionEmitter__/graphics/entity/deconstruction-emitter.png",
        scale = .50,
        priority = "medium",
        width = 256,
        height = 448,
        apply_projection = false,
        animation_speed = .15,
        frame_count = 32,
        line_length = 8,
        shift = {0.4, -2.0}
    }
}

local recipe_warehouse = {
    type = "recipe",
    name = "nanobot-deconstruction-emitter",
    enabled = true,
    energy_required = 30,
    ingredients = 
    {
        {"steel-chest", 8},
        {"gun-nano-emitter", 5},
        {"electronic-circuit", 20}
    },
    result = "nanobot-deconstruction-emitter"
}

data:extend{warehouseItem,warehouseContainer,recipe_warehouse}