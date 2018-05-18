local deconstruction_range = {[0] = 100, [1] = 125, [2] = 150, [3] = 175, [4] = 200}
local deconstruction_speeed_modifier = {[0] = 0, [1] = 3, [2] = 6, [3] = 9, [4] = 12}

local tick_separation_between_checks = 30

local teardown_interface_list = {}

local being_mined = {}

local function get_interface_range(entity)
    local modifier = entity.force.get_ammo_damage_modifier("nano-ammo")
    return deconstruction_range[modifier and modifier or 0]
end

local function get_interface_range_boundary(entity)
    local range = get_interface_range(entity)
    local b1,b2 = {},{}
    b1.x = entity.position.x - range
    b1.y = entity.position.y - range
    b2.x = entity.position.x + range
    b2.y = entity.position.y + range
    return {b1,b2}
end

local function check_ammo_status(entity)
    local ammo_amount = entity.get_item_count("ammo-nano-constructors")
    return ammo_amount > 0
end

local function use_ammo(entity, amount)
    local ammo_stack = entity.get_inventory(defines.inventory.chest).find_item_stack('ammo-nano-constructors')
    ammo_stack.drain_ammo(amount or 1)
    return check_ammo_status(entity)
end

local all_inventories = {
    defines.inventory.fuel	,
defines.inventory.burnt_result	,
defines.inventory.chest	,
defines.inventory.furnace_source	,
defines.inventory.furnace_result	,
defines.inventory.furnace_modules	,
defines.inventory.roboport_robot	,
defines.inventory.roboport_material	,
defines.inventory.robot_cargo	,
defines.inventory.robot_repair	,
defines.inventory.assembling_machine_input	,
defines.inventory.assembling_machine_output	,
defines.inventory.assembling_machine_modules,	
defines.inventory.lab_input	,
defines.inventory.lab_modules,	
defines.inventory.mining_drill_modules	,
defines.inventory.item_main	,
defines.inventory.turret_ammo	,
defines.inventory.beacon_modules	
}

local function position_to_string(pos)
    return pos.x .. 'X' .. pos.y
end

-- Attempt to insert an item_stack or array of item_stacks into the entity
-- Spill to the ground at the entity/player anything that doesn't get inserted
-- @param entity: the entity or player object
-- @param item_stacks: a SimpleItemStack or array of SimpleItemStacks to insert
-- @return bool : there was some items inserted or spilled
local function insert_or_spill_items(entity, item_stacks)
    local new_stacks = {}
    if item_stacks then
        if item_stacks[1] and item_stacks[1].name then
            new_stacks = item_stacks
        elseif item_stacks and item_stacks.name then
            new_stacks = {item_stacks}
        end
        for _, stack in pairs(new_stacks) do
            local name, count, health = stack.name, stack.count, stack.health or 1
            if game.item_prototypes[name] and not game.item_prototypes[name].has_flag("hidden") then
                local inserted = entity.insert({name = name, count = count, health = health})
                if inserted ~= count then
                    entity.surface.spill_item_stack(entity.position, {name = name, count = count - inserted, health = health}, true)
                end
            end
        end
        return new_stacks[1] and new_stacks[1].name and true
    end
end

local function on_mine_entity(player_index, entity, buffer)
    local miner_index = position_to_string(entity.position)
    local actual_miner = being_mined[miner_index]
    if actual_miner then
        for i = #buffer, 1, -1 do
            local item = buffer[i]
            if item.valid_for_read then
                actual_miner.insert(item)
            end
            item.clear()
        end
        buffer.clear()
        being_mined[miner_index] = nil
    end
end

script.on_event(defines.events.on_player_mined_entity, function (event)
    on_mine_entity(event.player_index, event.entity, event.buffer)
end
)

local function load_mod(event)
    being_mined = {}
end

script.on_load(function(event)
load_mod(event)
end
)

-- UNUSED - THERE IS BETTER METHOD TO DO THAT
local function manual_mine_entity(miner, target) 
    if miner == target then
        return false
    end
    local ammo_use = 1
    if target.has_items_inside() then
        for _,inventoryname in pairs(all_inventories) do
            local inventory = target.get_inventory(inventoryname)
            if inventory ~= nil and #inventory > 0 then
                for i = #inventory, 1, -1 do
                    miner.insert(inventory[i])
                end
                inventory.clear()
            end
        end
        -- higher ammo cost for item with elements inside
        ammo_use = 5
    end
    
    use_ammo(miner, ammo_use)

    -- TODO: check for deconstructible_tile_proxy and properly mine it
    if target.type == 'deconstructible-tile-proxy' then
        return false
    else
        being_mined[position_to_string(target.position)] = miner
        miner.force.players[1].mine_entity(target, true)
        
        return true
    end
    
end

local function scan_down_items_for_deconstruction()
    local teardown_interfaces = game.surfaces[1].find_entities_filtered{name = "nanobot-deconstruction-emitter"}
    for _,iface in pairs(teardown_interfaces) do
        if not iface.to_be_deconstructed(iface.force) then
            -- check if we have nanobots
            if check_ammo_status(iface) then
                local found_something
                local range = get_interface_range_boundary(iface)
                for _,item in pairs(game.surfaces[1].find_entities_filtered{area=range}) do
                    if item.to_be_deconstructed(iface.force) then
                        if manual_mine_entity(iface, item) then
                            found_something = true
                            break
                        end
                    end
                end
                if not found_something then
                    -- try tiles
                    -- nothing in teardown interface range at the moment, we could make it go sleep to save some performance
                end
            end
        end
    end
end

local function on_tick(event)
    if event.tick % (tick_separation_between_checks+1) == 0 then
        scan_down_items_for_deconstruction()
    end
end

script.on_event(defines.events.on_tick, function (event)
on_tick(event)
end
)