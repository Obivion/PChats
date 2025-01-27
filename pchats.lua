-- PartyChats Addon

_addon.name = 'PartyChats'
_addon.author = 'Obi The Magnificent'
_addon.version = '0.4'
_addon.command = 'pchats'

require 'tables'
require 'sets'
require 'strings'
require 'actions'
require 'pack'
res = require 'resources'

-- Debug mode variable (0 = off, 1 = on)
local debug_mode = 0

-- Variables for message probabilities and toggles
local fun_chance = 0.30  -- Default: 30% chance for fun messages
local unique_chance = 0.10  -- Default: 10% chance for unique messages
local enable_critical = true  -- Default: Enable critical messages
local enable_fun = true  -- Default: Enable fun messages
local enable_unique = true  -- Default: Enable unique messages

-- Function to load a theme from the themes folder
local function load_theme(name)
    local theme_file = windower.addon_path .. 'themes/' .. name .. '.lua'
    local success, theme = pcall(dofile, theme_file)
    if success then
        windower.add_to_chat(207, string.format('Theme "%s" loaded successfully.', name))
        if theme.description then
            windower.add_to_chat(207, string.format('Description: %s', theme.description))
        end
        return theme
    else
        windower.add_to_chat(207, string.format('Failed to load theme "%s". Falling back to default.', name))
        return dofile(windower.addon_path .. 'themes/default.lua')
    end
end

-- Load the default theme
local theme_name = 'default'
local message_table = load_theme(theme_name)

-- Function to handle commands
windower.register_event('addon command', function(command, ...)
    local args = {...}
    if command == 'debug_mode' then
        debug_mode = 1 - debug_mode  -- Toggle between 0 and 1
        windower.add_to_chat(207, string.format('Debug mode is now %s', debug_mode == 1 and 'ON' or 'OFF'))
    elseif command == 'fun_chance' then
        local chance = tonumber(args[1])
        if chance and chance >= 0 and chance <= 1 then
            fun_chance = chance
            windower.add_to_chat(207, string.format('Fun message chance set to %.0f%%', fun_chance * 100))
        else
            windower.add_to_chat(207, 'Invalid value for fun_chance. Must be between 0 and 1.')
        end
    elseif command == 'unique_chance' then
        local chance = tonumber(args[1])
        if chance and chance >= 0 and chance <= 1 then
            unique_chance = chance
            windower.add_to_chat(207, string.format('Unique message chance set to %.0f%%', unique_chance * 100))
        else
            windower.add_to_chat(207, 'Invalid value for unique_chance. Must be between 0 and 1.')
        end
    elseif command == 'enable_critical' then
        enable_critical = not enable_critical  -- Toggle critical messages
        windower.add_to_chat(207, string.format('Critical messages %s.', enable_critical and 'enabled' or 'disabled'))
    elseif command == 'enable_fun' then
        enable_fun = not enable_fun  -- Toggle fun messages
        windower.add_to_chat(207, string.format('Fun messages %s.', enable_fun and 'enabled' or 'disabled'))
    elseif command == 'enable_unique' then
        enable_unique = not enable_unique  -- Toggle unique messages
        windower.add_to_chat(207, string.format('Unique messages %s.', enable_unique and 'enabled' or 'disabled'))
    elseif command == 'theme' then
        local new_theme = args[1]
        if new_theme then
            theme_name = new_theme
            message_table = load_theme(theme_name)
        else
            windower.add_to_chat(207, 'Please specify a theme name.')
        end
    end
end)

-- Function to select a random message from a table or return the message itself
local function get_random_message(messages)
    if type(messages) == 'table' then
        return messages[math.random(#messages)]  -- Randomly select one message from the table
    else
        return messages  -- Return the single message
    end
end

-- Function to select a message based on classifications
local function select_message(message_data, category)
    if not message_data then return nil end

    -- Handle Category 4 (finish casting spells) separately
    if category == 4 then
        if message_data.after_mes then
            local after_mes_data = message_data.after_mes
            -- Check for unique message (if enabled and chance is met)
            if enable_unique and after_mes_data.unique and math.random() <= unique_chance then
                return get_random_message(after_mes_data.unique)
            end

            -- Check for fun message (if enabled and chance is met)
            if enable_fun and after_mes_data.fun and math.random() <= fun_chance then
                return get_random_message(after_mes_data.fun)
            end

            -- Fall back to critical message (if enabled)
            if enable_critical and after_mes_data.critical then
                return get_random_message(after_mes_data.critical)
            end

            -- No message available
            return nil
        else
            return nil  -- No after_mes defined, so don't send a message
        end
    end

    -- Check for unique message (if enabled and chance is met)
    if enable_unique and message_data.unique and math.random() <= unique_chance then
        return get_random_message(message_data.unique)
    end

    -- Check for fun message (if enabled and chance is met)
    if enable_fun and message_data.fun and math.random() <= fun_chance then
        return get_random_message(message_data.fun)
    end

    -- Fall back to critical message (if enabled)
    if enable_critical and message_data.critical then
        return get_random_message(message_data.critical)
    end

    -- No message available
    return nil
end

windower.register_event('action', function(act)
    local actor = windower.ffxi.get_mob_by_id(act.actor_id)
    local self = windower.ffxi.get_player()
    local targets = act.targets

    -- Ensure the action is performed by the player
    if actor.name == self.name then
        if targets and targets[1] then
            local primarytarget = windower.ffxi.get_mob_by_id(targets[1].id)
            local param = act.param
            local category = act.category

            -- Display target information
            local targetInfo = string.format('Target: %s (ID: %d)', primarytarget.name, primarytarget.id)

            -- Only display debug information if debug_mode is 1
            if debug_mode == 1 then
                if category == 7 then  -- Weapon skill
                    if res.weapon_skills[targets[1].actions[1].param] then
                        windower.add_to_chat(207, string.format('%s %s: %s uses %s on %s', MSG_READY_MOVE, category, actor.name, res.weapon_skills[targets[1].actions[1].param].en, targetInfo))
                    end
                elseif category == 8 then  -- Start casting spell
                    if res.spells[targets[1].actions[1].param] then
                        windower.add_to_chat(207, string.format('%s %s: %s begins casting %s (%s) on %s', MSG_BEGIN_CAST, category, actor.name, res.spells[targets[1].actions[1].param].en, res.skills[res.spells[targets[1].actions[1].param].skill].en, targetInfo))
                    end
                elseif category == 6 or category == 13 or category == 14 or category == 15 then  -- Job abilities
                    if res.job_abilities[param] then
                        windower.add_to_chat(207, string.format('%s %s: %s uses %s on %s', MSG_READY_MOVE, category, actor.name, res.job_abilities[param].en, targetInfo))
                    end
                end
            end

            -- Check for predefined messages and send to party chat
            local action_name
            if category == 7 then  -- Weapon skill
                action_name = res.weapon_skills[targets[1].actions[1].param] and res.weapon_skills[targets[1].actions[1].param].en
            elseif category == 8 then  -- Start casting spell
                action_name = res.spells[targets[1].actions[1].param] and res.spells[targets[1].actions[1].param].en
            elseif category == 4 then  -- Finish casting spell
                action_name = res.spells[param] and res.spells[param].en
            elseif category == 6 or category == 13 or category == 14 or category == 15 then  -- Job ability
                action_name = res.job_abilities[param] and res.job_abilities[param].en
            end

            if action_name and message_table[action_name] then
                local message_data = message_table[action_name]
                local message = select_message(message_data, category)

                if message then
                    message = message:gsub("PLAYER", actor.name)  -- Replace PLAYER with the actor's name
                    message = message:gsub("TARGET", primarytarget.name)  -- Replace TARGET with the target's name
                    windower.send_command('input /p ' .. message)  -- Send the message to party chat
                end
            end
        end
    end
end)