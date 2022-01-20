Mtb_Config = {}


-------------------------------------------- Configuração --------------------------------------------

-- Caso ainda já não tenha o sistema de fome e sede na sua base coloque 'true' abaixo, e configure
-- os valores como quiser.

Mtb_Config.fome_sede_imbutida = true

Mtb_Config.fome_variacao = 1
Mtb_Config.sede_variacao = 1
Mtb_Config.dano = 5
Mtb_Config.tempo_fome_sede = 4 -- Em segundos

-------------------------------------------- Configuração --------------------------------------------





-------------------------------------------- Instalação --------------------------------------------

-- Tokovoip:
-- Acrescente o evento abaixo em seu arquivo c_TokoVoip.lua, abaixo da linha 63, logo após o 'end'.
--[[
	TriggerEvent("mtb_hud:tokovoip",self.mode)
]]

-- Vrp:
-- Caso esteja utilizando a fome e sede da própria hud acrescente esse evento no seu vrp > modules > player_state.lua:
-- Se sua base for creative o diretório será esse: vrp > server-side > player_state.lua

--[[
	RegisterServerEvent("mtb_hud:updateHealthDb")
	AddEventHandler("mtb_hud:updateHealthDb",function(user_id,hunger,thirst)
		local data = vRP.getUserDataTable(user_id)
		if data then
			data.hunger = hunger
			data.thirst = thirst 
		end
	end)
]]

-------------------------------------------- Instalação --------------------------------------------

return Mtb_Config