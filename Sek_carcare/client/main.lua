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

opene = false

ESX						= nil
local PlayerOnWashZone	= false
local CarCoatingList 	= {}
local HaveCarCoating 	= false

local Washing = false

local second = 1000

Checkcar = false

Citizen.CreateThread(function()
	while ESX == nil do
		TriggerEvent('esx:getSharedObject', function(obj) ESX = obj end)
		Citizen.Wait(0)
	end
	CreateMechanicPed()
end)

function LoadModel(model)
    while not HasModelLoaded(model) do
          RequestModel(model)
          Citizen.Wait(10)
    end
end

function DisplayHelpText(str)
	SetTextComponentFormat("STRING")
	AddTextComponentString(str)
	DisplayHelpTextFromStringLabel(0, 0, 1, -1)
end

DrawText3D = function(coordsx,coordsy,coordsz,text)
    SetTextScale(0.30, 0.30)
    ---SetTextColour(0, 200, 100, 255)
    SetTextEntry("STRING")
	SetFloatingHelpTextWorldPosition(1, coordsx,coordsy,coordsz)
    SetTextCentre(true)
    AddTextComponentString(text)
    SetDrawOrigin(coordsx, coordsy, coordsz + 0.5, 0)
    DrawText(0.0, 0.0)
    ClearDrawOrigin()
	SetFloatingHelpTextWorldPosition(1, x,y,z)
    SetFloatingHelpTextStyle(1, 1, 2, -1, 3, 0)
    BeginTextCommandDisplayHelp('Sek_carcare'..GetCurrentResourceName())
    EndTextCommandDisplayHelp(2, false, false, -1)
end

Citizen.CreateThread(function()

	for i=1, #Config.MechanicPedCoords, 1 do
		local blip = AddBlipForCoord(Config.MechanicPedCoords[i].x, Config.MechanicPedCoords[i].y, Config.MechanicPedCoords[i].z)

		SetBlipSprite (blip, 402)
		SetBlipDisplay(blip, 4)
		SetBlipScale  (blip, 1.0)
		SetBlipColour (blip, 64)
		SetBlipAsShortRange(blip, true)

		BeginTextCommandSetBlipName("STRING")
		AddTextComponentString((Config.Bliptext))
		EndTextCommandSetBlipName(blip)
	end

end)

function LoadAnimDict(dict)
    while (not HasAnimDictLoaded(dict)) do
        RequestAnimDict(dict)
        Citizen.Wait(10)
    end    
end


Citizen.CreateThread(function()
	while true do
		Sleep = 1000
		if HaveCarCoating then
			if IsPedSittingInAnyVehicle(GetPlayerPed(-1)) then
				local CarPlayerSit 		= GetVehiclePedIsIn(PlayerPedId(), false)
				local CarPlatePlayerSit = GetVehicleNumberPlateText(CarPlayerSit)
				for k,v in pairs(CarCoatingList) do
					if CarPlayerSit == v.CarList or CarPlatePlayerSit == v.CarPlateList then
						Sleep = 30
						SetVehicleDirtLevel(GetVehiclePedIsIn(PlayerPedId(), false), 0.0)
						WashDecalsFromVehicle(GetVehiclePedIsIn(PlayerPedId(), false), 100.0)
						RemoveDecalsFromVehicle(GetVehiclePedIsIn(PlayerPedId(), false))
					end
				end
			end
		end
		Citizen.Wait(Sleep)
	end
end)

--==========================================================================-- Repaircar

local Mechanic_Ped 			= {}
local PlayerOnRepairZone 	= false
local PlayerOnMechanicZone 	= false
local CheckCarPer 			= false
local Repairing				= false

function CreateMechanicPed()
	for k, v in pairs(Config.MechanicPedCoords) do
		LoadModel(Config.Ped)
		local PedKey = GetHashKey(Config.Ped)
		local MechanicPed = CreatePed(5, PedKey, v.x,v.y,v.z-1, false, false, false)
		SetEntityHeading(MechanicPed,v.h)
		SetEntityInvincible(MechanicPed, true)
		SetBlockingOfNonTemporaryEvents(MechanicPed, true)
		SetPedDiesWhenInjured(MechanicPed, false)
		SetPedCanRagdollFromPlayerImpact(MechanicPed, false)
		FreezeEntityPosition(MechanicPed, true)
		SetEntityAsMissionEntity(MechanicPed, true, true)
        SetEntityAsMissionEntity(MechanicPed, true, true)
		table.insert(Mechanic_Ped,{Ped = MechanicPed})
	end
end

Citizen.CreateThread(function()
	while true do
		Citizen.Wait(1000)
		local coords      = GetEntityCoords(PlayerPedId())
		local isInMarker  = false
		local currentZone = nil

		for k,v in pairs(Config.MechanicPedCoords) do
			if(GetDistanceBetweenCoords(coords, v.x,v.y,v.z, true) < 5.0) then
				isInMarker  = true
				currentZone = k
				opene = true
			end
		end

		if (isInMarker and not PlayerOnMechanicZone) or (isInMarker and LastZone ~= currentZone) then
			PlayerOnMechanicZone = true
			LastZone                = currentZone
		end
		if not isInMarker and PlayerOnMechanicZone then
			PlayerOnMechanicZone = false
			Checkcar = false
			Washing = false
		end
	end
end)

Citizen.CreateThread(function()
	while true do
		Sleep = 1000
		if PlayerOnMechanicZone then
			local CarTarget = GetVehiclePedIsIn(PlayerPedId(),false)
			local VehicleCoords = GetEntityCoords(CarTarget)
			
			for k,v in pairs(Config.Rom) do
				Sleep = 5
				if IsPedSittingInAnyVehicle(GetPlayerPed(-1)) then
					if IsDisabledControlJustPressed(0,38) then
						if not Repairing then
							if CheckBlackList() then

								SetNuiFocus(true, true)

								SendNUIMessage({
									display = true,
								})

								SendNUIMessage({
									itemLabel = v.text,
									price = v.price,
								})
							else
								exports['mythic_notify']:Sendalert('error', 'รถคันนี้ไม่สามารถซ่อมได้')
							end
						end
					end
					if opene then
						Draw(VehicleCoords.x,VehicleCoords.y,VehicleCoords.z + 1, '<font face="font4thai">~w~กด [~r~E~w~] ~w~ เพื่อเปิดเมนู ~b~ CAR CARE </font>')
					end
				end
			end
		end
		Citizen.Wait(Sleep)
	end
end)

RegisterNUICallback('Yes', function(data, cb)

	SendNUIMessage({
		clear = true,
	})

	for k,v in pairs(Config.Rom) do
		if data.item == v.text then
			if k == 'Check' then
				ESX.TriggerServerCallback('Sek_carcare:checkmoneyCheck', function(checkmoneyCheck)
					if checkmoneyCheck then
						opene = false
						Checkcar = true
						TriggerServerEvent('Sek_carcare:removemoney',v.price)
						exports['mythic_notify']:Sendalert('success', 'คุณใช้บริการเปิดดูค่ารถ ราคา '..v.price..' บาท')
					else
						exports['mythic_notify']:Sendalert('error', 'คุณมีเเงินไม่เพียงพอ')
						FreezeEntityPosition(VehicleSit, false)
					end
				end,v.price)
			elseif k == 'Repairall' then
				ESX.TriggerServerCallback('Sek_carcare:checkmoneyCheck', function(checkmoneyCheck)
					if checkmoneyCheck then
						TriggerServerEvent('Sek_carcare:removemoney',v.price)
						StartingRepairCar('all')
						exports['mythic_notify']:Sendalert('success', 'คุณใช้บริการซ่อมทั้งหมด ราคา '..v.price..' บาท')
					else
						exports['mythic_notify']:Sendalert('error', 'คุณมีเเงินไม่เพียงพอ')
						FreezeEntityPosition(VehicleSit, false)
					end
				end,v.price)
			elseif k == 'Repairout' then
				ESX.TriggerServerCallback('Sek_carcare:checkmoneyCheck', function(checkmoneyCheck)
					if checkmoneyCheck then
						TriggerServerEvent('Sek_carcare:removemoney',v.price)
						StartingRepairCar('body')
						exports['mythic_notify']:Sendalert('success', 'คุณใช้บริการซ่อมภายนอก ราคา '..v.price..' บาท')
					else
						exports['mythic_notify']:Sendalert('error', 'คุณมีเเงินไม่เพียงพอ')
						FreezeEntityPosition(VehicleSit, false)
					end
				end,v.price)
			elseif k == 'Repair' then
				ESX.TriggerServerCallback('Sek_carcare:checkmoneyCheck', function(checkmoneyCheck)
					if checkmoneyCheck then
						TriggerServerEvent('Sek_carcare:removemoney',v.price)
						StartingRepairCar('engine')
						exports['mythic_notify']:Sendalert('success', 'คุณใช้บริการซ่อมเครื่องยนต์ ราคา '..v.price..' บาท')
					else
						exports['mythic_notify']:Sendalert('error', 'คุณมีเเงินไม่เพียงพอ')
						FreezeEntityPosition(VehicleSit, false)
					end
				end,v.price)
			elseif k == 'Wash' then
				ESX.TriggerServerCallback('Sek_carcare:checkmoneyCheck', function(checkmoneyCheck)
					if checkmoneyCheck then
						TriggerServerEvent('Sek_carcare:removemoney',v.price)
						StartingWashCar('Wash')
						exports['mythic_notify']:Sendalert('success', 'คุณใช้บริการล้างรถ ราคา '..v.price..' บาท')
					else
						exports['mythic_notify']:Sendalert('error', 'คุณมีเเงินไม่เพียงพอ')
						FreezeEntityPosition(VehicleSit, false)
					end
				end,v.price)
			elseif k == 'Kloom' then
				ESX.TriggerServerCallback('Sek_carcare:checkmoneyCheck', function(checkmoneyCheck)
					if checkmoneyCheck then
						TriggerServerEvent('Sek_carcare:removemoney',v.price)
						StartingWashCar('Kloom')
						exports['mythic_notify']:Sendalert('success', 'คุณใช้บริการเคลือบแก้ว ราคา '..v.price..' บาท')
					else
						exports['mythic_notify']:Sendalert('error', 'คุณมีเเงินไม่เพียงพอ')
						FreezeEntityPosition(VehicleSit, false)
					end
				end,v.price)
			end
		end
	end

end)

RegisterNUICallback('focusOff', function(data, cb)
	SetNuiFocus(false, false)
end)

RegisterCommand("vname",function()
	local ped = GetPlayerPed(-1)
	local veh = GetVehiclePedIsIn(ped, false)
	local model = GetEntityModel(veh)
	local vehiclename = GetDisplayNameFromVehicleModel(model)
	print(vehiclename)
end)

function CheckBlackList()
	local ped = GetPlayerPed(-1)
	local veh = GetVehiclePedIsIn(ped, false)
	local model = GetEntityModel(veh)
	local vehiclename = GetDisplayNameFromVehicleModel(model)
	local IsBlacklist = false
	for k,v in pairs(Config['BlacklistName']) do
		if vehiclename == v then
			IsBlacklist = true
		end
	end
	if IsBlacklist then
		return false
	else
		return true
	end
end

function PlayEffect(pdict, pname, posx, posy, posz, size)   
    UseParticleFxAssetNextCall(pdict)
    local PlayerPed = GetPlayerPed(-1)
    local pfx = StartParticleFxLoopedAtCoord(pname, posx, posy, posz, 20.0, 20.0, GetEntityHeading(PlayerPedId()), size, true, true, true, false)
    Citizen.Wait(100)
    StopParticleFxLooped(pfx, 0)
end

Citizen.CreateThread(function()
	while true do
		Wait(7)
		if Washing then
			local playerPed  = PlayerPedId()
    		local coords = GetEntityCoords(PlayerPedId())
    		local TypePT    = "core"
    		local particle  = "ent_sht_water_tower"
			PlayEffect(TypePT, particle, coords.x+0.6, coords.y-1, coords.z+2, 5.0)
			PlayEffect(TypePT, particle, coords.x+0.6, coords.y+1, coords.z+2, 5.0)
			PlayEffect(TypePT, particle, coords.x+0.6, coords.y-2, coords.z+2, 5.0)
			
		else
			Wait(1500)
		end
	end
end)

function PlayEffect(pdict, pname, posx, posy, posz, size)   
    UseParticleFxAssetNextCall(pdict)
    local PlayerPed = GetPlayerPed(-1)
    local pfx = StartParticleFxLoopedAtCoord(pname, posx, posy, posz, 20.0, 20.0, GetEntityHeading(PlayerPedId()), size, true, true, true, false)
    Citizen.Wait(100)
    StopParticleFxLooped(pfx, 0)
end

Citizen.CreateThread(function()
	while true do
		Sleep = 1000
		if Checkcar then
			opene = false
			if IsPedSittingInAnyVehicle(GetPlayerPed(-1)) then

				for k, v in pairs(Config.MechanicPedCoords) do
					Sleep = 5
					local CarTarget = GetVehiclePedIsIn(PlayerPedId(),false)
					local CarBodyHealth = GetVehicleBodyHealth(CarTarget)
					local CarEngineHealth = GetVehicleEngineHealth(CarTarget)
					local CarBodyHealthText = '~r~BODY~s~ '..math.modf(CarBodyHealth / 10)..' %'
					local CarEngineHealthText = '~b~ENGINE~s~ '..math.modf(CarEngineHealth / 10)..' %'
					local VehicleCoords = GetEntityCoords(CarTarget)
					Draw(VehicleCoords.x,VehicleCoords.y,VehicleCoords.z + 1, '<font face="font4thai">🚍~b~ BODY ~s~'..math.modf(CarBodyHealth / 10).. 
					' %  👨‍🔧 ~r~ ENGINE ~s~'..math.modf(CarEngineHealth / 10)..' %</font>')
				end
			end
		end
		Citizen.Wait(Sleep)
	end
end)


function StartingRepairCar(type)
	for k, v in pairs(Mechanic_Ped) do
		local MechanicCoords = GetEntityCoords(v.Ped)
		for p,i in pairs(Config.MechanicPedCoords) do
			local coords      = GetEntityCoords(PlayerPedId())
			if GetDistanceBetweenCoords(coords, i.x,i.y,i.z, true) < 5.0 then
				if GetDistanceBetweenCoords(MechanicCoords, i.x,i.y,i.z, true) < 2.0 then
					local CarTarget = GetVehiclePedIsIn(PlayerPedId(),false)
					local PlayerHeading = GetEntityHeading(PlayerPedId())
					local NPCHeading 	= GetEntityHeading(v.Ped)
					local CarTargetX,CarTargetY,CarTargetZ 	= table.unpack(GetOffsetFromEntityInWorldCoords(CarTarget, 0.0, 3.0, 0.0))

					Repairing = true
					FreezeEntityPosition(CarTarget, true)


					FreezeEntityPosition(v.Ped, false)
					TaskGoStraightToCoord(v.Ped,CarTargetX,CarTargetY,CarTargetZ,1.0,-1,PlayerHeading-180,1.0)
					LoadAnimDict(Config.DictFix)
					TaskPlayAnim(v.Ped, Config.DictFix ,Config.AnimFix, 8.0, -8.0, -1, 49, -1, false, false, false )
					Citizen.Wait(Config.TimeFixcar*second)
					if type == 'all' then
						SetVehicleEngineHealth(CarTarget, 1000.0)
						SetVehicleBodyHealth(CarTarget, 1000.0)
						SetVehicleFixed(CarTarget)
					end
					if type == 'body' then
						local SaveLastEngine = GetVehicleEngineHealth(CarTarget)
						SetVehicleBodyHealth(CarTarget, 1000.0)
						SetVehicleFixed(CarTarget)
						SetVehicleEngineHealth(CarTarget, SaveLastEngine)
					end
					if type == 'engine' then
						SetVehicleEngineHealth(CarTarget, 1000.0)
					end
					ClearPedTasksImmediately(v.Ped)
					TaskGoStraightToCoord(v.Ped,i.x,i.y,i.z,1.0,-1,NPCHeading,1.0)
					FreezeEntityPosition(CarTarget, false)
					FreezeEntityPosition(v.Ped, true)
					Repairing = false
					TriggerEvent('Sek:ClearAndCreateNew')
					TriggerEvent('Sek:Quests1Update', 'carrepair')
				end
			
			end
		end
	end
end


RegisterNetEvent('Sek:ClearAndCreateNew')
AddEventHandler('Sek:ClearAndCreateNew', function()
	Citizen.Wait(1500)
	for k, v in pairs(Mechanic_Ped) do DeleteEntity(v.Ped) end
	CreateMechanicPed()
end)

AddEventHandler('onResourceStop', function(resource)
	if resource == GetCurrentResourceName() then
		for k, v in pairs(Mechanic_Ped) do DeleteEntity(v.Ped) end
	end
end)

Citizen.CreateThread(function() 
    while true do
        Sleep = 100
        if Repairing then
        	DisableControlAction(0, 75, true)
        	Sleep = 0
        end
        Citizen.Wait(Sleep)
    end
end)
Draw = function(x,y,z, text)
    AddTextEntry('Sek_job'..GetCurrentResourceName(), text)
    SetFloatingHelpTextWorldPosition(1, x,y,z)
    SetFloatingHelpTextStyle(1, 1, 2, -1, 3, 0)
    BeginTextCommandDisplayHelp('Sek_job'..GetCurrentResourceName())
    EndTextCommandDisplayHelp(2, false, false, -1)
end