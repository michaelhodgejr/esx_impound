Config = {}

Config = {
	DrawDistance = 100,
	BlipInfos = {
		Sprite = 477,
		Color = 54
	}
}

-- The jobs that are able to impound vehicles
Config.JobsThatCanImpound = {'police', 'tow'}

-- The time in minutes before a user is able to retrieve a vehicle from the
-- impound lot.
Config.ElapsedTimeBeforeRelease = 1


Config.ImpoundLots = {
	Sandy = {
		Pos = {x=1048.13, y= 3618.42, z= 32.2},
		Size  = {x = 3.0, y = 3.0, z = 1.0},
		Color = {r = 204, g = 204, b = 0},
		Marker = -1,
		DropoffPoint = {
			Pos = {x=1048.13, y= 3618.42, z= 32.2},
			Color = {r=58,g=100,b=122},
			Size  = {x = 3.0, y = 3.0, z = 1.0},
			Marker = 27
		},
		RetrievePoint = {
			Pos = {x=1047.72, y= 3593.72, z= 33.00},
			Color = {r=0,g=0,b=0},
			Size  = {x = 3.0, y = 3.0, z = 1.0},
			Marker = -1
		},
	}
}
