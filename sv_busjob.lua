local QBCore = exports['qb-core']:GetCoreObject()
local bus

RegisterNetEvent("stag_busjob:server:billPlayer", function(playerId, amount)
    local src = source
    local Player = QBCore.Functions.GetPlayer(src)
    local biller = Player
    local billed = QBCore.Functions.GetPlayer(tonumber(playerId))
    local amount = tonumber(amount)
    if biller.PlayerData.job.name == 'busjob' then
        if billed ~= nil then
            if biller.PlayerData.citizenid ~= billed.PlayerData.citizenid then
                if amount and amount > 0 then
                billed.Functions.RemoveMoney('bank', amount)
                QBCore.Functions.Notify('You Charged A Customer', 'success', 5000)
                QBCore.Functions.Notify(billed.PlayerData.source,'You have been charged £' ..amount.. 'for your journey', 'success', 5000)
                exports['qb-banking']:AddMoney('busjob', amount)
                else
                    QBCore.Functions.Notify(src, 'Must be a valid amount above 0', 'error', 5000)
                end
            else
                QBCore.Functions.Notify(src, 'You cannot bill yourself', 'error', 5000)
            end
        else
            QBCore.Functions.Notify(src, 'Player Not Online', 'error', 5000)
        end
    end
end)