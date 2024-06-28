print('Stag Productions V1.0.0 Loaded')

local QBCore = exports['qb-core']:GetCoreObject()
local bus
local busStops = Config.busStops

local busSpawnLocation = Config.busSpawn
local busDutyLocation = Config.dutyToggle
local busReturnLocation = Config.busReturnLocation

CreateThread(function()
    local busBlip = AddBlipForCoord(busDutyLocation.x, busDutyLocation.y, busDutyLocation.z)
    SetBlipSprite(busBlip, 513)
    SetBlipDisplay(busBlip, 4)
    SetBlipScale(busBlip, 0.7)
    SetBlipAsShortRange(busBlip, true)
    SetBlipColour(busBlip, 29)
    BeginTextCommandSetBlipName('STRING')
    AddTextComponentSubstringPlayerName('Bus Depot')
    EndTextCommandSetBlipName(busBlip)
end)

CreateThread(function()
    exports['qb-target']:AddBoxZone("BusDutyZone", busDutyLocation, 2.0, 2.0, {
        name = "BusDutyZone",
        heading = 0,
        debugPoly = false,
        minZ = 27.6,
        maxZ = 30.6,
    }, {
        options = {
            {
                type = "client",
                event = "stag_busjob:ToggleDuty",
                icon = "fas fa-clipboard",
                label = "Toggle Bus Duty",
            },
        },
        distance = 2.5,
    })
end)

RegisterNetEvent('stag_busjob:ToggleDuty', function()
    local job = QBCore.Functions.GetPlayerData().job.name
    if job == 'busjob' then
    TriggerServerEvent('QBCore:ToggleDuty')
    else
        QBCore.Functions.Notify('Not a bus driver', 'error', 5000)
    end

end)

local toggle = false
local function toggleOnOff()
    local onDuty = QBCore.Functions.GetPlayerData().job.onduty
    local job = QBCore.Functions.GetPlayerData().job.name
    toggle = not toggle
    CreateThread(function()
        while toggle do
            Wait(0)
            if job == 'busjob' and onDuty then
                DrawMarker(39, busSpawnLocation.x, busSpawnLocation.y, busSpawnLocation.z + 2, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 2.0, 2.0, 2.0, 0, 100, 0, 50, false, true, 2, nil, nil, false)
            if IsControlJustPressed(0, 38) then
                print("You pressed E")
                SpawnBus()
            end
        end
    end
    end)
end

local CircleZone = CircleZone:Create(vector3(busSpawnLocation.x, busSpawnLocation.y, busSpawnLocation.z), 10.0, {
    name="circle_zone",
    debugPoly=false,
})

CircleZone:onPointInOut(PolyZone.getPlayerPosition, function(isPointInside)
    if isPointInside then
        toggleOnOff()
        print("Player entered the circle zone")
    else
        toggleOnOff()
        print("Player left the circle zone")
    end
end)

local toggle2 = false
local function toggle2OnOff()
    local job = QBCore.Functions.GetPlayerData().job.name
    toggle2 = not toggle2
    CreateThread(function()
        while toggle2 do
            Wait(0)
            if job == 'busjob' then
                DrawMarker(39, busReturnLocation.x, busReturnLocation.y, busReturnLocation.z + 2, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 2.0, 2.0, 2.0, 255, 0, 0, 50, false, true, 2, nil, nil, false)
            if IsControlJustPressed(0, 38) then
                print("You pressed E")
                ReturnBus()
            end
        end
    end
    end)
end

local CircleZone2 = CircleZone:Create(vector3(busReturnLocation.x, busReturnLocation.y, busReturnLocation.z), 10.0, {
    name="circle_zone2",
    debugPoly=false,
})
CircleZone2:onPointInOut(PolyZone.getPlayerPosition, function(isPointInside)
    if isPointInside then
        toggle2OnOff()
        print("Player entered the circle zone")
    else
        toggle2OnOff()
        print("Player left the circle zone")
    end
end)

function SpawnBus()
    if bus then
        QBCore.Functions.Notify("You already have a bus.")
    else
        local playerPed = PlayerPedId()
        local vehicleModel = GetHashKey(Config.busModel)

        RequestModel(vehicleModel)
        while not HasModelLoaded(vehicleModel) do
            Citizen.Wait(0)
        end

        local spawnCoords = busSpawnLocation
        bus = CreateVehicle(vehicleModel, spawnCoords.x, spawnCoords.y, spawnCoords.z, GetEntityHeading(playerPed), true, false)
        TaskWarpPedIntoVehicle(playerPed, bus, -1)
        TriggerEvent('vehiclekeys:client:SetOwner', QBCore.Functions.GetPlate(bus))
        SetBusStops()
    end
end

function ReturnBus()
    if bus then
        DeleteVehicle(bus)
        bus = nil
        QBCore.Functions.Notify("You have returned the bus.")
        RemoveBusStops()
    else
        QBCore.Functions.Notify("You don't have a bus to return.")
    end
end

local blips = {}


function SetBusStops()
    for id, stop in pairs(busStops) do
        local blip = AddBlipForCoord(stop.x, stop.y, stop.z)
        blips[id] = blip
        SetBlipSprite(blip, 1)
        SetBlipDisplay(blip, 4)
        SetBlipScale(blip, 0.8)
        SetBlipColour(blip, 5)
        SetBlipAsShortRange(blip, true)

        BeginTextCommandSetBlipName("STRING")
        AddTextComponentString("Bus Stop")
        EndTextCommandSetBlipName(blip)
    end
end

function RemoveBusStops()
    for id, blip in pairs(blips) do
        RemoveBlip(blip)
    end
end


function DrawText3D(x, y, z, text)
    local onScreen, _x, _y = World3dToScreen2d(x, y, z)
    local px, py, pz = table.unpack(GetGameplayCamCoords())

    if onScreen then
        SetTextScale(0.35, 0.35)
        SetTextFont(4)
        SetTextProportional(1)
        SetTextColour(255, 255, 255, 215)
        SetTextEntry("STRING")
        SetTextCentre(1)
        AddTextComponentString(text)
        DrawText(_x, _y)
        local factor = (string.len(text)) / 370
        DrawRect(_x, _y + 0.0125, 0.015 + factor, 0.03, 41, 11, 41, 100)
    end
end

RegisterNetEvent("stag_busjob:client:chargeRider", function()
    local bill = exports['qb-input']:ShowInput({
        header = "Bus Fare",
        submitText = "Charge",
        inputs = {
            {
                text = "Server ID(#)",
                name = "citizenid", 
                type = "text", 
                isRequired = true
            },
            {
                text = "   Bill Price (£)",
                name = "billprice", 
                type = "number",
                isRequired = false
            }
        }
    })
    if bill ~= nil then
        if bill.citizenid == nil or bill.billprice == nil then 
            return 
        end
        TriggerServerEvent("stag_busjob:server:billPlayer", bill.citizenid, bill.billprice)
    end
end)

RegisterCommand("busfare", function()
    local job = QBCore.Functions.GetPlayerData().job.name
    if job == 'busjob' then
        if IsPedInVehicle(PlayerPedId(), bus, false) then
    TriggerEvent("stag_busjob:client:chargeRider")
    else 
        QBCore.Functions.Notify('Not on duty or not in a bus', 'error', 5000)
    end
end
end, false)

AddEventHandler('onResourceStop', function(resourceName)
    if (GetCurrentResourceName() ~= resourceName) then
        return
    end
    RemoveBusStops()
end)