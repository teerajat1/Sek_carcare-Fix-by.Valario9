ESX = nil

TriggerEvent('esx:getSharedObject', function(obj) ESX = obj end)

ESX.RegisterServerCallback('Sek_carcare:checkmoneyCheck', function(source, cb, checkmoneyCheck)
	local xPlayer = ESX.GetPlayerFromId(source)

	if xPlayer.getMoney() >= checkmoneyCheck then
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