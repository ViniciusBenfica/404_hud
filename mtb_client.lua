local Tunnel = module("vrp","lib/Tunnel")
local Proxy = module("vrp","lib/Proxy")
vRP = Proxy.getInterface("vRP")
mtbS = Tunnel.getInterface("mtb_hud")
mtb = {}
Tunnel.bindInterface("mtb_hud", mtb)

local fome = 100
local sede = 100
local tokovoip = 3

local _abrir = true
local lockedCar = false
local plyInVeh = false
local enableController = true               -- Enable controller inputs
local seatbeltInput = 47                    -- Toggle seatbelt on/off with K or DPAD down (controller)
local seatbeltDisableExit = true            -- Disable vehicle exit when seatbelt is enabled
local seatbeltEjectSpeed = 45.0             -- Speed threshold to eject player (MPH)
local seatbeltEjectAccel = 100.0            -- Acceleration threshold to eject player (G's)
local currSpeed = 0.0
local cruiseSpeed = 999.0
local prevVelocity = {x = 0.0, y = 0.0, z = 0.0}
local seatbeltIsOn = false

Citizen.CreateThread(function()
	if Mtb_Config.fome_sede_imbutida then
		RegisterNetEvent("mtb_hud:varyHunger")
		AddEventHandler("mtb_hud:varyHunger",function(user_id, variation)
			print("ID FOME: "..user_id)
			print("VARIATION FOME: "..variation)
			mtbS.varyHunger(user_id, variation)
		end)

		RegisterNetEvent("mtb_hud:varyThirst")
		AddEventHandler("mtb_hud:varyThirst",function(user_id, variation)
			print("ID SEDE: "..user_id)
			print("VARIATION SEDE: "..variation)
			mtbS.varyThirst(user_id, variation)
		end)
	end

	local movie = false
	RegisterCommand("movie",function(source)
		SendNUIMessage({action = "movie"})
		if movie then
			if seatbeltIsOn then
				DisplayRadar(true)
			end
			movie = false
		else
			DisplayRadar(false)
			movie = true
		end
	end)

	local hud = false
	RegisterCommand("hud",function(source)
		if not movie then
			hud = not hud
			SendNUIMessage({action = "abrirFechar"})
		end
	end)
	
	RegisterNetEvent("mtb_hud:tokovoip")
	AddEventHandler("mtb_hud:tokovoip",function(_voip)
		if _voip == 1 then
			tokovoip = 2
		elseif _voip == 2 then
			tokovoip = 1
		elseif _voip == 3 then
			tokovoip = 3
		end
	end)

	local function startThread()
		while true do
			local sleep = 500
			local ped = PlayerPedId()
			local vida = GetEntityHealth(ped)
			local colete = GetPedArmour(ped)
			local x, y, z, street, veiculo, gasolina, trancado, velocidade, farol, setas = 0
			local dentroDoCarro = false
			local farolDesligado, farolMedio, farolAlto = 0, 0, 0

			if IsPedInAnyVehicle(ped, false) then
				sleep = 100
				x,y,z = table.unpack(GetEntityCoords(ped))
				street = GetStreetNameFromHashKey(GetStreetNameAtCoord(x,y,z))
				veiculo = GetVehiclePedIsIn(ped, false)
				dentroDoCarro = true 
				gasolina = GetVehicleFuelLevel(veiculo)
				velocidade = GetEntitySpeed(veiculo)
				kmh = velocidade * 3.6
				farolDesligado,farolMedio,farolAlto = GetVehicleLightsState(veiculo)
				setas = GetVehicleIndicatorLights(veiculo)
			else
				dentroDoCarro = false
				gasolina = 0
				kmh = 0
				setas = 0
			end

			if movie or hud then
				_abrir = false
			else
				_abrir = true
			end

			SendNUIMessage({
				abrir = _abrir,
				dentroDoCarro = dentroDoCarro, 
				vida = vida - 100,
				colete = colete, 
				street = street, 
				gasolina = gasolina,
				kmh = kmh,
				farol = farolDesligado + farolMedio + farolAlto,
				setas = setas,
				fome = 100-fome,
				sede = 100-sede,
				lockedCar = GetVehicleDoorLockStatus(veiculo),
				horas = GetClockHours(),
				minutos = GetClockMinutes(),
				tokovoip = tokovoip,
			})

			if vida <= 101 then sleep = 1000 end 
			Citizen.Wait(sleep)
		end
	end

	Citizen.CreateThread(function()
		while true do
			Citizen.Wait(250)
			if IsEntityVisible(PlayerPedId()) then
				startThread()
				break
			end
		end
	end)

	Citizen.CreateThread(function()
		while true do
			local mtb_sleep = 1000
			local ply = PlayerPedId()
			if IsPedInAnyVehicle(ply, false) then
				mtb_sleep = 700
				local plyCoords = GetEntityCoords(ply)	
				local vehicle = GetVehiclePedIsIn(ply, false)     
				local vehicleClass = GetVehicleClass(vehicle)

				if vehicleClass ~= 13 and vehicleClass ~= 8 then
					if GetIsVehicleEngineRunning(vehicle) then
						mtb_sleep = 0
						
						local prevSpeed = currSpeed
						currSpeed = GetEntitySpeed(vehicle)
						SetPedConfigFlag(ply, 32, true)
						if IsControlJustReleased(0, seatbeltInput) and (enableController or GetLastInputMethod(0)) then 
							if seatbeltIsOn then
								TriggerEvent("vrp_sound:source", 'unbelt', 0.5)
								if not movie then
									DisplayRadar(false)
								end
								SendNUIMessage({cinto = "off"})
								SetTimeout(1400, function()
									SeatBelt = false
									TriggerEvent("cancelando", false)
								end)
							elseif not seatbeltIsOn then
								TriggerEvent("vrp_sound:source", 'belt', 0.5)
								if not movie then
									DisplayRadar(true)
								end
								SetTimeout(1400, function()
									SeatBelt = true
									SendNUIMessage({cinto = "on"})
									TriggerEvent("cancelando", false)
								end)
							end
							seatbeltIsOn = not seatbeltIsOn
						end

						if not seatbeltIsOn then
							local vehIsMovingFwd = GetEntitySpeedVector(vehicle, true).y > 1.0
							local vehAcc = (prevSpeed - currSpeed) / GetFrameTime()
							if (vehIsMovingFwd and (prevSpeed > (seatbeltEjectSpeed/2.237)) and (vehAcc > (seatbeltEjectAccel*9.81))) then
								SetEntityCoords(ply, plyCoords.x, plyCoords.y, plyCoords.z - 0.47, true, true, true)
								SetEntityVelocity(ply, prevVelocity.x, prevVelocity.y, prevVelocity.z)
								Citizen.Wait(0)
								SetPedToRagdoll(ply, 1000, 1000, 0, 0, 0, 0)
							else
								prevVelocity = GetEntityVelocity(vehicle)
							end
						elseif seatbeltDisableExit then
							DisableControlAction(0, 75)
						end
					end
				else
					if not movie then
						DisplayRadar(true)
					end
				end
			else
				DisplayRadar(false)
			end
			Citizen.Wait(mtb_sleep)
		end
	end)

	RegisterNetEvent("mtb_hud:updateHealth")
	AddEventHandler("mtb_hud:updateHealth",function(user_id,hunger,thirst,esta_zuado,update)
		fome = hunger
		sede = thirst

		if esta_zuado then 
			local ped = PlayerPedId()
			SetEntityHealth(ped,GetEntityHealth(ped)-Mtb_Config.dano)
		end
		if update then 
			TriggerServerEvent("mtb_hud:updateHealthDb",user_id,fome,sede)
		end
	end)
	
end)