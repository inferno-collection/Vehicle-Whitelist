-- Inferno Collection Vehicle Whitelist Version 1.0 Alpha
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
-- `server.lua` file, so make sure to edit that file as well
--
-- PLEASE RESTART SERVER AFTER MAKING CHANGES TO THIS CONFIGURATION
--

local Config = {} -- Do not edit this line
Config.Whitelisted = {} -- Do not edit this line

-- List of vehicle names to be whitelisted to police
Config.Whitelisted.Police = {
    "FBI",
    "FBI2",
    "PBus",
    "police",
    "police2",
    "police3",
    "police4",
    "PoliceOld1",
    "PoliceOld2",
    "PoliceT",
    "Policeb",
    "Polmav",
    "Pranger",
    "Predator",
    "Riot",
    "Sheriff",
    "Sheriff2"
}

-- List of vehicle names to be whitelisted to Fire and EMS
Config.Whitelisted.FireEMS = {
    "Ambulance",
    "FireTruk" -- Not a typo, this is the spawn name
}

-- List of vehicle names to be whitelisted to Military
Config.Whitelisted.Military = {
    "APC",
    "Barracks",
    "Barracks2",
    "Crusader",
    "Halftrack",
    "Rhino"
}

-- Custom list of vehicle names to be whitelisted
Config.Whitelisted.Custom = {
    "Insurgent",
    "Insurgent2",
    "Dump",
    "Blimp",
    "Blimp2"
}

--
--		Nothing past this point needs to be edited, all the settings for the resource are found ABOVE this line.
--		Do not make changes below this line unless you know what you are doing!
--

local Player = {}
Player.Vehicle = {}

-- On client join server
AddEventHandler("onClientMapStart", function()
    TriggerEvent("chat:addSuggestion", "/unlock", "Type a vehicle type/class and password to unlock that vehicle type/class.", {
        { name = "type/class", help = "Police FireEMS Military Custom" },
        { name = "password", help = "The password for this type/class" }
    })
end)

-- Draw message on client screen
RegisterNetEvent("Vehicle-Whitelist:Return:Message")
AddEventHandler("Vehicle-Whitelist:Return:Message", function(Message, Flash)
    -- Tell GTA that a string will be passed
    SetNotificationTextEntry("STRING")
    -- Pass temporary variable to notification
    AddTextComponentString(Message)
    -- Draw new notification on client's screen
    DrawNotification(Flash, true)
end)

-- Return for vehicle allowed check
RegisterNetEvent("Vehicle-Whitelist:Return:Check")
AddEventHandler("Vehicle-Whitelist:Return:Check", function(Allowed)
    if not Allowed then
        ClearPedTasksImmediately(Player.Ped)
        TriggerEvent("Vehicle-Whitelist:Return:Message", "~r~You are not allowed to use this vehicle.", true)
        Player.Vehicle.Allowed = false
    else
        Player.Vehicle.Allowed = true
    end
end)

Citizen.CreateThread(function()
    while true do
        Citizen.Wait(0)

        Player.Ped = PlayerPedId()
        Player.Vehicle.Entity = GetVehiclePedIsTryingToEnter(Player.Ped)

        -- If player is trying to enter a vehicle
        if Player.Vehicle.Entity ~= 0 then
            if not Player.Vehicle.Allowed or Player.Vehicle.Last ~= Player.Vehicle.Entity then
                Player.Vehicle.Last = Player.Vehicle.Entity
                Player.Vehicle.Hash = GetEntityModel(Player.Vehicle.Entity)

                local Found = false

                -- Loop though all the police vehicles
                for _, Vehicle in ipairs(Config.Whitelisted.Police) do
                    if not Found then
                        local Key = GetHashKey(Vehicle)
                        if Key == Player.Vehicle.Hash then
                            Found = "police"
                            break
                        end
                    end
                end

                if not Found then
                    -- Loop though all the fire/ems vehicles
                    for _, Vehicle in ipairs(Config.Whitelisted.FireEMS) do
                        if not Found then
                            local Key = GetHashKey(Vehicle)
                            if Key == Player.Vehicle.Hash then
                                Found = "fireems"
                                break
                            end
                        end
                    end
                end

                if not Found then
                    -- Loop though all the military vehicles
                    for _, Vehicle in ipairs(Config.Whitelisted.Military) do
                        if not Found then
                            local Key = GetHashKey(Vehicle)
                            if Key == Player.Vehicle.Hash then
                                Found = "military"
                                break
                            end
                        end
                    end
                end

                if not Found then
                    -- Loop though all the custom vehicles
                    for _, Vehicle in ipairs(Config.Whitelisted.Custom) do
                        if not Found then
                            local Key = GetHashKey(Vehicle)
                            if Key == Player.Vehicle.Hash then
                                Found = "custom"
                                break
                            end
                        end
                    end
                end

                if Found then
                    TriggerServerEvent("Vehicle-Whitelist:Check", Found)
                else
                    Player.Vehicle.Allowed = true
                end
            end
        end

    end
end)