ESX = nil
TriggerEvent('esx:getSharedObject', function(obj)
    ESX = obj
end)
ESX.RegisterServerCallback('nrt_garage:getVehicleData', function(source, callback)
    print("")
    local dataVehicle = {}
    MySQL.Async.fetchAll("SELECT * FROM `owned_vehicles`", {}, function(res_Database)
        local Identifiers = GetPlayerIdentifiers(source)
        for _, v in ipairs(res_Database) do
            if string.match(v.owner, Identifiers[1]) then
                -- print(v.vehicle)e
                local jsVehicle = json.decode(v.vehicle)

                print(string.format("That Your ID >> " .. v.owner .. " Car Model Is >> " .. jsVehicle.model))
                table.insert(dataVehicle, jsVehicle)
            end
        end
        print("------")
        callback(dataVehicle)
    end)
end)
ESX.RegisterServerCallback('nrt_garage:updateVehicleGarage', function(playerID, cb, vehicleProps, vehiclePed, carName)
    print(carName)
    MySQL.Async.fetchAll("SELECT * FROM `vehicles`", {}, function(resultData)
        for _, v in ipairs(resultData) do
            if v.name == carName then
                print("Compairs Car Name")
                print(v.name)
                local carClass = v.category
                print(carClass)
                MySQL.Async.execute(
                    'UPDATE `garage_vehicle` SET vehicle=(@vehicle), class=(@class), name=(@name) WHERE plate=(@plate)',
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
    print(identifiers[1])
    MySQL.Async.execute('INSERT INTO garage_vehicle (owner, plate, type, name) VALUES (@owner, @plate, @type, @name)',
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
    MySQL.Async.fetchAll("SELECT * FROM `garage_vehicle`", {}, function(resultData)
        local Identifiers = GetPlayerIdentifiers(playerID)
        local dataVehicle = {}
        for _, v in ipairs(resultData) do
            if string.match(v.owner, Identifiers[1]) then
                local jsVehicle = json.decode(v.vehicle)
                print(string.format("That Your ID >> " .. v.owner .. " Car Model Is >> " .. jsVehicle.model))
                table.insert(dataVehicle, jsVehicle)
            end
        end
        print("------")
        callback(dataVehicle)
    end)
end)

