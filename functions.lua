function openMenu(isOpen)
    local e_key = 86
    if isOpen == false then
        mainMenu:Visible(false)
    elseif isOpen == true then
        alert("Enter Garage ~INPUT_VEH_HORN~")
        _menuGarage:ProcessMenus()
        if IsControlJustPressed(1, e_key) and isOpen == true then
            CreateMenuGaragePublic()
        end
    end
end
function deleteVehicleInTheWorld(vehicleProps)
    local vhTheWorld = ESX.Game.GetVehicles() -- Entity Vehicle
    for _, rowVehicleTheWorld in ipairs(vhTheWorld) do
        local vehicleWorldProps = ESX.Game.GetVehicleProperties(
                                      rowVehicleTheWorld)
        if (vehicleWorldProps==nul) then
            break
        end
        for _i, rowVehicleGarageProps in ipairs(vehicleProps) do
            if vehicleWorldProps.plate == rowVehicleGarageProps.plate then
                ESX.Game.DeleteVehicle(rowVehicleTheWorld)
            end
        end
    end
end
function spawnVehicleCar(vehicleProps, i)
    deleteVehicleInTheWorld(vehicleProps)
    for nameGarage, dataGarage in pairs(Config.SpawnCarInGarage) do
        if nameGarage == currentZone then
            for indexPos,countPosX in ipairs(dataGarage.pos.x) do -- i count of index X
                local vec3Coords = vector3(dataGarage.pos.x[indexPos], dataGarage.pos.y[indexPos], 
                        dataGarage.pos.z[indexPos])
                local objVehicle = ESX.Game.GetVehiclesInArea(vec3Coords, 6.0)
                local vhInArea = false
                for _i, v in pairs(objVehicle) do 
                    vhInArea = true
                    break
                end
                if vhInArea == false then
                    ESX.Game.SpawnVehicle(vehicleProps[i].model, vec3Coords,
                        dataGarage.heading, function(vehicleSpawn)
                        ESX.Game.SetVehicleProperties(vehicleSpawn, vehicleProps[i])
                    end)
                    break
                end
            end
            
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
    local dataVehicleProps = {}
    local listCarMenu = {}
    _menuGarage = NativeUI.CreatePool()
    mainMenu = NativeUI.CreateMenu("Garage Public", 'Garage Public Beta')
    _menuGarage:Add(mainMenu)

    ESX.TriggerServerCallback('nrt_garage:getVehicleGarage', function(callback)
        for k, v in ipairs(callback) do 
            table.insert(dataVehicleProps, v) 
        end
        if TableIsEmty(dataVehicleProps) == false then
            for _, rowVehicleProps in ipairs(dataVehicleProps) do
                local name = GetLabelText(
                                 GetDisplayNameFromVehicleModel(
                                     rowVehicleProps.model))
                local plate = rowVehicleProps.plate
                print("Insert %s",plate)
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
        if cb == "error" then
            notify(sx('cannot_save_vehicle_garage')) 
        else
            DeleteEntity(vehicle);
        end
    end, vehicleProps)
end

function DrawMarkerAll(data)
    DrawMarker(Config.tyeMarker, data.pos.x, data.pos.y, data.pos.z-0.9, 0.0, 0.0, 0.0, 0.0, 0.0,
               0.0, 2.0, 2.0, 2.0, data.color[1], data.color[2],
               data.color[3], data.color[4], false, true, 2, false, nil, nil, false)
end

function alert(msg)
    SetTextComponentFormat("STRING")
    AddTextComponentString(msg)
    DisplayHelpTextFromStringLabel(0, 0, 1, -1)
end
