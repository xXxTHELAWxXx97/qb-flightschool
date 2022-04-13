Version 0.1a

# ITS ALIVE
I wanted a flight school and really enjoyed the functions of the original DMV script.
I frankenstined this code together by using waypoints from from the flightschool script by Desync9492 and the functions and code from the qb-core conversion of the DMV script by bamablood94

# Installation
Insert the below item into the shared.lua of qb-core
```
['fly_permit']						 = {['name'] = 'fly_permit',						['label'] = 'Pilots Permit',			['weight'] = 0,			['type'] = 'item',		['image'] = 'id_card.png',				['unique'] = true,		['useable'] = true,		['shouldClose'] = false,   ['combinable'] = nil,   ['description'] = 'A Pilots permit to show you can fly a plane as long as you have a passenger with a valid Pilots License'},
['fly_license']						       = {['name'] = 'fly',						      ['label'] = 'Pilots License',			['weight'] = 0,			['type'] = 'item',		['image'] = 'id_card.png',				['unique'] = true,		['useable'] = true,		['shouldClose'] = false,   ['combinable'] = nil,   ['description'] = 'A Pilots permit to show you can fly a plane as long as you have a passenger with a valid Pilots License'},

```

Open qb-core/server/players.lua and find:

```
PlayerData.metadata['licences'] = PlayerData.metadata['licences'] or {
```
and add this to below the existing licenses:
```
        ['fly_permit'] = false,
	  ['fly'] = false
```
Open qb-cityhall/client/main.lua and find:
```
local idTypes = {
    ["id_card"] = {
        label = "ID Card",
        item = "id_card"
    },
    ["driver_license"] = {
        label = "Drivers License",
        item = "driver_license"
    },
    ["weaponlicense"] = {
        label = "Firearms License",
        item = "weaponlicense"
    }
}
```
then add:

```
    ["fly_permit"] = {
        label = "Pilots Permit",
        item = "fly_permit"
    },
    ["fly"] = {
        label = "Pilots License",
        item = "fly"
    }
```

and replace
```
RegisterNUICallback('requestLicenses', function(data, cb)
    local PlayerData = QBCore.Functions.GetPlayerData()
    local licensesMeta = PlayerData.metadata["licences"]
    local availableLicenses = {}

    for type,_ in pairs(licensesMeta) do
        if licensesMeta[type] then
            local licenseType = nil
            local label = nil

            if type == "driver" then
                licenseType = "driver_license"
                label = "Drivers Licence"
            elseif type == "weapon" then
                licenseType = "weaponlicense"
                label = "Firearms License"
            end

            availableLicenses[#availableLicenses+1] = {
                idType = licenseType,
                label = label
            }
        end
    end
    cb(availableLicenses)
end)
```
and add:
```
            elseif type == "fly" then
                licenseType = "fly"
                label = "Pilots License"
            elseif type == "fly_permit" then
                licenseType = "fly_permit"
                label = "Pilots Permit"

```

And last go to qb-cityhall/server/main.lua and replace:
```
RegisterServerEvent('qb-cityhall:server:requestId')
AddEventHandler('qb-cityhall:server:requestId', function(identityData)
    local src = source
    local Player = QBCore.Functions.GetPlayer(src)
    local info = {}
    if identityData.item == "id_card" then
        info.citizenid = Player.PlayerData.citizenid
        info.firstname = Player.PlayerData.charinfo.firstname
        info.lastname = Player.PlayerData.charinfo.lastname
        info.birthdate = Player.PlayerData.charinfo.birthdate
        info.gender = Player.PlayerData.charinfo.gender
        info.nationality = Player.PlayerData.charinfo.nationality
    elseif identityData.item == "driver_license" then
        info.firstname = Player.PlayerData.charinfo.firstname
        info.lastname = Player.PlayerData.charinfo.lastname
        info.birthdate = Player.PlayerData.charinfo.birthdate
        info.type = "Class C Driver License"
    elseif identityData.item == "weaponlicense" then
        info.firstname = Player.PlayerData.charinfo.firstname
        info.lastname = Player.PlayerData.charinfo.lastname
        info.birthdate = Player.PlayerData.charinfo.birthdate
    end

    Player.Functions.AddItem(identityData.item, 1, nil, info)

    TriggerClientEvent('inventory:client:ItemBox', src, QBCore.Shared.Items[identityData.item], 'add')
end)
```
with

```
RegisterNetEvent('qb-cityhall:server:requestId', function(identityData)
    local src = source
    local Player = QBCore.Functions.GetPlayer(src)
    local info = {}
    if identityData.item == "id_card" then
        info.citizenid = Player.PlayerData.citizenid
        info.firstname = Player.PlayerData.charinfo.firstname
        info.lastname = Player.PlayerData.charinfo.lastname
        info.birthdate = Player.PlayerData.charinfo.birthdate
        info.gender = Player.PlayerData.charinfo.gender
        info.nationality = Player.PlayerData.charinfo.nationality
    elseif identityData.item == "driver_license" then
        info.firstname = Player.PlayerData.charinfo.firstname
        info.lastname = Player.PlayerData.charinfo.lastname
        info.birthdate = Player.PlayerData.charinfo.birthdate
        info.type = "Class C Driver License"
    elseif identityData.item == "fly" then
        info.firstname = Player.PlayerData.charinfo.firstname
        info.lastname = Player.PlayerData.charinfo.lastname
        info.birthdate = Player.PlayerData.charinfo.birthdate
    elseif identityData.item == "fly_permit" then
        info.firstname = Player.PlayerData.charinfo.firstname
        info.lastname = Player.PlayerData.charinfo.lastname
        info.birthdate = Player.PlayerData.charinfo.birthdate
        info.type = "Pilots Permit"
    end

    Player.Functions.AddItem(identityData.item, 1, nil, info)
    TriggerClientEvent('inventory:client:ItemBox', src, QBCore.Shared.Items[identityData.item], 'add')
    Player.Functions.RemoveMoney("cash", 50)
end)
```
if you would like the police to be able to grant pilots licenses then add:
```
or args[2] == "fly_permit" or args[2] == "fly"
```
after:
```
if exports["qb-policejob"]:IsCopSV(src) and Player.PlayerData.job.grade.level >= 2 then
        if args[2] == "driver" or args[2] == "weapon"
```
but before the "then"
```

#Known Bugs
There is a bug where you might not get the full functionality on existing servers for existing characters, I would highly recomend just using the grant permission in qb-police for anyone currently on your server to try it. Or you can mess around the database and add the licenses yourself if you know how.

# Planned Details
Plan to make a new route, possibly have it end up back at sandy. Or just have it teleport you back to the SA office when the training is complete.
Let me know if you want to see anything from this script and I'll try my best

# Contact Me
If you have any questions or any problems please don't hesitate to message me or ask on the qbcore discord. We are happy to help.
xXxTHE LAWxXx97#5924
QBCore Discord: https://discord.gg/pKUZvJBxq4

# Credits
Bama94#1994 - qb core version of the DMV script as well as helping me identify errors that caused the script to not work properly at first.
Desync9492 - flightschool script for esx