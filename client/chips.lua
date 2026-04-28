local priceLevels = { 100, 500, 1000, 5000, 10000, 50000 }

AddEventHandler("Casino:Client:StartChipPurchase", function()
    if not LocalPlayer.state.Character then
        return
    end

    local cash = LocalPlayer.state.Character:GetData("Cash") or 0
    local chips = exports['pulsar-casino']:ChipsGet()

    local buyMenu = {
        main = {
            label = "Purchase Casino Chips",
            items = {
                {
                    --label = "Current Chip Balance",
                    label = string.format("You Have $%s Worth of Chips", formatNumberToCurrency(math.floor(chips))),
                    --disabled = true,
                },
            },
        }
    }

    if cash >= 100 then
        local buyMax = math.floor(cash / 1000) * 1000

        if buyMax > 10000 then
            table.insert(buyMenu.main.items, {
                label = string.format("Convert All Cash To Chips ($%s)", formatNumberToCurrency(buyMax)),
                description = string.format("Convert $%s into Chips", formatNumberToCurrency(buyMax)),
                event = "Casino:Client:ConfirmChipPurchase",
                data = { amount = buyMax },
            })
        end

        for k, v in ipairs(priceLevels) do
            table.insert(buyMenu.main.items, {
                label = string.format("Buy $%s of Chips", formatNumberToCurrency(v)),
                description = string.format("Convert $%s into Chips", formatNumberToCurrency(v)),
                event = "Casino:Client:ConfirmChipPurchase",
                data = { amount = v },
                disabled = cash < v
            })
        end

        exports['pulsar-hud']:ListMenuShow(buyMenu)
    else
        exports["pulsar-hud"]:Notification("error", "Not Enough Cash - Minimum is $100")
    end
end)

AddEventHandler("Casino:Client:ConfirmChipPurchase", function(data)
    exports["pulsar-core"]:ServerCallback("Casino:BuyChips", data.amount)
end)

AddEventHandler("Casino:Client:StartChipSell", function()
    if not LocalPlayer.state.Character then
        return
    end

    local cash = LocalPlayer.state.Character:GetData("Cash") or 0
    local chips = exports['pulsar-casino']:ChipsGet()

    local buyMenu = {
        main = {
            label = "Cash Out Casino Chips",
            items = {
                {
                    --label = "Current Chip Balance",
                    label = string.format("You Have $%s Worth of Chips", formatNumberToCurrency(math.floor(chips))),
                    --disabled = true,
                },
            },
        }
    }

    if chips > 0 then
        local sellMax = math.floor(chips)

        table.insert(buyMenu.main.items, {
            label = string.format("Cash Out All Chips ($%s)", formatNumberToCurrency(sellMax)),
            description = string.format("Convert $%s worth of chips into cash", formatNumberToCurrency(sellMax)),
            event = "Casino:Client:ConfirmChipSell",
            data = { amount = sellMax },
        })

        for k, v in ipairs(priceLevels) do
            if chips >= v then
                table.insert(buyMenu.main.items, {
                    label = string.format("Cash Out $%s of Chips", formatNumberToCurrency(v)),
                    description = string.format("Convert $%s worth of chips into cash", formatNumberToCurrency(v)),
                    event = "Casino:Client:ConfirmChipSell",
                    data = { amount = v },
                })
            end
        end

        exports['pulsar-hud']:ListMenuShow(buyMenu)
    else
        exports["pulsar-hud"]:Notification("error", "No Chips to Sell")
    end
end)

AddEventHandler("Casino:Client:ConfirmChipSell", function(data)
    exports["pulsar-core"]:ServerCallback("Casino:SellChips", data.amount)
end)

exports("ChipsGet", function()
    local chips = 0
    if LocalPlayer.state.loggedIn and LocalPlayer.state.Character then
        local casinoChips = LocalPlayer.state.Character:GetData("CasinoChips")
        if casinoChips then
            chips = tonumber(casinoChips) or 0
        end
    end

    return chips
end)

exports("ChipsHas", function(amount)
    if amount > 0 then
        return exports['pulsar-casino']:ChipsGet() >= amount
    end
    return false
end)
