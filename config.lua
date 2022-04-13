Config = {}

Config.PaymentType = 'bank'                                 -- 'cash (money on some servers)' or 'bank' What account to use for payment
Config.FlyTest = true                                       --[[False = Do not have to take the Pilots test to get a Pilots License(will give fly_license after 
                                                                questionairre.) True = Requires you to take Pilots Test to get fly_license]]
Config.SpeedMultiplier = 2.236936                           --KM/H = 3.6 MPH = 2.236936
Config.MaxErrors       = 5
Config.UseTarget       = true                              --CURRENTLY NOT WORKING! (recommend leaving false until future update) Gotta fix the target menu to auto change without having to restart qb-target. True will use qb-target instead of qb-menu False will use qb-menu
--Config.Ped = 's_m_y_cop_01'
Config.Ped = {                                              --Will Spawn this ped for qb-target if Config.UseTarget is true
  {
		model = 's_m_m_pilot_01',                                 -- Ped to spawn
		coords = vector4(214.3, -1400.02, 30.58, 324.41),       -- Coordinates to spawn ped at
		gender = 'male',                                        -- Pretty obvious
    gendernumber = 4                                        -- 4 = male 5 = female
	},
}
Config.FadeIn = true                                        -- Do you want to ped to fade in as you get closer?
Config.GiveItem = true                                      -- true = will give item after passing. False = will require players to go to city hall to accuire item

Config.Amount = {
    ['theoretical'] = 200,                                   --theoretical test payment amount(If Config.FlyTest = false then the theoritical test will go to the fly test amount.)
    ['fly']         = 1000,                                  --Fly Test Payment Amount
}

Config.Location = {
    ['ped'] = vector4(-1155.04, -2715.28, 19.89, 323.03),     --Location of Ped to spawn if Config.UseTarget is true
    ['marker'] = vector3(-1155.04, -2715.28, 19.89),          --Location of Blip and marker
    ['spawn'] = vector4(-978.65, -2996.51, 11.95, 61.07)    -- Location to spawn vehicle upon starting Drivers Test
}
Config.Blip = {                                             -- Blip Config
  Sprite = 16,
  Display = 4,
  Color = 1,
  Scale = 0.8,
  ShortRange = true,
  BlipName = 'SA Flight School'
}

Config.VehicleModels = {
  driver = 'Cuban800',                                      -- Plane to spawn with Driver's Test
  cdl = 'stockade'                                          -- Truck to spawn with CDL Test
}

Config.SpeedLimits = {                                      -- Speed Limits in each zone
  ground = 25,
  air    = 400
}

Config.CheckPoints = {                                      -- Each Cheackpoint for the Drivers Test

  {
    Pos = {x = -1064.91, y = -2979.39, z = 13.96},
    Action = function(playerPed, vehicle, setCurrentZoneType)
      DrawMissionText('Start your taxi! Speed limit while taxing:~y~ ' .. Config.SpeedLimits['ground'] .. 'mph', 5000)
    end
  },

  {
    Pos = {x = -1023.24, y = -3061.04, z = 13.94},
    Action = function(playerPed, vehicle, setCurrentZoneType)
      DrawMissionText('Make sure you follow the taxi lines', 5000)
    end
  },

  {
    Pos = {x = -1011.76, y = -3129.57, z = 13.94},
    Action = function(playerPed, vehicle, setCurrentZoneType)
      Citizen.CreateThread(function()
        
      setCurrentZoneType('air')

        DrawMissionText('~g~Good~s~, Cleared for Takeoff.', 5000)

      end)
    end
  },

  {
    Pos = {x = -1478.29, y = -2867.07, z = 50.96},
    Action = function(playerPed, vehicle, setCurrentZoneType)
      Citizen.CreateThread(function()
        DrawMissionText('~g~Good~s~, gear up, keep her steady', 5000)
      end)
    end
  },

  {
    Pos = {x = -1985.79, y = -2583.05, z = 208.94},
    Action = function(playerPed, vehicle, setCurrentZoneType)
      DrawMissionText('Keep an eye around you for other aircraft~s~!', 5000)
    end
  },

  {
    Pos = {x = -3807.71, y = 19.63, z = 410.03},
    Action = function(playerPed, vehicle, setCurrentZoneType)
      DrawMissionText('Go to the next point!', 5000)
    end
  },

  {
    Pos = {x = -3267.47, y = 2473.18, z = 477.76},
    Action = function(playerPed, vehicle, setCurrentZoneType)
      DrawMissionText('Go to the next point!', 5000)
    end
  },

  {
    Pos = {x = -615.01, y = 2543.81, z = 564.87},
    Action = function(playerPed, vehicle, setCurrentZoneType)
      DrawMissionText('Go to the next point!', 5000)
    end
  },

  {
    Pos = {x = 284.09, y = 2827.10, z = 238.94},
    Action = function(playerPed, vehicle, setCurrentZoneType)
      DrawMissionText('Go to the next point!', 5000)
    end
  },

  {
    Pos = {x = 579.14, y = 2912.26, z = 169.19},
    Action = function(playerPed, vehicle, setCurrentZoneType)
      DrawMissionText('Go to the next point!', 5000)
      PlaySound(-1, 'RACE_PLACED', 'HUD_AWARDS', 0, 0, 1)
    end
  },

  {
    Pos = {x = 853.16, y = 2995.65, z = 107.86},
    Action = function(playerPed, vehicle, setCurrentZoneType)
      DrawMissionText('Prepare to land.', 5000)
    end
  },

  {
    Pos = {x = 997.62, y = 3059.63, z = 57.99},
    Action = function(playerPed, vehicle, setCurrentZoneType)
      DrawMissionText('Gently now!', 5000)
    end
  },

  {
    Pos = {x = 1120.44, y = 3095.8, z = 40.41},
    Action = function(playerPed, vehicle, setCurrentZoneType)
      DrawMissionText('AWESOME!', 5000)
    end
  },

  {
    Pos = {x = 1274.31, y = 3135.83, z = 40.41},
    Action = function(playerPed, vehicle, setCurrentZoneType)
      DrawMissionText('Great Flight!', 5000)
    end
  },

}