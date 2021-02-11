ESX = nil
Citizen.CreateThread(function()
    while ESX == nil do
        TriggerEvent('esx:getSharedObject', function(obj)
            ESX = obj
        end)
        Citizen.Wait(0)
    end
end)
_menuGarage = NativeUI.CreatePool()
mainMenu = NativeUI.CreateMenu("Garage Public", 'Garage Public Beta')
_menuGarage:Add(mainMenu)

Citizen.CreateThread(function() -- Create BLips Garage Public
    for _,rowBlip in pairs(Config.Blips.GaragePublic) do 
        print(rowBlip.pos.x)
        local blips = AddBlipForCoord(rowBlip.pos.x, rowBlip.pos.y, rowBlip.pos.z)
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
    local isInMarkerGarage, currentZone = false
    while true do
        Citizen.Wait(0)
        local player = PlayerPedId()
        local playerCoor = GetEntityCoords(player)
        if Config.GaragePublic then
            for i, v in pairs(Config.GaragePublic.DrawMarker) do
                local distance = Vdist(playerCoor.x, playerCoor.y, playerCoor.z, v.pos.x, v.pos.y, v.pos.z)
                if distance < v.Distance then
                    DrawMarker(v.tyeMarker, v.pos.x, v.pos.y, v.pos.z, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, v.scale.x,
                        v.scale.y, v.scale.z, v.color.r, v.color.g, v.color.b, v.color.a, false, true, 2, false, nil,
                        nil, false)
                    if distance < 1.7 then
                        currentZone = v.ZoneName
                        openMenu(true)
                    elseif distance > 1.7 then
                        currentZone = 0
                        openMenu(false)
                    end
                end
            end
        end
    end
end)
function openMenu(isOpen)
    local h_key = 86
    if isOpen == false then
        mainMenu:Visible(false)
    elseif isOpen == true then
        alert("Enter Garage ~INPUT_VEH_HORN~")
        _menuGarage:ProcessMenus()
        if IsControlJustPressed(1, h_key) and isOpen == true then
            local dataVehicle = {}
            ESX.TriggerServerCallback('nrt_garage:getVehicleGarage', function(dataCallback)
                for _, v in ipairs(dataCallback) do
                    dataVehicle = dataCallback
                end
                print("wait Create Menu")
                CreateMenuGaragePublic(dataVehicle)
                mainMenu:Visible(true)
            end)
        end
    end
end
RegisterCommand("savecar", function()
    local vehicle = GetVehiclePedIsUsing(GetPlayerPed(-1))
    local vehicleProps = ESX.Game.GetVehicleProperties(vehicle)
    updateVehicleCar(vehicleProps,vehicle)
end)
function updateVehicleCar(vehicleProps,vehicle)
    local carName = GetLabelText(GetDisplayNameFromVehicleModel(vehicleProps.model))
    ESX.TriggerServerCallback('nrt_garage:updateVehicleGarage',function(cb)
        print(cb)
        if cb == 1 then
            DeleteEntity(vehicle);
        end
    end, vehicleProps,vehicle,carName)
end
function spawnVehicleCar(vehicleProps, i)
    print(#(vehicleProps))
    local spc = Config.GaragePublic.SpawnCar
    -- Delete Vehicle By Plate
    local vhTheWorld = ESX.Game.GetVehicles() -- Entity Vehicle
    for _, rowVehicleTheWorld in ipairs(vhTheWorld) do
        local vehicleWorldProps = ESX.Game.GetVehicleProperties(rowVehicleTheWorld)
        for _i, rowVehicleGarageProps in ipairs(vehicleProps) do
            if vehicleWorldProps.plate == rowVehicleGarageProps.plate then
                print("compairs")
                print(vehicleWorldProps.plate .. "===" .. rowVehicleGarageProps.plate)
                ESX.Game.DeleteVehicle(rowVehicleTheWorld)
            end
        end
    end
    ESX.Game.SpawnVehicle(vehicleProps[i].model, vector3(spc.pos.x, spc.pos.y, spc.pos.z), spc.heading,
        function(vehicleSpawn)
            ESX.Game.SetVehicleProperties(vehicleSpawn, vehicleProps[i])
            local vhProp = ESX.Game.GetVehicleProperties(vehicleSpawn)
            print(vhProp.plate)
        end)
end

function alert(msg)
    SetTextComponentFormat("STRING")
    AddTextComponentString(msg)
    DisplayHelpTextFromStringLabel(0, 0, 1, -1)
end

function CreateMenuGaragePublic(vehicleProps)
    local listCar = {}
    _menuGarage = NativeUI.CreatePool()
    mainMenu = NativeUI.CreateMenu("Garage Public", 'Garage Public Beta')
    _menuGarage:Add(mainMenu)
    for i, dataVehicle in ipairs(vehicleProps) do
        local name = GetLabelText(GetDisplayNameFromVehicleModel(dataVehicle.model))
        local plate = dataVehicle.plate
        table.insert(listCar, string.format("Name:%s plate:%s", name, plate))
    end
    local listItemVehicle = NativeUI.CreateListItem("Car", listCar, 1)
    mainMenu:AddItem(listItemVehicle)
    mainMenu.OnListSelect = function(sender, item, index)
        if item == listItemVehicle then
            local itemName = item:IndexToItem(index)
            print(itemName)
            print(index)
            spawnVehicleCar(vehicleProps, index)
        end
    end
    _menuGarage:MouseControlsEnabled(false)
    _menuGarage:MouseEdgeEnabled(false)
    _menuGarage:ControlDisablingEnabled(false)
    _menuGarage:RefreshIndex()
end
_menuGarage:MouseControlsEnabled(false)
_menuGarage:MouseEdgeEnabled(false)
_menuGarage:ControlDisablingEnabled(false)
_menuGarage:RefreshIndex()

