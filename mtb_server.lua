local Tunnel = module("vrp","lib/Tunnel")
local Proxy = module("vrp","lib/Proxy")
local Tools = module("vrp","lib/Tools")
vRP = Proxy.getInterface("vRP")
vRPclient = Tunnel.getInterface("vRP")

mtbC = Tunnel.getInterface("mtb_hud")
mtb = {}
Tunnel.bindInterface("mtb_hud",mtb)


Citizen.CreateThread(function()
    repeat
        Citizen.Wait(200)
    until( auth )

    if auth == "autentificado" then
        if Mtb_Config.fome_sede_imbutida then
            function mtb.getHunger(user_id) -- Pegar fome
                local data = vRP.getUserDataTable(user_id)
                if data then
                    return data.hunger
                end
                return 0
            end

            function mtb.getThirst(user_id) -- Pegar sede
                local data = vRP.getUserDataTable(user_id)
                if data then
                    return data.thirst
                end
                return 0
            end

            function mtb.setHunger(user_id, value) -- Setar fome
                local source = vRP.getUserSource(user_id)
                local data = vRP.getUserDataTable(user_id)
                if data then
                    data.hunger = value
                    if data.hunger < 0 then
                        data.hunger = 0
                    elseif data.hunger > 100 then
                        data.hunger = 100 
                    end   
                end
            end

            function mtb.setThirst(user_id,value) -- Setar sede
                local source = vRP.getUserSource(user_id)
                local data = vRP.getUserDataTable(user_id)
                if data then
                    data.thirst = value
                    if data.thirst < 0 then
                        data.thirst = 0
                    elseif data.thirst > 100 then
                        data.thirst = 100
                    end    
                end
            end

            function mtb.varyHunger(user_id, variation)
        
                local source = vRP.getUserSource(user_id)
                local data = vRP.getUserDataTable(user_id)
                local esta_com_fome = false
                if data then
                    local fome = data.hunger + variation

                    if fome < 0 then
                        fome = 0
                    elseif fome >= 100 then
                        fome = 100 
                        esta_com_fome = true
                    end   

                    TriggerClientEvent("mtb_hud:updateHealth",source,user_id,data.hunger,data.thirst,esta_com_fome,true)
                end
            end

            function mtb.varyThirst(user_id, variation)

                local source = vRP.getUserSource(user_id)
                local data = vRP.getUserDataTable(user_id)
                local esta_com_sede = false
                if data then
                    local sede = data.thirst + variation

                    if sede < 0 then
                        sede = 0
                    elseif sede >= 100 then
                        sede = 100 
                        esta_com_sede = true
                    end   

                    TriggerClientEvent("mtb_hud:updateHealth",source,user_id,data.hunger,data.thirst,esta_com_sede,true)
                end
            end

            function task_update()
                local users = vRP.getUsers()
                for k,v in pairs(users) do
                    Wait(100)
                    mtb.varyHunger(tonumber(k),Mtb_Config.fome_variacao)
                    Wait(100)
                    mtb.varyThirst(tonumber(k),Mtb_Config.sede_variacao)
                end
                SetTimeout(Mtb_Config.tempo_fome_sede*1000, task_update)
            end

            async(function()
                task_update()
            end)

            AddEventHandler("vRP:playerJoin",function(user_id,source,name,last_login)
                local data = vRP.getUserDataTable(user_id)
                if data.hunger == nil then
                    data.hunger = 0
                end
                if data.thirst == nil then
                    data.thirst = 0 
                end
                TriggerClientEvent("mtb_hud:updateHealth",source,user_id,data.hunger,data.thirst,true)
            end)

            AddEventHandler("vRP:playerSpawn", function(user_id, source, first_spawn)
                local data = vRP.getUserDataTable(user_id)
                if data ~= nil then
                    if data.hunger then
                        mtb.setHunger(user_id, data.hunger)
                    end
                    if data.thirst then
                        mtb.setThirst(user_id, data.thirst)
                    end
                end
            end)
        end
    end
end)