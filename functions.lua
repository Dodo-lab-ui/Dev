Citizen.CreateThread(function()
    while ESX == nil do
        TriggerEvent('esx:getSharedObject', function(obj)
            ESX = obj
        end)
        Citizen.Wait(0)
    end

end)


function TryToSell(pedId, coords, zone)
    if not DoesEntityExist(pedId) or IsPedDeadOrDying(pedId) or IsPedAPlayer(pedId) or IsPedFalling(pedId) then
        Citizen.Trace("disc-drugsales: ped: " .. pedId .. " not able to sell to.")
        return
    end

    cachedPeds[pedId] = true

    ClearPedTasksImmediately(pedId)

    -- math.randomseed(GetGameTimer())
    local canSell = nil
	canSell	= math.random(1, 4)
	--print(canSell)
    if canSell == 4 then
		local canCall = 0
		canCall = math.random(1, 3)
		if canCall == 3 then
			local coords = GetEntityCoords(GetPlayerPed(-1), true)
			TriggerServerEvent("MLSPD:Serveur:AppelLSPD", "Citoyen", "Tentative de vente de Drogue", coords)
			TriggerServerEvent("MBCSO:Serveur:Appel", "Citoyen", "Tentative de vente de Drogue", coords)
			ESX.ShowNotification("Désolé mais sa m'interesse pas")
		else
			ESX.ShowNotification("Désolé mais sa m'interesse pas")
		end
	else
		FreezeEntityPosition(pedId, true)
		FreezeEntityPosition(PlayerPedId(), true)
		ClearPedTasks(PlayerPedId())
        TaskTurnPedToFaceEntity(pedId, PlayerPedId(), Config.DiscussTime)
        Citizen.Wait(Config.DiscussTime / 2)
		
        PlayAnim(pedId, 'mp_common', 'givetake1_a')
        Sell(zone)
        PlayAnim(PlayerPedId(), 'mp_common', 'givetake1_a')		
        Citizen.Wait(Config.DiscussTime / 2)
		ClearPedTasks(pedId)
		ClearPedTasks(PlayerPedId())
		FreezeEntityPosition(PlayerPedId(), false)
		FreezeEntityPosition(pedId, false)
		
		
		local canCall = 0
		canCall = math.random(1, 5)
		if canCall == 5 then
			local coords = GetEntityCoords(GetPlayerPed(-1), true)
			TriggerServerEvent("MLSPD:Serveur:AppelLSPD", "Citoyen", "Tentative de vente de Drogue", coords)
			TriggerServerEvent("MBCSO:Serveur:Appel", "Citoyen", "Tentative de vente de Drogue", coords)
		end
		
    end
    ClearPedTasks(PlayerPedId())
end

-- local function PlayGiveAnim(tped)
	-- local pid = PlayerPedId()
	-- FreezeEntityPosition(pid, true)
	-- TaskPlayAnim(pid, "mp_common", "givetake2_a", 8.0, -8, 2000, 0, 1, 0,0,0)
	-- TaskPlayAnim(tped, "mp_common", "givetake2_a", 8.0, -8, 2000, 0, 1, 0,0,0)
	-- FreezeEntityPosition(pid, false)
-- end

function Sell(zone)
    ESX.TriggerServerCallback("disc-drugsales:sellDrug", function(soldDrug)
        if soldDrug then
          --  exports['mythic_notify']:SendAlert('success', "Thanks! Here's $" .. soldDrug)
			ESX.ShowNotification("succès Merci! Voici $" .. soldDrug)
			
        else
			ESX.ShowNotification("error Bien n'essayez pas de perdre mon temps si vous n'avez même pas quelque chose à vendre?")
          --  exports['mythic_notify']:SendAlert('error', "Well don't try to waste my time if you don't even have something to sell?")
        end
    end, zone)
end

function PlayAnim(ped, lib, anim, r)
    ESX.Streaming.RequestAnimDict(lib, function()
        TaskPlayAnim(ped, lib, anim, 8.0, -8, -1, r and 49 or 0, 0, 0, 0, 0)
    end)
end

