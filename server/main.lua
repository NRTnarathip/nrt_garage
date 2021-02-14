ESX = nil
TriggerEvent('esx:getSharedObject', function(obj)
    ESX = obj
end)
RegisterNetEvent('nrt_garage:compareVehicleprops')
AddEventHandler('nrt_garage:compareVehicleprops', function(callback,vehicleProps_1,vehicle_2)
    for _, rowVehicleProps in ipairs(vehicleProps_1) do 
        for _i, _rowVehicleProps in ipairs(rowVehicleProps) do
            print(_rowVehicleProps)
        end
    end
end)
ESX.RegisterServerCallback('nrt_garage:getVehicleData', function(source, callback)
    local dataVehicle = {}
    MySQL.Async.fetchAll("SELECT * FROM `owned_vehicles`", {}, function(res_Database)
        local Identifiers = GetPlayerIdentifiers(source)
        for _, v in ipairs(res_Database) do
            if string.match(v.owner, Identifiers[1]) then
                local jsVehicle = json.decode(v.vehicle)               
                table.insert(dataVehicle, jsVehicle)
            end
        end

        callback(dataVehicle)
    end)
end)

ESX.RegisterServerCallback('nrt_garage:SaveCarVehicleGarage', function(playerID, cb, vehicleProps, vehiclePed, carName)
    MySQL.Async.fetchAll("SELECT * FROM `owned_vehicles`", {}, function(resOwnedVehicle) 
        for k,rowOwned in ipairs(resOwnedVehicle) do
            if rowOwned.plate == vehicleProps.plate then --Exits Owned Buy Vehicle At Dealerchip
                local updateVehicleGarage = false
                MySQL.Async.fetchAll("SELECT * FROM `vehicle_garage`", {}, function(resVehicleGarage) -- find Exits Car In Vehicle Garage
                    for _,rowVehicleGarage in ipairs(resVehicleGarage) do
                        if rowVehicleGarage.plate == vehicleProps.plate then 
                            updateVehicleGarage = true
                            break
                        end
                    end
                    if updateVehicleGarage == true then
                        print('update vehicle')
                        MySQL.Async.execute('UPDATE `vehicle_garage` SET vehicle=(@vehicle) WHERE plate=(@plate)',
                            {
                                ['@vehicle'] = json.encode(vehicleProps)
                            },function()
                                cb('updateVehicle')
                        end)
                    else-- if row plate Not Founds Do Create Insert Data To Row vehiclee
                        print("create vehicle")
                        local indentifiertPed = GetPlayerIdentifiers(playerID)
                        MySQL.Async.execute('INSERT INTO vehicle_garage (vehicle,owner, plate, type, name) VALUES (@vehicle,@owner,@plate,@type, @name)', {
                            ['@owner']   = indentifiertPed[1],
                            ['@plate']   = vehicleProps.plate,
                            ['@vehicle'] = json.encode(vehicleProps),
                            ['@type']   = 'car',
                            ['@name']   = carName
                        }, function()
                            cb('createVehicle')
                        end)
                    end
                end)
            end
        end
    end)
end)
ESX.RegisterServerCallback('nrt_garage:getVehicleGarage', function(playerID, callback)
    MySQL.Async.fetchAll("SELECT * FROM `vehicle_garage`", {}, function(resultData)
        local Identifiers = GetPlayerIdentifiers(playerID)
        local dataVehicle = {}
        for _, v in ipairs(resultData) do
            if string.match(v.owner, Identifiers[1]) then
                local jsVehicle = json.decode(v.vehicle)
                table.insert(dataVehicle, jsVehicle)
            end
        end
        callback(dataVehicle)
    end)
end)

