# esx_impound

ESX Impound is a plugin that adds impound lots around the map. Users must either wait a specified amount of time, or pay a fine, or both
before retrieving their vehicle (configurable)

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

Create your config file from the default

```
  cp config.default config.lua
```

Review and execute the esx_impound.sql file. If you wish to add additional impound locations you can do that
by adding appropriate entries to the config file.

# Additional Notes

There are some configuration options in the config file that you can adjust to your liking.
