ESX = nil
Citizen.CreateThread(function()
    while ESX == nil do
        TriggerEvent('esx:getSharedObject', function(obj) ESX = obj end)
        Citizen.Wait(0)
    end
end)

_menuGarage = NativeUI.CreatePool()
mainMenu = NativeUI.CreateMenu("Garage Public", 'Garage Public Beta')
_menuGarage:Add(mainMenu)
currentZone = nil
listCarFromVehicleOwned = {}
Citizen.CreateThread(function() -- Create BLips Garage Public
    local cfgBlips = Config.Blips
    for nameGarage, dataGarage in pairs(Config.GaragePublic) do

        local blips = AddBlipForCoord(dataGarage.pos.x, dataGarage.pos.y,
            dataGarage.pos.z)
        SetBlipSprite(blips, cfgBlips.Sprite)
        SetBlipDisplay(blips, cfgBlips.Display)
        SetBlipScale(blips, cfgBlips.Scale)
        SetBlipColour(blips, cfgBlips.Color) -- green
        BeginTextCommandSetBlipName("STRING")
        AddTextComponentString("Public Garage")
        SetBlipAsShortRange(blips, true)
        EndTextCommandSetBlipName(blips)
    end
end)
Citizen.CreateThread(function() 
    while true do 
        for nameGarage, dataGarage in pairs(Config.SaveCarInGarage) do
            if nameGarage == currentZone then
                local distance = Vdist(playerCoor.x, playerCoor.y, playerCoor.z,
                                        dataGarage.pos.x, dataGarage.pos.y,
                                        dataGarage.pos.z)
                if distance < 50.0 then
                    DrawMarker(30, dataGarage.pos.x, dataGarage.pos.y,
                                dataGarage.pos.z, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0,
                                2.0, 2.0, 2.0, 155, 155, 255, 255, false, true,
                                2, false, nil, nil, false)
                    if distance < 1.7 then
                        if OnVehicle ~= 0 then
                            Draw3DText(dataGarage.pos.x, dataGarage.pos.y, dataGarage.pos.z, 0.5,
                            "Press [E] Save Car")
                            if IsControlJustPressed(1, 38) then -- [E] Key
                                SaveCarAtGarage()
                            end 
                        end
                    end
                end
            end
        end
        Citizen.Wait(0)
    end
end)
Citizen.CreateThread(function()
    while true do
        player = PlayerPedId()
        playerCoor = GetEntityCoords(player)
        OnVehicle = GetVehiclePedIsIn(player, false)
        if Config.GaragePublic then
            for nameGarage, dataGarage in pairs(Config.GaragePublic) do
                local distance = Vdist(playerCoor.x, playerCoor.y, playerCoor.z,
                                       dataGarage.pos.x, dataGarage.pos.y,
                                       dataGarage.pos.z)
                if distance < 50.0 then
                    if currentZone ~= nameGarage then
                        currentZone = nameGarage
                    end
                    DrawMarkerAll(dataGarage)
                    if distance < 1.7 then
                        openMenu(true)
                    elseif distance > 1.7 then
                        openMenu(false)
                    end
                end
            end
        end
        Citizen.Wait(0)
    end
end)