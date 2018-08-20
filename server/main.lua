ESX = nil
TriggerEvent('esx:getSharedObject', function(obj) ESX = obj end)

--SELECT * FROM owned_vehicles WHERE vehicle LIKE '%"plate":"T034JZ9D"%' LIMIT 1

ESX.RegisterServerCallback('esx_impound:impound_vehicle', function(source, cb, plate)
	local xPlayer = ESX.GetPlayerFromId(source)
	ImpoundVehicle(plate)
	cb()
end)

--[[
  Impounds a vehicle

	Params
	  plate (string) - plate of vehicle to impound

  Returns
	 void
]]
function ImpoundVehicle(plate)
	-- Retrieve vehicle data from garage
	MySQL.Async.fetchAll('SELECT * FROM owned_vehicles WHERE vehicle LIKE \'%"plate":"' .. plate .. '"%\' LIMIT 1', {}, function(vehicles)
		for index, vehicle in pairs(vehicles) do
			-- Insert vehicle into impound table
	    MySQL.Async.execute("INSERT INTO `impounded_vehicles` (`vehicle`, `owner`) VALUES(@vehicle, @owner)", {['@vehicle'] = vehicle.vehicle, ['@owner'] = vehicle.owner})

			-- Delete vehicle from garage
	    MySQL.Async.execute("DELETE FROM owned_vehicles WHERE id=@id LIMIT 1", {['@id'] = vehicle.id})
		end
  end)
end
