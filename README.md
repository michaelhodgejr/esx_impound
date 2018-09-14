# esx_impound

ESX Impound is a plugin that adds impound lots around the map. Users must either wait a specified amount of time, or pay a fine, or both
before retrieving their vehicle (configurable)

If the users have the appropriate job (as defined in the config file) then they are able to impound a vehicle by driving it to the impound lot directly
or by using the /impound command.

# Requirements
ESX
esx_eden_garage

# Installation

Run inside of your server-data/resources folder

```
git clone git@github.com:michaelhodgejr/esx_impound.git [esx]/esx_impound
```

Add to your server.cfg file

```
start esx_impound
```

Create your config file from the default.

```
  cp config.default config.lua
```

Add any additional impound lots that you want in the config file. An example impound lot is below.

```lua
SandyAirField = {
  Pos = {x=1731.30, y= 3310.54, z= 40.22}, -- Position of map blip
  Size  = {x = 10.0, y = 10.0, z = 1.0}, -- Size
  Color = {r=0,g=255,b=0}, -- Blip Color
  Marker = 1,
  Type = "smallhanger", -- Type of "impound" type. Available options are nil (default), helipad, dock or small hanger

  -- table of vehicles that are able to spawn at this lot
  AllowedVehicles = {
    "duster",
    "dodo"
  },

  -- Retrieval marker
  RetrievePoint = {
    Pos = {x=1731.30, y= 3310.54, z= 40.22},
    Heading = 185.0,
    Color = {r=0,g=255,b=0},
    Size  = {x = 10.0, y = 10.0, z = 1.0},
    Marker = 1
  },

  --  marker
  DropoffPoint = {
    Pos = {x=1731.30, y= 3310.54, z= 40.22},
    Color = {r=0,g=255,b=0},
    Size  = {x = 10.0, y = 10.0, z = 1.0},
    Marker = 1
  }, 	
},
```

Review and execute the esx_impound.sql file. If you wish to add additional impound locations you can do that
by adding appropriate entries to the config file.

# Upgrading
__1.2.1 -> 1.3.0__

Add the new configuration options to your config file

```
-- Set to true if you are using a "plate" column on your owned_vehicles table (such as when using esx_migrate)
Config.OwnedVehiclesHasPlateColumn = false
```

Execute the following SQL statements

```
ALTER TABLE `impounded_vehicles` ADD COLUMN `plate` VARCHAR(12) NULL DEFAULT NULL AFTER `id`;
ALTER TABLE `impounded_vehicles` ADD INDEX `plate` (`plate`);
```


__1.1.0 -> 1.2.0__

Add the new configuration options to your config file

```
-- Determines if the ability to impound vehicles is based upon esx jobs
Config.RestrictImpoundToJobs = true

-- Determines if the ability to retrieve vehicles is based upon esx jobs
Config.RestrictRetrievalToJobs = false

-- The jobs that are able to retrieve vehicles
Config.RetrievalJobs = {'unemployed'}

```
