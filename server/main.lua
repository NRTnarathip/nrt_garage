ESX = nil
TriggerEvent('esx:getSharedObject', function(obj)
    ESX = obj
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
ESX.RegisterServerCallback('nrt_garage:updateVehicleGarage', function(playerID, cb, vehicleProps, vehiclePed, carName)

    MySQL.Async.fetchAll("SELECT * FROM `vehicles`", {}, function(resultData)
        for _, v in ipairs(resultData) do
            if v.name == carName then
                local carClass = v.category
                MySQL.Async.execute(
                    'UPDATE `vehicle_garage` SET vehicle=(@vehicle), class=(@class), name=(@name) WHERE plate=(@plate)',
                    {
                        ['@vehicle'] = json.encode(vehicleProps),
                        ['@plate'] = vehicleProps.plate,
                        ['@class'] = carClass,
                        ['@name'] = carName
                    }, function(error)
                        cb(error)
                    end)
            end
        end
    end)
end)
ESX.RegisterServerCallback('nrt_garage:createVehicleGarage', function(playerId, callback, vehicleProps)
    local identifiers = GetPlayerIdentifiers(playerId)
    MySQL.Async.execute('INSERT INTO vehicle_garage (owner, plate, type, name) VALUES (@owner, @plate, @type, @name)',
        {
            ['@owner'] = identifiers[1], -- steam: Identifiers
            ['@plate'] = vehicleProps.plate,
            ['@vehicle'] = json.encode(vehicleProps),
            ['@type'] = "car",
            ['@name'] = GetLabelText(GetDisplayNameFromVehicleModel(vehicleProps.model))
        }, function(error)
            callback(error)
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

