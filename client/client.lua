QBCore = exports['qb-core']:GetCoreObject()

-----------------
--- Variables ---
-----------------

local src = source
local CurrentTest = nil
local LastCheckPoint = -1
local CurrentCheckPoint = 0
local CurrentZoneType   = nil
local spawnedPeds = {}

RegisterNetEvent('QBCore:Client:OnPlayerLoaded')
AddEventHandler('QBCore:Client:OnPlayerLoaded', function()
    isLoggedIn = true
    Player = QBCore.Functions.GetPlayerData()
end)

-- Opens qb-menu to select dmv options
function OpenMenu()
    exports['qb-menu']:openMenu({
      {
        header = "SA Flight School",
        isMenuHeader = true,
      },
      {
        header = "Start Theoretical Test",
        txt = "$"..Config.Amount['theoretical'].."",
        params = {
          event = 'qb-flightschool:startquiz',
          args = {
            CurrentTest = 'theory'
          }
        }
      }
    })
end
function OpenMenu2()
    exports['qb-menu']:openMenu({
      {
        header = "SA Flight School",
        isMenuHeader = true,
      },
      {
        header = "Start Flight Test",
        txt = "$"..Config.Amount['fly'].."",
        params = {
          event = 'qb-flightschool:startfly',
          args = {
            CurrentTest = 'fly'
          }
        }
      }
    })
  end
  -- Event to put in qb-menu to start driving test
  RegisterNetEvent('qb-flightschool:startfly', function()
          CurrentTest = 'fly'
          DriveErrors = 0
          LastCheckPoint = -1
          CurrentCheckPoint = 0
          IsAboveSpeedLimit = false
          CurrentZoneType = 'ground'
          local prevCoords = GetEntityCoords(PlayerPedId())
          QBCore.Functions.SpawnVehicle(Config.VehicleModels.driver, function(veh)
              TaskWarpPedIntoVehicle(PlayerPedId(), veh, -1)
              SetVehicleDoorLatched(veh, 0, true, true, false)
              exports['LegacyFuel']:SetFuel(veh, 100)
              SetEntityAsMissionEntity(veh, true, true)
              SetEntityHeading(veh, Config.Location['spawn'].w)
              TriggerEvent('vehiclekeys:client:SetOwner', QBCore.Functions.GetPlate(veh))
              TriggerServerEvent('qb-vehicletuning:server:SaveVehicleProps', QBCore.Functions.GetVehicleProperties(veh))
              LastVehicleHealth = GetVehicleBodyHealth(veh)
              CurrentVehicle = veh
              QBCore.Functions.Notify('You are taking the Flying test')
          end, Config.Location['spawn'], false)
  end)
  
  
  
  -- Event for qb-menu to run to start quiz
  RegisterNetEvent('qb-flightschool:startquiz')
  AddEventHandler('qb-flightschool:startquiz', function ()
      CurrentTest = 'theory'
      SendNUIMessage({
        Wait(10),
        openQuestion = true
      })
  
      SetTimeout(200, function ()
          SetNuiFocus(true, true)
      end)
  
  end)
  
  -- When stopping/finishing theoritical test
  function StopTheoryTest(success) 
      CurrentTest = nil
      SendNUIMessage({
        openQuestion = false
      })
      SetNuiFocus(false)
      if success then
        QBCore.Functions.Notify('You passed your test!', 'success')
        TriggerServerEvent('qb-flightschool:theorypaymentpassed')
      else
        QBCore.Functions.Notify('You failed the test!', 'error')
        TriggerServerEvent('qb-flightschool:theorypaymentfailed')
      end
  end
  
  --Stop Fly Test
  function StopFlyTest(success)
      local playerPed = PlayerPedId()
      local veh = GetVehiclePedIsIn(playerPed, true)
      if success then
        TriggerServerEvent('qb-flightschool:flypaymentpassed')
        QBCore.Functions.Notify('You passed the Flying Test!')
        QBCore.Functions.DeleteVehicle(veh)
        CurrentTest = nil
      elseif success == false then
        TriggerServerEvent('qb-flightschool:flypaymentfailed')
        QBCore.Functions.Notify('You Failed the Flying Test!')
        CurrentTest = nil
        RemoveBlip(CurrentBlip)
        QBCore.Functions.DeleteVehicle(veh)
        Wait(1000)
        SetEntityCoords(playerPed, Config.Location['marker'].x+1, Config.Location['marker'].y+1, Config.Location['marker'].z)
      end
    
      CurrentTest     = nil
      CurrentTestType = nil
    
    end
  
  -- Fly test
  Citizen.CreateThread(function()
    while true do
      Citizen.Wait(10)
      if CurrentTest == 'fly' then
        local marker = Config.Location['marker']
        local playerPed      = PlayerPedId()
        local coords         = GetEntityCoords(playerPed)
        local nextCheckPoint = CurrentCheckPoint + 1
        if Config.CheckPoints[nextCheckPoint] == nil then
          if DoesBlipExist(CurrentBlip) then
            RemoveBlip(CurrentBlip)
          end
          CurrentTest = nil
          StopFlyTest(true)
        else
          if CurrentCheckPoint ~= LastCheckPoint then
            if DoesBlipExist(CurrentBlip) then
              RemoveBlip(CurrentBlip)
            end
            CurrentBlip = AddBlipForCoord(Config.CheckPoints[nextCheckPoint].Pos.x, Config.CheckPoints[nextCheckPoint].Pos.y, Config.CheckPoints[nextCheckPoint].Pos.z)
            SetBlipRoute(CurrentBlip, 90)
            LastCheckPoint = CurrentCheckPoint
          end
          local distance = GetDistanceBetweenCoords(coords, Config.CheckPoints[nextCheckPoint].Pos.x, Config.CheckPoints[nextCheckPoint].Pos.y, Config.CheckPoints[nextCheckPoint].Pos.z, true)
          if distance <= 7000.0 then
            DrawMarker(33, Config.CheckPoints[nextCheckPoint].Pos.x, Config.CheckPoints[nextCheckPoint].Pos.y, Config.CheckPoints[nextCheckPoint].Pos.z, 0.0, 0.0, 0.0, 0, 0.0, 0.0, 10.5, 10.5, 10.5, 102, 204, 102, 100, false, true, 2, false, false, false, false)
          end
          if distance <= 7.0 then
            Config.CheckPoints[nextCheckPoint].Action(playerPed, CurrentVehicle, SetCurrentZoneType)
            CurrentCheckPoint = CurrentCheckPoint + 1
          end
        end
      end
    end
  end)
  
 -- Fail test on vehicle exit
 Citizen.CreateThread(function()
  local vehicle -- < alternatively you could move it here if you want
  local playerped
  while true do
    if CurrentTest == 'fly' then  
      playerped = GetPlayerPed(-1)
      vehicle = GetVehiclePedIsIn(playerped, false)
      if vehicle == 0 then  
        StopFlyTest(false)
      end
    end
      Citizen.Wait(500)
  end
end)


  
  -- Speed / Damage control
  Citizen.CreateThread(function()
    while true do
      Citizen.Wait(10)
        if CurrentTest == 'fly' then
            local playerPed = PlayerPedId()
            if IsPedInAnyVehicle(playerPed,  false) then
                local vehicle      = GetVehiclePedIsIn(playerPed,  false)
                local speed        = GetEntitySpeed(vehicle) * Config.SpeedMultiplier
                local tooMuchSpeed = false
                for k,v in pairs(Config.SpeedLimits) do
                    if CurrentZoneType == k and speed > v then
                    tooMuchSpeed = true
                        if not IsAboveSpeedLimit then
                            DriveErrors       = DriveErrors + 1
                            IsAboveSpeedLimit = true
                            QBCore.Functions.Notify('Flying too fast',"error")
                            QBCore.Functions.Notify("Errors:"..tostring(DriveErrors).."/" ..Config.MaxErrors, "error")
                        end
                    end
                end
                if not tooMuchSpeed then
                    IsAboveSpeedLimit = false
                end
                local health = GetVehicleBodyHealth(vehicle)
                if health < LastVehicleHealth then
                    DriveErrors = DriveErrors + 1
                    QBCore.Functions.Notify('You Damaged the Vehicle')
                    QBCore.Functions.Notify("Errors:"..tostring(DriveErrors).."/" ..Config.MaxErrors, "error")
                    LastVehicleHealth = health
                end
                if DriveErrors >= Config.MaxErrors then
                  Wait(10)
                  StopFlyTest(false)
                end
            end
        end
    end
  end)
  
  
  --Page Selections changing to different page of UI for theoritical quiz
  RegisterNUICallback('question', function(data, cb)
      SendNUIMessage({
        openSection = 'question'
      })
      cb()
  end)
  
  RegisterNUICallback('close', function(data, cb)
      StopTheoryTest(true)
      cb()
  end)
  
  RegisterNUICallback('kick', function(data, cb)
      StopTheoryTest(false)
      cb()
  end)
  
  --Block UI
  Citizen.CreateThread(function ()
      while true do
          Citizen.Wait(10)
          if CurrentTest =='theory' then
              local playerPed = GetPlayerPed(-1)
  
              DisableControlAction(0, 1, true) -- LookLeftRight
              DisableControlAction(0, 2, true) -- LookUpDown
              DisablePlayerFiring(playerPed, true) -- Disable weapon firing
              DisableControlAction(0, 142, true) -- MeleeAttackAlternate
              DisableControlAction(0, 106, true) -- VehicleMouseControlOverride
          end
      end
  end)
  
  --Blips
  Citizen.CreateThread(function ()
      blip = AddBlipForCoord(Config.Location['marker'].x, Config.Location['marker'].y, Config.Location['marker'].z)
      SetBlipSprite(blip, Config.Blip.Sprite)
      SetBlipDisplay(blip, Config.Blip.Display)
      SetBlipColour(blip, Config.Blip.Color)
      SetBlipScale(blip, Config.Blip.Scale)
      SetBlipAsShortRange(blip, Config.Blip.ShortRange)
      BeginTextCommandSetBlipName("STRING")
      AddTextComponentString(Config.Blip.BlipName)
      EndTextCommandSetBlipName(blip)
  end)
  
  --Marker
  Citizen.CreateThread(function ()
      while true do
          Citizen.Wait(0)
          local fly = Config.FlyTest
          local ped = PlayerPedId()
          local pos = GetEntityCoords(ped)
          local dist = GetDistanceBetweenCoords(pos,Config.Location['marker'].x, Config.Location['marker'].y, Config.Location['marker'].z, true)
          if dist <= 6.0 then
              local marker ={
                  ['x'] = Config.Location['marker'].x,
                  ['y'] = Config.Location['marker'].y,
                  ['z'] = Config.Location['marker'].z
              }
              DrawText3Ds(marker['x'], marker['y'], marker['z'], "[E] Open Menu")
              if dist <= 1.5 then
                if CurrentTest ~= 'fly' then
                  if IsControlJustReleased(0, 46) then
                    QBCore.Functions.TriggerCallback('qb-flightschool:server:menu', function (permit)
                        if permit == false then
                            QBCore.Functions.TriggerCallback('qb-flightschool:server:menu2', function (license)
                                if license then
                                    if fly then
                                        Wait(10)
                                        OpenMenu2()
                                    else
                                    end
                                else
                                  QBCore.Functions.Notify("You already took your tests! Go to City Hall to buy your License.")
                                end
                            end)
                        else
                          Wait(10)
                          OpenMenu()
                        end
                    end)
                  end
                elseif CurrentTest == 'fly' and IsControlJustReleased(0, 46) then
                  QBCore.Functions.Notify("You\'re already Taking the Flying Test.")
                end
              end
          end
      end
  end)
  
  
  
  -----------------DrawText3Ds Function-------------------
  DrawText3Ds = function(x,y,z, text)
      local onScreen,_x,_y=World3dToScreen2d(x,y,z)
      local factor = #text / 370
      local px,py,pz=table.unpack(GetGameplayCamCoords())
      
      SetTextScale(0.35, 0.35)
      SetTextFont(4)
      SetTextProportional(1)
      SetTextColour(255, 255, 255, 215)
      SetTextEntry("STRING")
      SetTextCentre(1)
      AddTextComponentString(text)
      DrawText(_x,_y)
      DrawRect(_x,_y + 0.0125, 0.015 + factor, 0.03, 0, 0, 0, 120)
  end
  -----------------DrawMissionText Function-------------------
  function DrawMissionText(msg, time)
      ClearPrints()
      SetTextEntry_2('STRING')
      AddTextComponentString(msg)
      DrawSubtitleTimed(time, 1)
  end
  -----------------SetCurrentZoneType Function-------------------
  function SetCurrentZoneType(type)
      CurrentZoneType = type
    end
  
  -----------------Ped Spawner-------------------
  --[[Citizen.CreateThread(function ()
    while true do
        Citizen.Wait(0)
        local drive = Config.DriversTest
        local ped = PlayerPedId()
        local pos = GetEntityCoords(ped)
        local dist = GetDistanceBetweenCoords(pos,Config.Location['marker'].x, Config.Location['marker'].y, Config.Location['marker'].z, true)
        if Config.UseTarget then
          for k,v in pairs(Config.Ped) do
            local distance = #(pos - v.coords.xyz)
            if distance < 20 and not spawnedPeds[k] then
              local spawnedPed = NearPed(v.model, v.coords, v.gender, v.animDict, v.animName, v.scenario)
              spawnedPeds[k] = { spawnedPed = spawnedPed }
            end
            if distance >= 20 and spawnedPeds[k] then
              if Config.FadeIn then
                for i = 255, 0, -51 do
                  Citizen.Wait(50)
                  SetEntityAlpha(spawnedPeds[k].spawnedPed, i, false)
                end
              end
              DeletePed(spawnedPeds[k].spawnedPed)
              spawnedPeds[k] = nil
            end
          end
          if CurrentTest ~= 'drive' then
            QBCore.Functions.TriggerCallback('qb-flightschool:server:menu', function (permit)
              if permit == false then
                QBCore.Functions.TriggerCallback('qb-flightschool:server:menu2', function (license)
                  if license then
                    if drive then
                      local models = {
                        's_m_y_cop_01'
                      }
                      exports['qb-target']:RemoveTargetModel(models, 'Take Theoretical Test')
                      exports['qb-target']:AddTargetModel(models, {
                        options = {
                          {
                            type = "client",
                            event = "qb-dmw:startdriver",
                            icon = 'fas fa-clipboard',
                            label = 'Take Drivers Test',
                          }
                        },
                        distance = 2.5,
                      })
                    else
                      QBCore.Functions.Notify('You don\'t have to take the driving test.')
                      QBCore.Functions.Notify('If you don\'t have your license, please visit the city hall')
                    end
                  else
                    exports['qb-target']:RemoveTargetModel(models, 'Take Drivers Test')
                  end
                end)
              else
                local models = {
                  's_m_y_cop_01'
                }
                exports['qb-target']:AddTargetModel(models, {
                  options = {
                    {
                      type = "client",
                      event = "qb-flightschool:startquiz",
                      icon = 'fas fa-quiz',
                      label = 'Take Theoretical Test'
                    }
                  },
                  distance = 2.5
                })
              end
            end)
          else
            QBCore.FunctionsQBCore.Functions.Notify("You\'re already Taking the Drivers Test.")
          end
        else
          if dist <= 6.0 then
            local marker ={
                ['x'] = Config.Location['marker'].x,
                ['y'] = Config.Location['marker'].y,
                ['z'] = Config.Location['marker'].z
            }
            DrawText3Ds(marker['x'], marker['y'], marker['z'], "[E] Open Menu")
            if dist <= 1.5 then
              if CurrentTest ~= 'drive' then
                if IsControlJustReleased(0, 46) then
                  QBCore.Functions.TriggerCallback('qb-flightschool:server:menu', function (permit)
                      if permit == false then
                          QBCore.Functions.TriggerCallback('qb-flightschool:server:menu2', function (license)
                              if license then
                                  if drive then
                                      Wait(10)
                                      OpenMenu2()
                                  end
                              else
                                QBCore.Functions.Notify("You already took your tests! Go to City Hall to buy your License.")
                              end
                          end)
                      else
                        Wait(10)
                        OpenMenu()
                      end
                  end)
                end
              elseif CurrentTest == 'drive' and IsControlJustReleased(0, 46) then
                QBCore.Functions.Notify("You\'re already Taking the Drivers Test.")
              end
            end
        end
        end
    end
  end)]]
  
  --PedSpawning
  --[[Citizen.CreateThread(function()
      while true do
          Citizen.Wait(500)
          for k,v in pairs(Config.Ped) do
              local playerCoords = GetEntityCoords(PlayerPedId())
              local distance = #(playerCoords - v.coords.xyz)
  
              if distance < 20 and not spawnedPeds[k] then
                  local spawnedPed = NearPed(v.model, v.coords, v.gender, v.animDict, v.animName, v.scenario)
                  spawnedPeds[k] = { spawnedPed = spawnedPed }
              end
  
              if distance >= 20 and spawnedPeds[k] then
                  if Config.FadeIn then
                      for i = 255, 0, -51 do
                          Citizen.Wait(50)
                          SetEntityAlpha(spawnedPeds[k].spawnedPed, i, false)
                      end
                  end
                  DeletePed(spawnedPeds[k].spawnedPed)
                  spawnedPeds[k] = nil
              end
          end
      end
  end)]]
  
  function NearPed(model, coords, animDict, animName, scenario)
      RequestModel(model)
      while not HasModelLoaded(model) do
          Citizen.Wait(50)
      end
  
      if Config.MinusOne then
          spawnedPed = CreatePed(Config.Ped.gendernumber, model, coords.x, coords.y, coords.z - 1.0, coords.w, false, true)
      else
          spawnedPed = CreatePed(Config.Ped.gendernumber, model, coords.x, coords.y, coords.z, coords.w, false, true)
      end
  
      SetEntityAlpha(spawnedPed, 0, false)
  
      if Config.Frozen then
          FreezeEntityPosition(spawnedPed, true)
      end
  
      if Config.Invincible then
          SetEntityInvincible(spawnedPed, true)
      end
  
      if Config.Stoic then
          SetBlockingOfNonTemporaryEvents(spawnedPed, true)
      end
  
      if animDict and animName then
          RequestAnimDict(animDict)
          while not HasAnimDictLoaded(animDict) do
              Citizen.Wait(50)
          end
  
          TaskPlayAnim(spawnedPed, animDict, animName, 8.0, 0, -1, 1, 0, 0, 0)
      end
  
      if scenario then
          TaskStartScenarioInPlace(spawnedPed, scenario, 0, true)
      end
  
      if Config.FadeIn then
          for i = 0, 255, 51 do
              Citizen.Wait(50)
              SetEntityAlpha(spawnedPed, i, false)
          end
      end
  
      return spawnedPed
  end