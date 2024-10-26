-- namechanger.lua
-- ESX ve QBCore için SQL tabanlı isim değiştirme scripti

local Framework = nil

-- Framework tespiti
CreateThread(function()
    if GetResourceState("qb-core") == "started" then
        Framework = "QBCore"
        QBCore = exports['qb-core']:GetCoreObject()
        print("^2[NameChanger]^7: QBCore framework algılandı.")
    elseif GetResourceState("es_extended") == "started" then
        Framework = "ESX"
        ESX = exports['es_extended']:getSharedObject()
        print("^2[NameChanger]^7: ESX framework algılandı.")
    else
        print("^1[NameChanger]^7: Desteklenen bir framework bulunamadı!")
    end
end)

-- /isimdegis komutu
RegisterCommand("isimdegis", function(source, args)
    local src = source
    local citizenid = args[1]  -- Kullanıcıdan gelen citizenid
    local newFirstName = args[2]  -- Yeni ad
    local newLastName = args[3]  -- Yeni soyad

    -- Argüman kontrolü
    if not citizenid or not newFirstName or not newLastName then
        TriggerClientEvent('chat:addMessage', src, { template = '<div class="chat-message error">Kullanım: /isimdegis [citizenid] [Yeni Ad] [Yeni Soyad]</div>' })
        return
    end

    -- Yetki kontrolü
    if Framework == "QBCore" then
        local Player = QBCore.Functions.GetPlayer(src)
        if Player and isAuthorized(Player.PlayerData.job.name) then
            UpdatePlayerName(citizenid, newFirstName, newLastName, src)
        else
            TriggerClientEvent('chat:addMessage', src, { template = '<div class="chat-message error">Bu komutu kullanma yetkiniz yok.</div>' })
        end
    elseif Framework == "ESX" then
        local xPlayer = ESX.GetPlayerFromId(src)
        if xPlayer and isAuthorized(xPlayer.getGroup()) then
            UpdatePlayerName(citizenid, newFirstName, newLastName, src)
        else
            TriggerClientEvent('chat:addMessage', src, { template = '<div class="chat-message error">Bu komutu kullanma yetkiniz yok.</div>' })
        end
    else
        print("^1[NameChanger]^7: Framework bulunamadı, isim değişikliği işlemi yapılamıyor.")
    end
end, false)

-- Yetki kontrol fonksiyonu
function isAuthorized(group)
    local authorizedGroups = { "mod", "admin", "superadmin" } -- Yetkili gruplar
    for _, authorizedGroup in ipairs(authorizedGroups) do
        if group == authorizedGroup then
            return true
        end
    end
    return false
end

-- SQL güncelleme fonksiyonu
function UpdatePlayerName(citizenid, firstName, lastName, src)
    local rowsAffected = exports.oxmysql:executeSync('UPDATE players SET firstname = ?, lastname = ? WHERE citizenid = ?', { firstName, lastName, citizenid })

    if rowsAffected > 0 then
        TriggerClientEvent('chat:addMessage', src, { template = '<div class="chat-message success">Oyuncunun adı başarıyla güncellendi: ' .. firstName .. ' ' .. lastName .. '</div>' })
        print(('^2[NameChanger]^7: %s adlı oyuncunun ismi "%s %s" olarak güncellendi.'):format(citizenid, firstName, lastName))
    else
        TriggerClientEvent('chat:addMessage', src, { template = '<div class="chat-message error">Hata: Oyuncu bulunamadı veya isim güncellenemedi.</div>' })
        print(('^1[NameChanger]^7: %s adlı oyuncunun ismi güncellenemedi.'):format(citizenid))
    end
end
