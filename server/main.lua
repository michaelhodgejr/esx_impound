ESX = nil
TriggerEvent('esx:getSharedObject', function(obj) ESX = obj end)

RegisterCommand('impound', function(source, args)
  TriggerClientEvent('esx_impound:impound_nearest_vehicle', source)
end)

ESX.RegisterServerCallback('esx_impound:impound_vehicle', function(source, cb, plate)
  ImpoundVehicle(plate)
  cb()
end)

ESX.RegisterServerCallback('esx_impound:retrieve_vehicle', function(source, cb, plate)
  RetrieveVehicle(plate)
  cb()
end)

ESX.RegisterServerCallback('esx_impound:get_vehicle_list', function(source, cb)
  local _source = source
  local xPlayer = ESX.GetPlayerFromId(_source)
  local vehicles = {}

  MySQL.Async.fetchAll("SELECT * FROM impounded_vehicles WHERE owner=@identifier",{['@identifier'] = xPlayer.getIdentifier()}, function(data)
    for _,v in pairs(data) do
      local vehicle = json.decode(v.vehicle)
      table.insert(vehicles, {vehicle = vehicle, state = v.state, can_release = VehicleEligableForRelease(v)})
    end
    cb(vehicles)
  end)
end)

ESX.RegisterServerCallback('esx_impound:check_money', function(source, cb)
  local xPlayer = ESX.GetPlayerFromId(source)

  if xPlayer.get('money') >= Config.ImpoundFineAmount then
    xPlayer.removeAccountMoney('bank', Config.ImpoundFineAmount)
    cb(true)
  else
    cb(false)
  end
end)

--[[
Impounds a vehicle

Params
plate (string) - plate of vehicle to impound

Returns
void
]]
function ImpoundVehicle(plate)
  local current_time = os.time(os.date("!*t"))

  -- Retrieve vehicle data from garage
  if Config.OwnedVehiclesHasPlateColumn then
    MySQL.Async.fetchAll('SELECT * FROM owned_vehicles WHERE plate = @plate LIMIT 1', {
      ['@plate'] = plate
    }, function(vehicles)
      ProcessImpoundment(plate, current_time, vehicles)
    end)
  else
    MySQL.Async.fetchAll('SELECT * FROM owned_vehicles WHERE vehicle LIKE \'%"plate":"' .. plate .. '"%\' LIMIT 1', {}, function(vehicles)
      ProcessImpoundment(plate, current_time, vehicles)
    end)
  end

end

--[[
  Processes the impound of a vehicle

  Params
    vehicles - table of vehicles

  Returns
    void
]]
function ProcessImpoundment(plate, current_time, vehicles)
  for index, vehicle in pairs(vehicles) do
    -- Insert vehicle into impound table
    MySQL.Async.execute("INSERT INTO `impounded_vehicles` (`plate`, `vehicle`, `owner`, `impounded_at`) VALUES(@plate, @vehicle, @owner, @timestamp)", {
      ['@plate'] = plate,
      ['@vehicle'] = vehicle.vehicle,
      ['@owner'] = vehicle.owner,
      ['@timestamp'] = current_time
    })

    -- Delete vehicle from garage
    MySQL.Async.execute("DELETE FROM owned_vehicles WHERE id=@id LIMIT 1", {['@id'] = vehicle.id})
  end
end

--[[
Retrieves a vehicle

Params
plate (string) - plate of vehicle to retrieve

Returns
void
]]
function RetrieveVehicle(plate)

  -- Retrieve vehicle data from impound lot
  MySQL.Async.fetchAll('SELECT * FROM impounded_vehicles WHERE plate = @plate LIMIT 1', {
    ['@plate'] = plate
  }, function(vehicles)
    for index, vehicle in pairs(vehicles) do
      -- Insert vehicle into owned_vehicles table
      if Config.OwnedVehiclesHasPlateColumn then
        MySQL.Async.execute("INSERT INTO `owned_vehicles` (`plate`, `vehicle`, `owner`, `state`) VALUES(@plate, @vehicle, @owner, '0')",
          {
            ['@plate'] = plate,
            ['@vehicle'] = vehicle.vehicle,
            ['@owner'] = vehicle.owner
          }
        )
      else
        MySQL.Async.execute("INSERT INTO `owned_vehicles` (`vehicle`, `owner`, `state`) VALUES(@vehicle, @owner, '0')",
          {
            ['@vehicle'] = vehicle.vehicle,
            ['@owner'] = vehicle.owner
          }
        )
      end
      -- Delete vehicle from Impound Lot
      MySQL.Async.execute("DELETE FROM impounded_vehicles WHERE id=@id LIMIT 1", {['@id'] = vehicle.id})
    end
  end)
end

--[[
Determines if a vehicle is eligable for release

Params
vehicle - table

Returns
boolean
]]
function VehicleEligableForRelease(vehicle)
  local current_time = os.time(os.date("!*t"))

  if Config.UserMustWaitElapsedTime then
    -- Determine the time the user could get their vehicle back and check if that time
    -- has expired
    if (vehicle.impounded_at + (Config.ElapsedTimeBeforeRelease * 60)) <= current_time then
      return true
    else
      return false
    end
  else
    return true
  end
end
