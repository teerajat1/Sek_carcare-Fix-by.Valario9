ESX = nil

TriggerEvent('esx:getSharedObject', function(obj) ESX = obj end)

ESX.RegisterServerCallback(GetCurrentResourceName() .. ':checkMoney', function(source, cb, money)
	local xPlayer = ESX.GetPlayerFromId(source)

	if xPlayer.getMoney() >= money then
		cb(true)
	else
		cb(false)
	end
end)

RegisterServerEvent('Sek_carcare:removemoney')
AddEventHandler('Sek_carcare:removemoney', function(money)

    local xPlayer = ESX.GetPlayerFromId(source)

    xPlayer.removeMoney(money)

end)