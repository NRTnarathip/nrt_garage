ESX = nil
TriggerEvent('esx:getSharedObject', function(obj)
    ESX = obj
end)
ESX.RegisterServerCallback('nrt_garage:SaveCarVehicleGarage', function(playerID, cb, vehicleProps)
    MySQL.Async.fetchAll('SELECT * FROM owned_vehicles', {}, function(resOwnedVehicle)
        for key,rowOwned in ipairs(resOwnedVehicle) do
            if rowOwned.plate == vehicleProps.plate then --Exits Owned Buy Vehicle At Dealerchip
                cb('found')
            end
        end
    end)
end)

ESX.RegisterServerCallback('nrt_garage:getVehicleGarage', function(playerID, callback)
    local dataVehicleProps = {}
    local Identifiers = GetPlayerIdentifiers(playerID)
    MySQL.Async.fetchAll('SELECT * FROM owned_vehicles',{}, function(resOwnedVehicle)
        for k, rowFechTable in ipairs(resOwnedVehicle) do
            if rowFechTable.owner == Identifiers[1] then
                local jsVehicleProps = json.decode(rowFechTable.vehicle)
                table.insert(dataVehicleProps, jsVehicleProps)
            end
        end
        callback(dataVehicleProps)
    end)
end)

