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
firstTimeOpenMenu = GetClockMinutes()
Citizen.CreateThread(function() -- Create BLips Garage Public
    for _, rowBlip in pairs(Config.Blips.GaragePublic) do
        local blips = AddBlipForCoord(rowBlip.pos.x, rowBlip.pos.y,
                                      rowBlip.pos.z)
        SetBlipSprite(blips, rowBlip.Sprite)
        SetBlipDisplay(blips, rowBlip.Display)
        SetBlipScale(blips, rowBlip.Scale)
        BeginTextCommandSetBlipName("STRING")
        AddTextComponentString("Public Garage")
        SetBlipAsShortRange(blips, true)
        EndTextCommandSetBlipName(blips)

    end
end)
Citizen.CreateThread(function()
    while true do
        local player = PlayerPedId()
        local playerCoor = GetEntityCoords(player)
        if Config.GaragePublic then
            for i, v in pairs(Config.GaragePublic.DrawMarker) do
                local distance = Vdist(playerCoor.x, playerCoor.y, playerCoor.z,
                                       v.pos.x, v.pos.y, v.pos.z)
                if distance < v.Distance then
                    DrawMarkerAll(v)
                    if v.ZoneName == 'Garage' then
                        if distance < 1.7 then
                            openMenu(true)
                        elseif distance > 1.7 then
                            openMenu(false)
                        end
                    elseif v.ZoneName == 'SaveCar' then
                        if distance < 1.7 then
                            Draw3DText(v.pos.x,v.pos.y,v.pos.z,0.5,"Press [E] Save Car")
                            if IsControlJustPressed(1,38) then-- [E] Key
                                local OnVehicle = GetVehiclePedIsIn(GetPlayerPed(-1), false)
                                if OnVehicle ~= 0 then
                                    SaveCarAtGarage()
                                end
                            end
                        end
                    end
                end
            end
        end
        Citizen.Wait(0)
    end
end)



