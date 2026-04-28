_insideCasino = false
_insideCasinoAudio = false

AddEventHandler('onClientResourceStart', function(resource)
	if resource == GetCurrentResourceName() then
		Wait(1000)
		TriggerEvent("Casino:Client:Startup")
	end
end)

RegisterNetEvent("Characters:Client:Spawn")
AddEventHandler("Characters:Client:Spawn", function()
	exports["pulsar-blips"]:Add("casino", "Diamond Casino & Resort", vector3(956.586, 36.004, 71.429), 680, 22, 1.0, 2,
		11)

	LocalPlayer.state.playingCasino = false
end)

AddEventHandler("Casino:Client:Startup", function()
	local casinoDesks = {
		{
			center = vector3(965.62, 46.99, 71.7),
			length = 3.0,
			width = 1.0,
			options = {
				heading = 58,
				--debugPoly=true,
				minZ = 71.1,
				maxZ = 72.1,
			},
		},
		{
			center = vector3(998.08, 53.86, 75.07),
			length = 1.4,
			width = 0.5,
			options = {
				heading = 328,
				--debugPoly=true,
				minZ = 74.47,
				maxZ = 75.67,
			},
		},
	}

	for k, v in ipairs(casinoDesks) do
		exports.ox_target:addBoxZone({
			id = "casino-employee-" .. k,
			coords = v.center,
			size = vector3(v.length, v.width, 1.0),
			rotation = v.options.heading or 0,
			debug = false,
			minZ = v.options.minZ,
			maxZ = v.options.maxZ,
			options = {
				{
					icon = "fas fa-clipboard-check",
					label = "Clock In",
					onSelect = function()
						TriggerEvent("Casino:Client:ClockIn", { job = "casino" })
					end,
					groups = { "casino" },
					reqOffDuty = true,
				},
				{
					icon = "fas fa-clipboard",
					label = "Clock Out",
					onSelect = function()
						TriggerEvent("Casino:Client:ClockOut", { job = "casino" })
					end,
					groups = { "casino" },
					reqDuty = true,
				},
				{
					icon = "fas fa-door-closed",
					label = "Close Casino",
					onSelect = function()
						TriggerEvent("Casino:Client:OpenClose", { state = false })
					end,
					groups = { "casino" },
					reqDuty = true,
					canInteract = function()
						return GlobalState["CasinoOpen"]
					end,
				},
				{
					icon = "fas fa-door-open",
					label = "Open Casino",
					onSelect = function()
						TriggerEvent("Casino:Client:OpenClose", { state = true })
					end,
					groups = { "casino" },
					reqDuty = true,
					canInteract = function()
						return not GlobalState["CasinoOpen"]
					end,
				},
			}
		})
	end

	exports['pulsar-pedinteraction']:Add(
		"CasinoStaff1",
		`u_f_m_casinoshop_01`,
		vector3(965.357, 48.067, 70.701),
		146.416,
		25.0,
		false,
		"seal-question",
		"WORLD_HUMAN_STAND_IMPATIENT"
	)

	exports['pulsar-pedinteraction']:Add(
		"CasinoStaff2",
		`s_m_y_casino_01`,
		vector3(951.773, 21.896, 70.904),
		346.697,
		25.0,
		false,
		"seal-question",
		"WORLD_HUMAN_GUARD_STAND"
	)

	exports['pulsar-polyzone']:CreateBox("casino_inside", vector3(1004.77, 38.26, 77.91), 129.2, 90.0, {
		heading = 305,
		--debugPoly=true,
		minZ = 62.71,
		maxZ = 78.11,
	}, {})

	exports['pulsar-polyzone']:CreatePoly("casino_audio", {
		vector2(1031.4703369141, 69.031555175781),
		vector2(1029.1315917969, 70.45630645752),
		vector2(1020.2162475586, 74.967506408691),
		vector2(1018.774230957, 67.163162231445),
		vector2(1016.8631591797, 63.980415344238),
		vector2(1010.8873291016, 63.975051879883),
		vector2(1008.0106811523, 63.327266693115),
		vector2(997.93920898438, 54.817604064941),
		vector2(998.31079101562, 57.504776000977),
		vector2(989.02960205078, 59.375911712646),
		vector2(983.41088867188, 58.477466583252),
		vector2(982.99322509766, 52.2580909729),
		vector2(963.95635986328, 51.413318634033),
		vector2(952.62396240234, 48.958881378174),
		vector2(956.68328857422, 34.952949523926),
		vector2(961.76043701172, 31.73747253418),
		vector2(955.79132080078, 8.4615421295166),
		vector2(981.96832275391, 14.115256309509),
		vector2(991.46240234375, 21.801073074341),
		vector2(1017.1166992188, 30.705118179321),
		vector2(1023.4791870117, 34.56270980835),
		vector2(1028.4720458984, 30.613445281982),
		vector2(1037.5812988281, 34.075561523438),
		vector2(1040.0360107422, 37.743408203125),
		vector2(1042.3696289062, 42.986534118652),
		vector2(1046.3763427734, 43.615371704102),
		vector2(1049.4754638672, 57.303512573242),
		vector2(1048.7061767578, 61.635692596436),
	}, {
		--debugPoly=true,
		minZ = 60.95,
		maxZ = 74.785,
	})

	exports['pulsar-pedinteraction']:Add(
		"CasinoCashier",
		`s_m_y_casino_01`,
		vector3(990.372, 31.271, 70.466),
		56.249,
		25.0,
		false,
		"seal-question"
	)

	exports.ox_target:addBoxZone({
		id = "casino-cashier",
		coords = vector3(990.35, 31.18, 71.47),
		size = vector3(5.4, 2.0, 2.8),
		rotation = 330,
		debug = false,
		minZ = 70.47,
		maxZ = 73.27,
		options = {
			{
				icon = "fas fa-inbox",
				label = "Cash Out Chips",
				event = "Casino:Client:StartChipSell",
				canInteract = function()
					return exports['pulsar-casino']:ChipsGet() > 0
				end,
			},
			{
				icon = "fas fa-inbox",
				label = "Purchase Chips",
				event = "Casino:Client:StartChipPurchase",
			},
			{
				icon = "fas fa-gift",
				label = "Purchase VIP Card ($10,000, 1 Week)",
				event = "Casino:Client:PurchaseVIP",
			},
		}
	})
end)

AddEventHandler("Polyzone:Enter", function(id, testedPoint, insideZones, data)
	if id == "casino_inside" then
		_insideCasino = true
		TriggerEvent("Casino:Client:Enter")
	elseif id == "casino_audio" then
		_insideCasinoAudio = true
		StartCasinoBackgroundAudioThread()
	end
end)

AddEventHandler("Polyzone:Exit", function(id, testedPoint, insideZones, data)
	if id == "casino_inside" then
		_insideCasino = false
		TriggerEvent("Casino:Client:Exit")
	elseif id == "casino_audio" then
		_insideCasinoAudio = false
		StopCasinoBackgroundAudio()
	end
end)

AddEventHandler("Casino:Client:ClockIn", function(data)
	if data and data.job then
		exports['pulsar-jobs']:DutyOn(data.job)
	end
end)

AddEventHandler("Casino:Client:ClockOut", function(data)
	if data and data.job then
		exports['pulsar-jobs']:DutyOff(data.job)
	end
end)

AddEventHandler("Casino:Client:OpenClose", function(data)
	exports["pulsar-core"]:ServerCallback("Casino:OpenClose", data)
end)

AddEventHandler("Casino:Client:PurchaseVIP", function(data)
	exports["pulsar-core"]:ServerCallback("Casino:PurchaseVIP", data)
end)

RegisterNetEvent("Casino:Client:RefreshInt", function()
	RefreshInterior(121090)
end)
