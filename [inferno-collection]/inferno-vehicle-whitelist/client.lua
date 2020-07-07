-- Inferno Collection Vehicle Whitelist Version 1.1 Beta
--
-- Copyright (c) 2019 - 2020, Christopher M, Inferno Collection. All rights reserved.
--
-- This project is licensed under the following:
-- Permission is hereby granted, free of charge, to any person obtaining a copy of this software and associated documentation files (the "Software"), to use, copy, modify, and merge the software, under the following conditions:
-- The above copyright notice and this permission notice shall be included in all copies or substantial portions of the Software.
-- THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY, FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM, OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE SOFTWARE. THE SOFTWARE MAY NOT BE SOLD.
--

--
-- Resource Configuration
-- Please note, there is also some configuration required in the `server.lua` file, so make sure to edit that file as well
--
-- PLEASE RESTART SERVER AFTER MAKING CHANGES TO THIS CONFIGURATION
--

local Config = {} -- Do not edit this line
Config.Whitelisted = {} -- Do not edit this line

-- List of vehicle names to be whitelisted to police
Config.Whitelisted.police = {
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
Config.Whitelisted.fireems = {
    "Ambulance",
    "FireTruk" -- Not a typo, this is the spawn name
}

-- List of vehicle names to be whitelisted to Military
Config.Whitelisted.military = {
    "APC",
    "Barracks",
    "Barracks2",
    "Crusader",
    "Halftrack",
    "Rhino"
}

-- Custom list of vehicle names to be whitelisted
Config.Whitelisted.custom = {
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

-- Checked vehicles
local Vehicles = {}
local LastVehicle
local LastVehicleAllowed = false

-- On client join server
AddEventHandler("onClientMapStart", function()
    TriggerEvent("chat:addSuggestion", "/unlock", "Type a vehicle type/class and password to unlock that vehicle type/class.", {
        { name = "type/class", help = "Police FireEMS Military Custom" },
        { name = "password", help = "The password for this type/class" }
    })
end)

-- Return for vehicle allowed check
RegisterNetEvent("Vehicle-Whitelist:Message")
AddEventHandler("Vehicle-Whitelist:Message", function(Text, Flash)
    NewNoti(Text, Flash)
end)

-- Return for vehicle allowed check
RegisterNetEvent("Vehicle-Whitelist:Return:Check")
AddEventHandler("Vehicle-Whitelist:Return:Check", function(Allowed)
    if not Allowed then
        local PlayerPed = PlayerPedId()
        local Vehicle = GetVehiclePedIsIn(PlayerPed, false)

        ClearPedTasksImmediately(PlayerPed)
        NewNoti("~r~You are not allowed to use this vehicle.", true)

        if Vehicle then TaskLeaveVehicle(PlayerPed, Vehicle, 16) end
    end

    LastVehicleAllowed = Allowed
end)

Citizen.CreateThread(function()
    while true do
        Citizen.Wait(0)

        local PlayerPed = PlayerPedId()
        local Vehicle = GetVehiclePedIsTryingToEnter(PlayerPed)

        -- If player is trying to enter a vehicle
        if (Vehicle ~= 0 and LastVehicle ~= Vehicle) or not LastVehicleAllowed then
            local VehicleHash = GetEntityModel(Vehicle)
            LastVehicle = Vehicle
            LastVehicleAllowed = true

            for VehicleType, WhitelistVehicles in pairs(Config.Whitelisted) do
                for _, WhitelistVehicle in pairs(WhitelistVehicles) do
                    if GetHashKey(WhitelistVehicle) == VehicleHash then
                        if not Vehicles[VehicleType] then
                            TriggerServerEvent("Vehicle-Whitelist:Check", VehicleType)
                        elseif Vehicles[VehicleType] == "notallowed" then
                            TriggerEvent("Vehicle-Whitelist:Return:Check", false)
                        end

                        goto EndLoop
                    end
                end
            end
            ::EndLoop::
        end

    end
end)

function NewNoti(Text, Flash)
    SetNotificationTextEntry("STRING")
    AddTextComponentString(Text)
    DrawNotification(Flash, true)
end