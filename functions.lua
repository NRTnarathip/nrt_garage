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
                CreateMenuGaragePublic(dataVehicle)
                mainMenu:Visible(true)
            end)
        end
    end
end
function spawnVehicleCar(vehicleProps, i)
    local spc = Config.GaragePublic.SpawnCar
    -- Delete Vehicle By Plate
    local vhTheWorld = ESX.Game.GetVehicles() -- Entity Vehicle
    for _, rowVehicleTheWorld in ipairs(vhTheWorld) do
        local vehicleWorldProps = ESX.Game.GetVehicleProperties(rowVehicleTheWorld)
        for _i, rowVehicleGarageProps in ipairs(vehicleProps) do
            if vehicleWorldProps.plate == rowVehicleGarageProps.plate then
                ESX.Game.DeleteVehicle(rowVehicleTheWorld)
            end
        end
    end
    ESX.Game.SpawnVehicle(vehicleProps[i].model, vector3(spc.pos.x, spc.pos.y, spc.pos.z), spc.heading,
        function(vehicleSpawn)
            ESX.Game.SetVehicleProperties(vehicleSpawn, vehicleProps[i])
            local vhProp = ESX.Game.GetVehicleProperties(vehicleSpawn)
        end)
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
            spawnVehicleCar(vehicleProps, index)
        end
    end
    _menuGarage:MouseControlsEnabled(false)
    _menuGarage:MouseEdgeEnabled(false)
    _menuGarage:ControlDisablingEnabled(false)
    _menuGarage:RefreshIndex()
end

RegisterCommand("savecar", function()
    SaveCarToGarage()
end)
function SaveCarToGarage()
    local vehicle = GetVehiclePedIsUsing(GetPlayerPed(-1))
    local vehicleProps = ESX.Game.GetVehicleProperties(vehicle)
    SaveVehicleCar(vehicleProps,vehicle)
end

function Draw3DText(x, y, z, scl_factor, text)
    local onScreen, _x, _y = World3dToScreen2d(x, y, z)
    local p = GetGameplayCamCoords()
    local distance = GetDistanceBetweenCoords(p.x, p.y, p.z, x, y, z, 1)
    local scale = (1 / distance) * 2
    local fov = (1 / GetGameplayCamFov()) * 100
    local scale = scale * fov * scl_factor
    if onScreen then
        SetTextScale(0.0, scale)
        SetTextFont(0)
        SetTextProportional(1)
        SetTextColour(255, 255, 255, 255)
        SetTextDropshadow(0, 0, 0, 0, 255)
        SetTextEdge(2, 0, 0, 0, 150)
        SetTextDropShadow()
        SetTextOutline()
        SetTextEntry("STRING")
        SetTextCentre(1)
        AddTextComponentString(text)
        DrawText(_x, _y)
    end
end
function SaveVehicleCar(vehicleProps,vehicle)
    local carName = GetLabelText(GetDisplayNameFromVehicleModel(vehicleProps.model))
    ESX.TriggerServerCallback('nrt_garage:SaveCarVehicleGarage',function(cb)
        print(cb)
        if cb == 'updateVehicle' or 'createVehicle' then
            DeleteEntity(vehicle);
        end
    end, vehicleProps,vehicle,carName)
end

function DrawMarkerAll(v)
    DrawMarker(v.tyeMarker, v.pos.x, v.pos.y, v.pos.z, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, v.scale.x,
    v.scale.y, v.scale.z, v.color.r, v.color.g, v.color.b, v.color.a, false, true, 2, false, nil,
    nil, false)
end
function alert(msg)
    SetTextComponentFormat("STRING")
    AddTextComponentString(msg)
    DisplayHelpTextFromStringLabel(0, 0, 1, -1)
end