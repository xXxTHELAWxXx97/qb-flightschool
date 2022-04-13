QBCore = exports['qb-core']:GetCoreObject()

--Event to Remove Money from player upon failed attempt at theoritical test
RegisterNetEvent('qb-flightschool:theoryflyfailed', function()
    local amount = Config.Amount['theoretical']/2
	local _source = source
	local Player = QBCore.Functions.GetPlayer(_source)
    Player.Functions.RemoveMoney(Config.PaymentType, amount)
    TriggerClientEvent('QBCore:Notify', "You paid $"..amount.."","success")
    TriggerClientEvent('QBCore:Notify', "You failed the test. Please try again!", "error")
end)

--Event to Remove Money and Add Item upon successful attempt at theoritical test
RegisterNetEvent('qb-flightschool:theorypaymentpassed', function()
	local _source = source
	local Player = QBCore.Functions.GetPlayer(_source)
    local license = true
    local info = {}
    if Config.FlyTest then
        local info = {}
        local _source = source
        local Player = QBCore.Functions.GetPlayer(_source)
        local licenseTable = Player.PlayerData.metadata['licences']
        info.type = "Pilots Permit"
        licenseTable['fly_permit'] = true
        Player.Functions.SetMetaData('licences', licenseTable)
        Player.Functions.RemoveMoney(Config.PaymentType, Config.Amount['theoretical'])
        if Config.GiveItem then
            Player.Functions.AddItem('fly_permit', 1, nil, info)
            TriggerClientEvent('QBCore:Notify', "You passed and got your Pilots Permit", "success")
            TriggerClientEvent('inventory:client:ItemBox', _source, QBCore.Shared.Items['fly_permit'], 'add')
        else
            TriggerClientEvent('QBCore:Notify', "You passed the test. Go to City to get your Pilot Permit")
        end
        TriggerClientEvent('QBCore:Notify', "You paid $"..Config.Amount['theoretical'], "success")
    elseif Config.FlyTest == false then
        info.firstname = Player.PlayerData.charinfo.firstname
        info.lastname = Player.PlayerData.charinfo.lastname
        info.birthdate = Player.PlayerData.charinfo.birthdate
        info.type = "Pilots License"
        local licenseTable = Player.PlayerData.metadata['licences']
        licenseTable['fly'] = true
        Player.Functions.SetMetaData('licences', licenseTable)
        Player.Functions.RemoveMoney(Config.PaymentType, Config.Amount['fly'])
        if Config.GiveItem then
            Player.Functions.AddItem('fly_license', 1, nil, info)
            TriggerClientEvent('QBCore:Notify', "You passed and got your Pilots License", "success")
            TriggerClientEvent('inventory:client:ItemBox', _source, QBCore.Shared.Items['fly_license'], 'add')
        else
            TriggerClientEvent('QBCore:Notify', "You passed! Go to City Hall and get your Pilots License")
        end
        TriggerClientEvent('QBCore:Notify', "You paid $"..Config.Amount['fly'],"success")
        
    end
end)

RegisterNetEvent('qb-flightschool:flypaymentpassed', function ()
    local src = source
    local Player = QBCore.Functions.GetPlayer(src)
    local info = {}
    if Config.FlyTest then
        local info = {}
        local _source = source
        local Player = QBCore.Functions.GetPlayer(_source)
        local licenseTable = Player.PlayerData.metadata['licences']
        info.citizenid = Player.PlayerData.citizenid
        info.firstname = Player.PlayerData.charinfo.firstname
        info.lastname = Player.PlayerData.charinfo.lastname
        info.birthdate = Player.PlayerData.charinfo.birthdate
        info.gender = Player.PlayerData.charinfo.gender
        info.nationality = Player.PlayerData.charinfo.nationality
        licenseTable['fly'] = true
        Player.Functions.SetMetaData('licences', licenseTable)
        Player.Functions.RemoveMoney(Config.PaymentType, Config.Amount['fly'])
        if Config.GiveItem == true then
            Player.Functions.AddItem('fly_license', 1, nil, info)
            TriggerClientEvent('QBCore:Notify', "You passed the Pilots Test and got your Pilots License", "success")
            TriggerClientEvent('inventory:client:ItemBox', _source, QBCore.Shared.Items['fly_license'], 'add')
        else
            TriggerClientEvent('QBCore:Notify', "You passed the Pilots Test. Go to City Hall to get your License")
        end
        TriggerClientEvent('QBCore:Notify', "You paid $"..Config.Amount['fly'],"success")
    end
end)

RegisterNetEvent('qb-flightschool:flypaymentfailed', function ()
    local amount = Config.Amount['fly']/2
    local _source = source
    local Player = QBCore.Functions.GetPlayer(_source)
    Player.Functions.RemoveMoney(Config.PaymentType, amount)
    QBCore.Functions.Notify("You paid $"..amount.."","success")
end)

QBCore.Functions.CreateCallback('qb-flightschool:server:menu', function(source, cb)
    local src = source
    local Player = QBCore.Functions.GetPlayer(src)
    local licenseTable = Player.PlayerData.metadata['licences']
    if licenseTable['fly_permit'] == true then
        cb(false)
    else
        cb(true)
    end
end)

QBCore.Functions.CreateCallback('qb-flightschool:server:menu2', function(source, cb)
    local src = source
    local Player = QBCore.Functions.GetPlayer(src)
    local licenseTable = Player.PlayerData.metadata['licences']
    if licenseTable['fly'] then
        cb(false)
    elseif licenseTable['fly_permit'] and licenseTable['fly'] == false then
        cb(true)
    end
end)

