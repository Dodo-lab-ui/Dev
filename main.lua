ESX = nil

local hasDrugs = false

cachedPeds = {}

OnlinePolice = 0

--Clean ped cache to avoid memory leaks
Citizen.CreateThread(function()
    while true do
        cachedPeds = {}
        Citizen.Wait(300000)
    end
end)

Citizen.CreateThread(function()
    while ESX == nil do
        TriggerEvent('esx:getSharedObject', function(obj)
            ESX = obj
        end)
        Citizen.Wait(0)
    end

    while ESX.GetPlayerData().job == nil do
        Citizen.Wait(10)
    end

    PlayerData = ESX.GetPlayerData()
end)

function canSell(pedId)
    return hasDrugs and not IsPedSittingInAnyVehicle(pedId)
end

function CanSellTo(pedId)
    return DoesEntityExist(pedId) and not IsPedDeadOrDying(pedId) and not IsPedAPlayer(pedId) and not IsPedFalling(pedId) and not cachedPeds[pedId] and not IsEntityAMissionEntity(pedId)
end

function GetPedInFront()
    local player = PlayerId()
    local plyPed = GetPlayerPed(player)
    local plyPos = GetEntityCoords(plyPed, false)
    local plyOffset = GetOffsetFromEntityInWorldCoords(plyPed, 1.3, 1.3, 0.0)
    local rayHandle = StartShapeTestCapsule(plyPos.x, plyPos.y, plyPos.z, plyOffset.x, plyOffset.y, plyOffset.z, 1.0, 12, plyPed, 7)
    local _, _, _, _, ped = GetShapeTestResult(rayHandle)
--	print(ped)
    return ped
end




Citizen.CreateThread(function()
    while true do
		Citizen.Wait(10)
		-- print(OnlinePolice)
		if Config.CopsNeeded <= OnlinePolice then
			local ped = PlayerPedId()
			local pedCoords = GetEntityCoords(ped)
			local currentZone = GetNameOfZone(pedCoords.x, pedCoords.y, pedCoords.z)
			
			-- Debug zone actuelle
			-- print("Current zone:", currentZone)
			
			if currentZone == "BEACH"  -- Vespucci Beach  
			or currentZone == "DELBE"  -- Del Perro Beach 
			or currentZone == "DELPE"  -- Del Perro 
			or currentZone == "BURTON"  -- Burton  
			or currentZone == "DTVINE" -- Downtown Vinewood
			or currentZone == "EAST_V"  -- East Vinewood  
			or currentZone == "MOVIE"  -- Richards Majestic
			or currentZone == "VESP"  -- Vespucci  
			or currentZone == "VCANA"  -- Vespucci Canals  
			or currentZone == "LMESA"  -- La Mesa  
			or currentZone == "ROCKF" -- Rockford Hills
			or currentZone == "LEGSQU"  -- Legion Square
			or currentZone == "GOLF" -- GWC and Golfing Society 
			or currentZone == "CHIL" -- Vinewood Hills 
			or currentZone == "WVINE" --  West Vinewood  
			or currentZone == "RGLEN" -- Richman Glen  
			or currentZone == "RICHM" -- Richman 			
			or currentZone == "SKID" -- Mission Row
			or currentZone == "STAD" -- Maze Bank Arena
			or currentZone == "BANHAMC" --  Banham Canyon Dr 
			or currentZone == "BHAMCA" --  Banham Canyon
			or currentZone == "MIRR" --  Mirror Park
			or currentZone == "PALETO" --  Paleto Bay
			or currentZone == "SANDY" --  Sandy Shore
			or currentZone == "VINE" then -- Vinewood  
			
			--	print("true")
				local closestPed = GetPedInFront()
				local closestpedCoords = GetEntityCoords(closestPed)
				local dist = GetDistanceBetweenCoords(pedCoords.x, pedCoords.y, pedCoords.z, closestpedCoords.x, closestpedCoords.y, closestpedCoords.z, true)
				if dist <= 1.5 and not IsPedSittingInAnyVehicle(GetPlayerPed(-1)) then
					local cs = canSell(PlayerPedId())
					local cst = CanSellTo(closestPed)
					
					-- Debug pour voir les valeurs
					-- print("Distance:", dist, "HasDrugs:", hasDrugs, "CanSell:", cs, "CanSellTo:", cst, "PedID:", closestPed)
					
					if cs and cst then
						ESX.ShowHelpNotification("Appuis sur ~INPUT_DETONATE~ pour vendre ta drogues")
					end
					if IsControlJustReleased(0, 47) and cs and cst then -- Changé de 58 à 47 (G)
						if not cachedPeds[closestPed] then
							showNotification = false
							local zone = GetNameOfZone(pedCoords.x, pedCoords.y, pedCoords.z)
							TryToSell(closestPed, pedCoords, zone)
						else
						   -- exports['mythic_notify']:SendAlert('inform', "You've already talked to me? Don't come up to me again.")
							ESX.ShowNotification("Tu m'as déjà parlé? Ne reviens pas vers moi.")
						end
			
					
					end
				else
					Citizen.Wait(1000)				
				end			
			else
				Citizen.Wait(1000)		
			end
		else
			Citizen.Wait(1000)
		end
    end
end)

Citizen.CreateThread(function()
    while true do
        Citizen.Wait(40000) -- Retour à la fréquence normale
        -- print("Checking drugs status...") -- Debug
        ESX.TriggerServerCallback('disc-drugsales:hasDrugs', function(hD)
            -- print("Server callback returned:", hD) -- Debug
            if hasDrugs ~= hD then
                if hD then
					print("Vous avez de la drogue!")
                else
					print("Vos médicaments sont consommés!")
                end
                hasDrugs = hD
                -- print("Updated hasDrugs to:", hasDrugs) -- Debug
            end
        end)
		ESX.TriggerServerCallback('disc-drugsales:getOnlinePolice', function(online)
			OnlinePolice = online
			-- print("Online police:", OnlinePolice) -- Debug
		end)
    end
end)





--##################################################################################################################
--##											Marker        							       					  ##
--##################################################################################################################


function DisplayHelpText(str)
	SetTextComponentFormat("STRING")
	AddTextComponentString(str)
	DisplayHelpTextFromStringLabel(0, 0, 1, -1)
end