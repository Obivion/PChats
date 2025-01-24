-- PartyChats Addon
--[[Copyright © 2025, Obi of Hades
All rights reserved.

Redistribution and use in source and binary forms, with or without
modification, are permitted provided that the following conditions are met:

    * Redistributions of source code must retain the above copyright
      notice, this list of conditions and the following disclaimer.
    * Redistributions in binary form must reproduce the above copyright
      notice, this list of conditions and the following disclaimer in the
      documentation and/or other materials provided with the distribution.
    * Neither the name of PartyChats nor the
      names of its contributors may be used to endorse or promote products
      derived from this software without specific prior written permission.

THIS SOFTWARE IS PROVIDED BY THE COPYRIGHT HOLDERS AND CONTRIBUTORS "AS IS" AND
ANY EXPRESS OR IMPLIED WARRANTIES, INCLUDING, BUT NOT LIMITED TO, THE IMPLIED
WARRANTIES OF MERCHANTABILITY AND FITNESS FOR A PARTICULAR PURPOSE ARE
DISCLAIMED. IN NO EVENT SHALL OBI BE LIABLE FOR ANY
DIRECT, INDIRECT, INCIDENTAL, SPECIAL, EXEMPLARY, OR CONSEQUENTIAL DAMAGES
(INCLUDING, BUT NOT LIMITED TO, PROCUREMENT OF SUBSTITUTE GOODS OR SERVICES;
LOSS OF USE, DATA, OR PROFITS; OR BUSINESS INTERRUPTION) HOWEVER CAUSED AND
ON ANY THEORY OF LIABILITY, WHETHER IN CONTRACT, STRICT LIABILITY, OR TORT
(INCLUDING NEGLIGENCE OR OTHERWISE) ARISING IN ANY WAY OUT OF THE USE OF THIS
SOFTWARE, EVEN IF ADVISED OF THE POSSIBILITY OF SUCH DAMAGE.]]

_addon.name = 'PartyChats'
_addon.author = 'Obi The Magnificent'
_addon.version = '0.5' -- Updated version
_addon.command = 'pchats'

require 'tables'
require 'sets'
require 'strings'
require 'actions'
require 'pack'
require 'logger'
res = require 'resources'
files = require 'files'

--Variables

pchatsrun = 0
funmode = 0 -- Variable for fun mode
current_theme = 'default' -- Variable to store the current theme
force_critical = 0  -- New variable: force_critical
force_fun = 0  -- New variable: force_fun

windower.register_event('action', function(act)
    -- Check if the addon is running
    if pchatsrun == 1 then
        -- Get information about the action
        local actor = windower.ffxi.get_mob_by_id(act.actor_id)
        local self = windower.ffxi.get_player()
        local target_count = act.target_count
        local category = act.category
        local param = act.param
        local recast = act.recast
        local targets = act.targets
        local primarytarget = windower.ffxi.get_mob_by_id(targets[1].id)
        local valid_target = act.valid_target

        -- Check if the action was performed by the player
        if actor.name == self.name then
            local message_data = nil -- Initialize variable to store message data
            local ability_messages = require('themes/' .. current_theme) -- Load the current theme's messages

            -- Check the action category and retrieve the corresponding message data
            if act.category == 6 and res.job_abilities[act.param] then -- Job ability
                local ability_name = res.job_abilities[act.param].en -- Get the ability name
                message_data = ability_messages[ability_name] -- Get the message data from the table
            elseif act.category == 8 and res.spells[targets[1].actions[1].param] then -- Spell
                local spell_name = res.spells[targets[1].actions[1].param].en -- Get the spell name from the nested actions table
                message_data = ability_messages[spell_name] -- Get the message data from the table
            elseif act.category == 7 and res.job_abilities[act.param] then -- Weapon skill
                local ability_name = res.job_abilities[act.param].en -- Get the weapon skill name
                message_data = ability_messages[ability_name] -- Get the message data from the table
            end

            -- If message data was found for the action
			if message_data then
				if message_data.type == 'critical' and force_critical == 1 then  -- Force critical messages
					local messages = message_data.messages
					local selected_message = messages[math.random(#messages)]
					windower.send_command('p ' .. selected_message.message)
				elseif message_data.type == 'fun' and funmode == 1 then  -- Fun messages
					local messages = message_data.messages
					local selected_message = messages[math.random(#messages)]
					if force_fun == 100 or math.random(100) <= force_fun or math.random(100) <= selected_message.chance then
						windower.send_command('p ' .. selected_message.message)
					end
				end
			end
        end
    end
end)

windower.register_event('addon command', function(command, ...)
    local args = L{...}

    if command:lower() == 'forcecrit' then
        force_critical = (force_critical == 0) and 1 or 0
        windower.add_to_chat(7, (force_critical == 1) and "Force Critical: Always On" or "Force Critical: Normal Mode")
    end

if command:lower() == 'forcefun' then
    local fun_levels = { 0, 10, 25, 50, 100 }  -- Available fun levels
    local current_index = table.find(fun_levels, force_fun) or 1  -- Find current level or default to 1
    local next_index = current_index % #fun_levels + 1  -- Calculate next index, wrapping around
    force_fun = fun_levels[next_index]  -- Set force_fun to the next level

    -- Display the current force_fun level
    local fun_message = "Force Fun: " .. (force_fun > 0 and force_fun .. "%" or "Normal Mode")
    windower.add_to_chat(7, fun_message)
end
	
    if command:lower() == 'chat' then -- Changed command to 'chat'
        pchatsrun = (pchatsrun == 0) and 1 or 0 -- Toggle pchatsrun
        windower.add_to_chat(7, (pchatsrun == 1) and "Party Chat Addon Started" or "Party Chat Addon Stopped")
    end

    if command:lower() == 'fun' then -- Changed command to 'fun'
        funmode = (funmode == 0) and 1 or 0 -- Toggle funmode
        windower.add_to_chat(7, (funmode == 1) and "Fun Mode On" or "Fun Mode Off")
    end

	if command:lower() == 'theme' then
		local theme = args[1]
		if theme then
			-- Construct the correct relative path to the theme file
			local theme_file = 'themes/' .. theme .. '.lua' 
			if files.new(theme_file):exists() then
				current_theme = theme
				windower.add_to_chat(7, 'Theme set to: ' .. theme)
			else
				windower.add_to_chat(7, 'Error: Theme "' .. theme .. '" not found.')
			end
		else
			windower.add_to_chat(7, 'Usage: //pchats theme <theme_name>')
		end
	end
end)