function openMenu(isOpen)
    local h_key = 86
    if isOpen == false then
        mainMenu:Visible(false)
    elseif isOpen == true then
        alert("Enter Garage ~INPUT_VEH_HORN~")
        _menuGarage:ProcessMenus()
        if IsControlJustPressed(1, h_key) and isOpen == true then
            CreateMenuGaragePublic()
        end
    end
end
function _tsl(str, ...)
    if Locales[Config.Locale] ~= nil then
        if Locales[Config.Locale][str] ~= nil then
            return string.format(Locales[Config.Locale][str], ...)
        else
            return 'Translation [' .. Config.Locale .. '][' .. str ..
                       '] does not exists'
        end
    else
        return 'Locale [' .. Config.Locale .. '] does not exists'
    end
end
function sx(str, ...) -- Translate string first char uppercase
    return tostring(_tsl(str, ...):gsub("^%l", string.upper))
end
function deleteVehicleInTheWorld(vehicleProps)
    local vhTheWorld = ESX.Game.GetVehicles() -- Entity Vehicle
    for _, rowVehicleTheWorld in ipairs(vhTheWorld) do
        local vehicleWorldProps = ESX.Game.GetVehicleProperties(
                                      rowVehicleTheWorld)
        for _i, rowVehicleGarageProps in ipairs(vehicleProps) do
            if vehicleWorldProps.plate == rowVehicleGarageProps.plate then
                ESX.Game.DeleteVehicle(rowVehicleTheWorld)
            end
        end
    end
end
function spawnVehicleCar(vehicleProps, i)
    deleteVehicleInTheWorld(vehicleProps)
    local spc = Config.GaragePublic.SpawnCar
    -- check Obtacle location spawn
    for _, rowSpawnCoordsX in ipairs(spc.pos.x) do
        local vec3Coords = vector3(spc.pos.x[_], spc.pos.y[_], spc.pos.z[_])
        local objVehicle = ESX.Game.GetVehiclesInArea(vec3Coords, 6.0)
        local vhInArea = false
        for _i, v in pairs(objVehicle) do vhInArea = true end
        if vhInArea == false then
            ESX.Game.SpawnVehicle(vehicleProps[i].model, vec3Coords,
                                  spc.heading, function(vehicleSpawn)
                ESX.Game.SetVehicleProperties(vehicleSpawn, vehicleProps[i])
            end)
            break
        end
    end
end
function TableIsEmty(tableArgs)
    for _, v in ipairs(tableArgs) do return false end
    return true
end

function GetPropsVehicleDefualt(rowVehicleOwnedProps)
    local vehiclePropsDefualt = {
        ['model'] = rowVehicleOwnedProps.model,
        ['plate'] = rowVehicleOwnedProps.plate,
        ['color1'] = 3,
        ['color2'] = 3
    }
    return vehiclePropsDefualt
end

function CreateMenuGaragePublic()
    print('createMenu')
    local dataVehicleProps = {}
    local listCarMenu = {}
    _menuGarage = NativeUI.CreatePool()
    mainMenu = NativeUI.CreateMenu("Garage Public", 'Garage Public Beta')
    _menuGarage:Add(mainMenu)
    ESX.TriggerServerCallback('nrt_garage:getVehicleGarage', function(callback)
        for k, v in ipairs(callback) do table.insert(dataVehicleProps, v) end
        if TableIsEmty(dataVehicleProps) == false then
            for _, rowVehicleProps in ipairs(dataVehicleProps) do
                local name = GetLabelText(
                                 GetDisplayNameFromVehicleModel(
                                     rowVehicleProps.model))
                local plate = rowVehicleProps.plate
                table.insert(listCarMenu,
                             string.format("Name:%s plate:%s", name, plate))
            end
        else
            table.insert(listCarMenu, 'Emty')
        end
        local listItemVehicle = NativeUI.CreateListItem("Car", listCarMenu, 1)
        mainMenu.OnListSelect = function(sender, item, index)
            if item == listItemVehicle then
                local itemName = item:IndexToItem(index)
                if itemName == 'Emty' and itemName ~= 'nil' then
                    notify(sx('car_emty'))
                else
                    spawnVehicleCar(dataVehicleProps, index)
                end
            end
        end
        mainMenu:AddItem(listItemVehicle)
        _menuGarage:MouseControlsEnabled(false)
        _menuGarage:MouseEdgeEnabled(false)
        _menuGarage:ControlDisablingEnabled(false)
        _menuGarage:RefreshIndex()
        mainMenu:Visible(not mainMenu:Visible())
    end)
end

RegisterCommand("savecar", function() SaveCarAtGarage() end)
function SaveCarAtGarage()
    local vehicle = GetVehiclePedIsUsing(GetPlayerPed(-1))
    local vehicleProps = ESX.Game.GetVehicleProperties(vehicle)
    SaveVehicleCar(vehicleProps, vehicle)
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
function notify(string)
    SetNotificationTextEntry("STRING")
    AddTextComponentString(string)
    DrawNotification(true, false)
end
function SaveVehicleCar(vehicleProps, vehicle)
    local carName = GetLabelText(GetDisplayNameFromVehicleModel(
                                     vehicleProps.model))
    ESX.TriggerServerCallback('nrt_garage:SaveCarVehicleGarage', function(cb)
        if cb == 'updateVehicle' or cb == 'createVehicle' then
            DeleteEntity(vehicle);
        elseif cb == 2 then
            notify(sx('cannot_save_vehicle_garage'))
        end
    end, vehicleProps, vehicle, carName)
end

function DrawMarkerAll(v)
    DrawMarker(v.tyeMarker, v.pos.x, v.pos.y, v.pos.z, 0.0, 0.0, 0.0, 0.0, 0.0,
               0.0, v.scale.x, v.scale.y, v.scale.z, v.color.r, v.color.g,
               v.color.b, v.color.a, false, true, 2, false, nil, nil, false)
end

function alert(msg)
    SetTextComponentFormat("STRING")
    AddTextComponentString(msg)
    DisplayHelpTextFromStringLabel(0, 0, 1, -1)
end
