AddEventHandler("Casino:Server:Startup", function()
    exports["pulsar-chat"]:RegisterStaffCommand("setcasinovehicle", function(source, args, rawCommand)
        exports["pulsar-core"]:ClientCallback(source, "Vehicles:Admin:GetVehicleInsideData", false, function(vehData)
            if vehData and vehData.model then
                local newData = {
                    vehicle = vehData.model,
                    properties = vehData.properties,
                }

                if exports['pulsar-casino']:ConfigSet("vehicle", newData) then
                    GlobalState["Casino:Vehicle"] = newData
                end
            end
        end)
    end, {
        help = "Set the Casino Vehicle to a Copy of the Vehicle You Are In",
        params = {},
    }, 0)

    exports["pulsar-chat"]:RegisterStaffCommand("clearcasinovehicle", function(source, args, rawCommand)
        if exports['pulsar-casino']:ConfigSet("vehicle", false) then
            GlobalState["Casino:Vehicle"] = false
        end
    end, {
        help = "Clear the Casino Vehicle",
        params = {},
    }, 0)

    while not _casinoConfigLoaded do
        Wait(250)
    end

    GlobalState["Casino:Vehicle"] = exports['pulsar-casino']:ConfigGet("vehicle")

    exports["pulsar-chat"]:RegisterStaffCommand("refreshcasinoint", function(source, args, rawCommand)
        TriggerClientEvent("Casino:Client:RefreshInt", source)
    end, {
        help = "Refresh the Casino Interior",
        params = {},
    }, 0)
end)
