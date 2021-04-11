QBCore = nil


TriggerEvent('QBCore:GetObject', function(obj) QBCore = obj end)

local ItemList = {
    ["cash"] = "cash"
}


--CODE

local Races = {}
RegisterServerEvent('qb-streetraces:NewRace')
AddEventHandler('qb-streetraces:NewRace', function(RaceTable)
    local src = source
    local RaceId = math.random(1000, 9999)
    local Player = QBCore.Functions.GetPlayer(src)
    local cash = Player.Functions.GetItemByName('cash')



    if Player.PlayerData.items ~= nil then 
        for k, v in pairs(Player.PlayerData.items) do 
            if cash ~= nil then
                if ItemList[Player.PlayerData.items[k].name] ~= nil then 
                    if Player.PlayerData.items[k].name == "cash" and Player.PlayerData.items[k].amount >= RaceTable.amount then 
                        Player.Functions.RemoveItem("cash", RaceTable.amount, k)
                        TriggerClientEvent('inventory:client:ItemBox', source, QBCore.Shared.Items['cash'], "remove")
                        
                        Races[RaceId] = RaceTable
                        Races[RaceId].creator = GetPlayerIdentifiers(src)[1]
                        table.insert(Races[RaceId].joined, GetPlayerIdentifiers(src)[1])
                        TriggerClientEvent('qb-streetraces:SetRace', -1, Races)
                        TriggerClientEvent('qb-streetraces:SetRaceId', src, RaceId)
                        TriggerClientEvent('QBCore:Notify', src, "To Join The Race You Need To Pay $"..Races[RaceId].amount.."", 'success')
                    else
                        TriggerClientEvent('QBCore:Notify', src, "You do not have cash", 'error')   
                        break
                    end
                    

                end
            else
                TriggerClientEvent('QBCore:Notify', src, "You do not have cash", 'error')   
                break
                
            end
        end
        
        -- Player.Functions.AddMoney("cash", price, "sold pawnable items")
    end


end)

RegisterServerEvent('qb-streetraces:RaceWon')
AddEventHandler('qb-streetraces:RaceWon', function(RaceId)
    local src = source
    local xPlayer = QBCore.Functions.GetPlayer(src)

    xPlayer.Functions.AddItem("cash", Races[RaceId].pot, false)
    TriggerClientEvent('inventory:client:ItemBox', source, QBCore.Shared.Items['cash'], "add")
    --xPlayer.Functions.AddMoney('cash', Races[RaceId].pot, "race-won")
    TriggerClientEvent('QBCore:Notify', src, "You Have Won The Race And Got $"..Races[RaceId].pot, 'success')
    TriggerClientEvent('qb-streetraces:SetRace', -1, Races)
    TriggerClientEvent('qb-streetraces:RaceDone', -1, RaceId, GetPlayerName(src))
end)

RegisterServerEvent('qb-streetraces:JoinRace')
AddEventHandler('qb-streetraces:JoinRace', function(RaceId)
    local src = source
    local zPlayer = QBCore.Functions.GetPlayer(Races[RaceId].creator)
    local xPlayer = QBCore.Functions.GetPlayer(src)
    local cash = xPlayer.Functions.GetItemByName('cash')

    if zPlayer ~= nil then
        if xPlayer.PlayerData.items ~= nil then 
            for k, v in pairs(xPlayer.PlayerData.items) do 
                if cash ~= nil then
                    if ItemList[xPlayer.PlayerData.items[k].name] ~= nil then 
                        if xPlayer.PlayerData.items[k].name == "cash" and xPlayer.PlayerData.items[k].amount >= Races[RaceId].amount then 
                            xPlayer.Functions.RemoveItem("cash", Races[RaceId].amount, k)
                            TriggerClientEvent('inventory:client:ItemBox', src, QBCore.Shared.Items['cash'], "remove")
                            Races[RaceId].pot = Races[RaceId].pot + Races[RaceId].amount
                            
                            TriggerClientEvent('qb-streetraces:SetRace', -1, Races)
                            TriggerClientEvent('qb-streetraces:SetRaceId', src, RaceId)
                            TriggerClientEvent('QBCore:Notify', zPlayer.PlayerData.source, GetPlayerName(src).." Joined The Race", 'primary')
                        else
                            TriggerClientEvent('QBCore:Notify', src, "You do not have cash", 'error')   
                            break
                        end
                        

                    end
                else
                    TriggerClientEvent('QBCore:Notify', src, "You do not have cash", 'error')   
                    break
                    
                end
            end
            
            -- Player.Functions.AddMoney("cash", price, "sold pawnable items")
        end
    else
        TriggerClientEvent('QBCore:Notify', src, "The One Who Made The Race Is Offline", 'error')
        Races[RaceId] = {}
    end
    



        -- if xPlayer.PlayerData.money.cash >= Races[RaceId].amount then
        --     Races[RaceId].pot = Races[RaceId].pot + Races[RaceId].amount
        --     table.insert(Races[RaceId].joined, GetPlayerIdentifiers(src)[1])
        --     if xPlayer.Functions.RemoveMoney('cash', Races[RaceId].amount, "streetrace-joined") then
        --         TriggerClientEvent('qb-streetraces:SetRace', -1, Races)
        --         TriggerClientEvent('qb-streetraces:SetRaceId', src, RaceId)
        --         TriggerClientEvent('QBCore:Notify', zPlayer.PlayerData.source, GetPlayerName(src).." Joined The Race", 'primary')
        --     end

    
end)

QBCore.Commands.Add("createrace", "Start A Street Race", {{name="amount", help="The Stake Amount For The Race."}}, false, function(source, args)
    local src = source
    local amount = tonumber(args[1])

    local Player = QBCore.Functions.GetPlayer(src)
    local cash = Player.Functions.GetItemByName('cash')



    if Player.PlayerData.items ~= nil then 
        if GetJoinedRace(GetPlayerIdentifiers(src)[1]) == 0 then
            for k, v in pairs(Player.PlayerData.items) do 
                if cash ~= nil then
                    if ItemList[Player.PlayerData.items[k].name] ~= nil then 
                        if Player.PlayerData.items[k].name == "cash" and Player.PlayerData.items[k].amount >= amount then 
                            -- Player.Functions.RemoveItem("cash", amount, k)
                            -- TriggerClientEvent('inventory:client:ItemBox', source, QBCore.Shared.Items['cash'], "remove")
                            
                            TriggerClientEvent('qb-streetraces:CreateRace', src, amount)
                        else
                            TriggerClientEvent('QBCore:Notify', src, "You do not have cash", 'error')   
                            break
                        end
                    end
                else
                    TriggerClientEvent('QBCore:Notify', src, "You do not have cash", 'error')   
                    break
                    
                end
            end
        else
            TriggerClientEvent('QBCore:Notify', src, "You Are Already In A Race", 'error')    
        end
        -- Player.Functions.AddMoney("cash", price, "sold pawnable items")
    end

end)

QBCore.Commands.Add("stoprace", "Stop The Race You Created", {}, false, function(source, args)
    local src = source
    CancelRace(src)
end)

QBCore.Commands.Add("quitrace", "Get Out Of A Race. (You Will NOT Get Your Money Back!)", {}, false, function(source, args)
    local src = source
    local xPlayer = QBCore.Functions.GetPlayer(src)
    local RaceId = GetJoinedRace(GetPlayerIdentifiers(src)[1])
    local zPlayer = QBCore.Functions.GetPlayer(Races[RaceId].creator)

    if RaceId ~= 0 then
        if GetCreatedRace(GetPlayerIdentifiers(src)[1]) ~= RaceId then
            RemoveFromRace(GetPlayerIdentifiers(src)[1])
            TriggerClientEvent('QBCore:Notify', src, "You Have Stepped Out Of The Race! And You Lost Your Money", 'error')
        else
            TriggerClientEvent('QBCore:Notify', src, "/stoprace To Stop The Race", 'error')
        end
    else
        TriggerClientEvent('QBCore:Notify', src, "You Are Not In A Race ", 'error')
    end
end)

QBCore.Commands.Add("startrace", "Start The Race", {}, false, function(source, args)
    local src = source
    local RaceId = GetCreatedRace(GetPlayerIdentifiers(src)[1])
    
    if RaceId ~= 0 then
      
        Races[RaceId].started = true
        TriggerClientEvent('qb-streetraces:SetRace', -1, Races)
        TriggerClientEvent("qb-streetraces:StartRace", -1, RaceId)
    else
        TriggerClientEvent('QBCore:Notify', src, "You Have Not Started A Race", 'error')
        
    end
end)

function CancelRace(source)
    local RaceId = GetCreatedRace(GetPlayerIdentifiers(source)[1])
    local Player = QBCore.Functions.GetPlayer(source)

    if RaceId ~= 0 then
        for key, race in pairs(Races) do
            if Races[key] ~= nil and Races[key].creator == Player.PlayerData.steam then
                if not Races[key].started then
                    for _, iden in pairs(Races[key].joined) do
                        local xdPlayer = QBCore.Functions.GetPlayer(iden)
                           -- xdPlayer.Functions.AddMoney('cash', Races[key].amount, "race-cancelled")
                            xdPlayer.Functions.AddItem("cash", Races[key].amount, false)
                            TriggerClientEvent('inventory:client:ItemBox', source, QBCore.Shared.Items['cash'], "add")

                            TriggerClientEvent('QBCore:Notify', xdPlayer.PlayerData.source, "Race Has Stopped, You Got Back $"..Races[key].amount.."", 'error')
                            TriggerClientEvent('qb-streetraces:StopRace', xdPlayer.PlayerData.source)
                            RemoveFromRace(iden)
                    end
                else
                    TriggerClientEvent('QBCore:Notify', Player.PlayerData.source, "The Race Has Already Started", 'error')
                end
                TriggerClientEvent('QBCore:Notify', source, "Race Stopped!", 'error')
                Races[key] = nil
            end
        end
        TriggerClientEvent('qb-streetraces:SetRace', -1, Races)
    else
        TriggerClientEvent('QBCore:Notify', source, "You Have Not Started A Race!", 'error')
    end
end

function RemoveFromRace(identifier)
    for key, race in pairs(Races) do
        if Races[key] ~= nil and not Races[key].started then
            for i, iden in pairs(Races[key].joined) do
                if iden == identifier then
                    table.remove(Races[key].joined, i)
                end
            end
        end
    end
end

function GetJoinedRace(identifier)
    for key, race in pairs(Races) do
        if Races[key] ~= nil and not Races[key].started then
            for _, iden in pairs(Races[key].joined) do
                if iden == identifier then
                    return key
                end
            end
        end
    end
    return 0
end

function GetCreatedRace(identifier)
    for key, race in pairs(Races) do
        if Races[key] ~= nil and Races[key].creator == identifier and not Races[key].started then
            return key
        end
    end
    return 0
end
