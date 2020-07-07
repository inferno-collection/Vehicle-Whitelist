-- Inferno Collection Vehicle Whitelist Version 1.1 Beta
--
-- Copyright (c) 2019, Christopher M, Inferno Collection. All rights reserved.
--
-- This project is licensed under the following:
-- Permission is hereby granted, free of charge, to any person obtaining a copy of this software and associated documentation files (the "Software"), to use, copy, modify, and merge the software, under the following conditions:
-- The above copyright notice and this permission notice shall be included in all copies or substantial portions of the Software.
-- THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY, FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM, OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE SOFTWARE. THE SOFTWARE MAY NOT BE SOLD.
--

--
-- Resource Configuration
-- Please note, there is also some configuration required in the
-- `client.lua` file, so make sure to edit that file as well
--
-- PLEASE RESTART SERVER AFTER MAKING CHANGES TO THIS CONFIGURATION
--

local Config = {} -- Do not edit this line
Config.Passwords = {} -- Do not edit this line

-- Password for Police vehicles
Config.Passwords.police = "p"

-- Password for Fire/EMS vehicles
Config.Passwords.fireems = "f"

-- Password for Military vehicles
Config.Passwords.military = "m"

-- Password for custom vehicles
Config.Passwords.custom = "c"

--
--		Nothing past this point needs to be edited, all the settings for the resource are found ABOVE this line.
--		Do not make changes below this line unless you know what you are doing!
--

local Allowed = {}
Allowed.police = {}
Allowed.fireems = {}
Allowed.military = {}
Allowed.custom = {}

-- Unlock command
RegisterCommand("unlock", function(source, Args)
    if Args[1] then
        local Class = Args[1]:lower()

        if Class == "police" or Class == "fireems" or Class == "military" or Class == "custom" then
            if Args[2] then
                if not Allowed[Class][source] then
                    local Password = Args[2]

                    if Config.Passwords[Class] == Password then
                        Allowed[Class][source] = true

                        TriggerClientEvent("Vehicle-Whitelist:Message", source, "~g~Access to " .. Args[1] .. " vehicles granted!", false)
                    else
                        TriggerClientEvent("Vehicle-Whitelist:Message", source, "~r~Password incorrect!", true)
                    end
                else
                    TriggerClientEvent("Vehicle-Whitelist:Message", source, "~g~You already have access to " .. Args[1] .. " vehicles!", false)
                end
            else
                TriggerClientEvent("Vehicle-Whitelist:Message", source, "~r~No password provided!", true)
            end
        else
            TriggerClientEvent("Vehicle-Whitelist:Message", source, "~r~" .. Args[1] .. " is not a valid vehicle class!", true)
        end
    else
        TriggerClientEvent("Vehicle-Whitelist:Message", source, "~r~No arguments provided!", true)
    end
end)

-- Check if client is allowed to drive a vehicle type
RegisterServerEvent("Vehicle-Whitelist:Check")
AddEventHandler("Vehicle-Whitelist:Check", function(VehicleType)
    TriggerClientEvent("Vehicle-Whitelist:Return:Check", source, Allowed[VehicleType][source])
end)