-- Local
local Keys = {
	["ESC"] = 322, ["F1"] = 288, ["F2"] = 289, ["F3"] = 170, ["F5"] = 166, ["F6"] = 167, ["F7"] = 168, ["F8"] = 169, ["F9"] = 56, ["F10"] = 57,
	["~"] = 243, ["1"] = 157, ["2"] = 158, ["3"] = 160, ["4"] = 164, ["5"] = 165, ["6"] = 159, ["7"] = 161, ["8"] = 162, ["9"] = 163, ["-"] = 84, ["="] = 83, ["BACKSPACE"] = 177,
	["TAB"] = 37, ["Q"] = 44, ["W"] = 32, ["E"] = 38, ["R"] = 45, ["T"] = 245, ["Y"] = 246, ["U"] = 303, ["P"] = 199, ["["] = 39, ["]"] = 40, ["ENTER"] = 18,
	["CAPS"] = 137, ["A"] = 34, ["S"] = 8, ["D"] = 9, ["F"] = 23, ["G"] = 47, ["H"] = 74, ["K"] = 311, ["L"] = 182,
	["LEFTSHIFT"] = 21, ["Z"] = 20, ["X"] = 73, ["C"] = 26, ["V"] = 0, ["B"] = 29, ["N"] = 249, ["M"] = 244, [","] = 82, ["."] = 81,
	["LEFTCTRL"] = 36, ["LEFTALT"] = 19, ["SPACE"] = 22, ["RIGHTCTRL"] = 70,
	["HOME"] = 213, ["PAGEUP"] = 10, ["PAGEDOWN"] = 11, ["DELETE"] = 178,
	["LEFT"] = 174, ["RIGHT"] = 175, ["TOP"] = 27, ["DOWN"] = 173,
	["NENTER"] = 201, ["N4"] = 108, ["N5"] = 60, ["N6"] = 107, ["N+"] = 96, ["N-"] = 97, ["N7"] = 117, ["N8"] = 61, ["N9"] = 118
}

ESX = nil
local HasAlreadyEnteredMarker   = false
local LastZone                  = nil
local PlayerData = nil
local CurrentActionMsg          = ''
local CurrentActionData         = {}
local GUI                       = {}
GUI.Time                        = 0

--[[
  Setup of ESX
]]
Citizen.CreateThread(function()
  while ESX == nil do
    TriggerEvent('esx:getSharedObject', function(obj) ESX = obj end)
    Citizen.Wait(0)
  end
end)

RegisterNetEvent('esx:playerLoaded')
AddEventHandler('esx:playerLoaded', function(xPlayer)
	  drawImpoundLotMapBlips()
end)


--[[
  Function for drawing the impound lot blips on the map
]]
function drawImpoundLotMapBlips()
	local zones = {}
	local blipInfo = {}

	for zoneKey,zoneValues in pairs(Config.ImpoundLots)do
		local blip = AddBlipForCoord(zoneValues.Pos.x, zoneValues.Pos.y, zoneValues.Pos.z)
		SetBlipSprite (blip, Config.BlipInfos.Sprite)
		SetBlipDisplay(blip, 4)
		SetBlipScale  (blip, 0.8)
		SetBlipColour (blip, Config.BlipInfos.Color)
		SetBlipAsShortRange(blip, true)
		BeginTextCommandSetBlipName("STRING")
		AddTextComponentString("Impound Lot")
		EndTextCommandSetBlipName(blip)
	end
end

--[[
  Function for drawing the impound lot blips on the map
]]
function removeImpoundLotMapBlips()
	for index, blip in pairs(drawnImpoundBlips)do
		RemoveBlip(blip)
	end
end

--[[
  Thread for drawing the blips, markers, dropoff and retrieval markers for
  the impound lots
]]
Citizen.CreateThread(function()
	while true do
		Wait(0)
    drawImpoundLotMapBlips()
		drawImpoundLotMarkers()
	end
end)

--[[
  Thread for determining if the player has entered a impound lot marker or not
]]
Citizen.CreateThread(function()
	local currentZone = 'impound_lot'
	while true do
		Wait(0)

		local coords      = GetEntityCoords(GetPlayerPed(-1))
		local isInMarker  = false

		for _,v in pairs(Config.ImpoundLots) do
			if(GetDistanceBetweenCoords(coords, v.Pos.x, v.Pos.y, v.Pos.z, true) < v.Size.x) then
				isInMarker  = true
				this_ImpoundLot = v
			end
		end

		if isInMarker and not hasAlreadyEnteredMarker then
			hasAlreadyEnteredMarker = true
			LastZone                = currentZone
			TriggerEvent('esx_impound:hasEnteredMarker', currentZone)
		end

		if not isInMarker and hasAlreadyEnteredMarker then
			hasAlreadyEnteredMarker = false
			TriggerEvent('esx_impound:hasExitedMarker', LastZone)
		end
	end
end)


Citizen.CreateThread(function()
	while true do
		Citizen.Wait(0)

		if CurrentAction ~= nil then

			SetTextComponentFormat('STRING')
			AddTextComponentString(CurrentActionMsg)
			DisplayHelpTextFromStringLabel(0, 0, 1, -1)

			if IsControlPressed(0,  Keys['E']) and (GetGameTimer() - GUI.Time) > 150 then
				if CurrentAction == 'impound_lot_menu' then
					OpenImpoundMenu()
				end

				CurrentAction = nil
				GUI.Time      = GetGameTimer()
			end
		end
	end
end)

AddEventHandler('esx_impound:hasEnteredMarker', function(zone)
	if zone == 'impound_lot' then
		CurrentAction     = 'impound_lot_menu'
		CurrentActionMsg  = "Press ~INPUT_PICKUP~ to access the impound lot"
		CurrentActionData = {}
	end
end)

AddEventHandler('esx_impound:hasExitedMarker', function(zone)
	ESX.UI.Menu.CloseAll()
	CurrentAction = nil
end)

--[[
  Determines if the player has a job that allows access to the impound lot

	Returns
	  boolean
]]
function hasImpoundAppropriateJob()
	if has_value(Config.JobsThatCanImpound, ESX.GetPlayerData().job.name) then
		return true
	else
		return false
	end
end

function drawImpoundLotMarkers()
	local coords = GetEntityCoords(GetPlayerPed(-1))

	for k,v in pairs(Config.ImpoundLots) do
		if(GetDistanceBetweenCoords(coords, v.Pos.x, v.Pos.y, v.Pos.z, true) < Config.DrawDistance) then
			DrawMarker(v.Marker, v.Pos.x, v.Pos.y, v.Pos.z, 0.0, 0.0, 0.0, 0, 0.0, 0.0, v.Size.x, v.Size.y, v.Size.z, v.Color.r, v.Color.g, v.Color.b, 100, false, true, 2, false, false, false, false)
			DrawMarker(v.RetrievePoint.Marker, v.RetrievePoint.Pos.x, v.RetrievePoint.Pos.y, v.RetrievePoint.Pos.z, 0.0, 0.0, 0.0, 0, 0.0, 0.0, v.RetrievePoint.Size.x, v.RetrievePoint.Size.y, v.RetrievePoint.Size.z, v.RetrievePoint.Color.r, v.RetrievePoint.Color.g, v.RetrievePoint.Color.b, 100, false, true, 2, false, false, false, false)
			DrawMarker(v.DropoffPoint.Marker, v.DropoffPoint.Pos.x, v.DropoffPoint.Pos.y, v.DropoffPoint.Pos.z, 0.0, 0.0, 0.0, 0, 0.0, 0.0, v.DropoffPoint.Size.x, v.DropoffPoint.Size.y, v.DropoffPoint.Size.z, v.DropoffPoint.Color.r, v.DropoffPoint.Color.g, v.DropoffPoint.Color.b, 100, false, true, 2, false, false, false, false)
		end
	end
end

function OpenImpoundMenu()
	local ply = GetPlayerPed(-1)

	ESX.UI.Menu.CloseAll()

	local elements = {
		{label = "Retrieve Vehicle", value = "retrieve_vehicle"}
	}


	if hasImpoundAppropriateJob() and IsPedInAnyVehicle(ply, true) then
		table.insert(elements, {label = "Impound Vehicle", value="impound_vehicle"})
	end


	ESX.UI.Menu.Open(
		'default', GetCurrentResourceName(), 'impound_menu',
		{
			title    = 'Impound Lot',
			align    = 'top-left',
			elements = elements,
		},
		function(data, menu)

			menu.close()
			if(data.current.value == 'retrieve_vehicle') then
				ListVehiclesMenu()
			end

			if(data.current.value == 'impound_vehicle') then
				ImpoundCurrentVehicle()
			end
		end,
		function(data, menu)
			menu.close()
		end
	)
end

--[[
  Impounds the vehicle the driver

	Returns
	  void
]]
function ImpoundCurrentVehicle()
	local vehicle = GetVehiclePedIsIn(GetPlayerPed(-1), true)
	local vprops = ESX.Game.GetVehicleProperties(vehicle)
	local plate = vprops.plate

	ESX.TriggerServerCallback('esx_impound:impound_vehicle', function()
	  ESX.ShowNotification('Vehicle has been impounded!')
	  DeleteVehicle(vehicle)
	end, plate)
end

--[[
  Determines if a table has a value in it

  Params
    tab - Table
    val - value to search

  Returns
    boolean
]]
function has_value (tab, val)
  for index, value in ipairs(tab) do
    if value == val then
        return true
    end
  end

  return false
end
