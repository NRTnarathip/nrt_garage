ESX = nil
TriggerEvent('esx:getSharedObject', function(obj)
    ESX = obj
end)


ESX.RegisterServerCallback('nrt_garage:SaveCarVehicleGarage', function(playerID, cb, vehicleProps, vehiclePed, carName)
    local sqlSELECT_DBVehicle_Shop = "SELECT * FROM "..Config.DBVehicleShop
    local sqlSELECT_DBVehicle_Garage = "SELECT * FROM "..Config.DBVehicleGarage
    local sqlINSERT_DBVehicle_Garage = string.format('INSERT INTO %s (vehicle,owner, plate, type, name) VALUES (@vehicle,@owner,@plate,@type, @name)',Config.DBVehicleGarage)
    local sqlUPDATE_DBVehicle_Garage = string.format("UPDATE %s SET vehicle=(@vehicle) WHERE plate=(@plate)",Config.DBVehicleGarage)
    MySQL.Async.fetchAll(sqlSELECT_DBVehicle_Shop, {}, function(resOwnedVehicle) 
        for k,rowOwned in ipairs(resOwnedVehicle) do
            if rowOwned.plate == vehicleProps.plate then --Exits Owned Buy Vehicle At Dealerchip
                local updateVehicleGarage = false
                MySQL.Async.fetchAll(sqlSELECT_DBVehicle_Garage, {}, function(resVehicleGarage) -- find Exits Car In Vehicle Garage
                    for _,rowVehicleGarage in ipairs(resVehicleGarage) do
                        if rowVehicleGarage.plate == vehicleProps.plate then 
                            updateVehicleGarage = true
                            break
                        end
                    end
                    if updateVehicleGarage == true then
                        print('update vehicle')
                        MySQL.Async.execute(sqlUPDATE_DBVehicle_Garage,
                            {
                                ['@vehicle'] = json.encode(vehicleProps)
                            },function()
                            
                                cb('updateVehicle')
                        end)
                    else-- if row plate Not Founds Do Create Insert Data To Row vehiclee
                        print("create vehicle")
                        local indentifiertPed = GetPlayerIdentifiers(playerID)
                        MySQL.Async.execute(sqlINSERT_DBVehicle_Garage, {
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
            else --If You don't own this car
            	cb(2)
            end
        end
    end)
end)
ESX.RegisterServerCallback('nrt_garage:getVehicleGarage', function(playerID, callback)
    local sqlSELECT_DBVehicle_Shop = "SELECT * FROM "..Config.DBVehicleShop
    local sqlSELECT_DBVehicle_Garage = "SELECT * FROM "..Config.DBVehicleGarage
    local dataVehicleProps = {}
    local vehicleOwnedProps = {}
    local vehicleGarageProps = {}
    local Identifiers = GetPlayerIdentifiers(playerID)
    MySQL.Async.fetchAll(sqlSELECT_DBVehicle_Shop, {}, function(resultData)
        for _, rowVehicleOwnedProps in ipairs(resultData) do
            if string.match(rowVehicleOwnedProps.owner, Identifiers[1]) then
                local jsVehicleProps = json.decode(rowVehicleOwnedProps.vehicle)
                table.insert(vehicleOwnedProps, jsVehicleProps)
            end
        end
        MySQL.Async.fetchAll(sqlSELECT_DBVehicle_Garage, {}, function(resultData)
            for _, rowVehicleGarageProps in ipairs(resultData) do
                if string.match(rowVehicleGarageProps.owner, Identifiers[1]) then
                    local jsVehicleGarageProps = json.decode(rowVehicleGarageProps.vehicle)
                    table.insert(vehicleGarageProps,jsVehicleGarageProps)
                end
            end
            if TableIsEmty(vehicleGarageProps) == false then
                for _, rowVehicleOwnedProps in ipairs(vehicleOwnedProps) do
                    for _i, rowVehicleGarageProps in ipairs(vehicleGarageProps) do
                        if rowVehicleOwnedProps.plate == rowVehicleGarageProps.plate then
                            table.insert(dataVehicleProps,rowVehicleGarageProps)
                        else
                            table.insert(dataVehicleProps,GetPropsVehicleDefualt(rowVehicleOwnedProps))
                        end
                    end
                end
            else
                for k,rowVehicleOwnedProps in ipairs(vehicleOwnedProps) do
                    table.insert(dataVehicleProps,GetPropsVehicleDefualt(rowVehicleOwnedProps))
                end
            end
            callback(dataVehicleProps)
        end)
    end)
    
end)

