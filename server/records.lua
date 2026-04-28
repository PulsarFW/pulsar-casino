function UpdateCharacterCasinoStats(source, statType, isWin, amount)
    local char = exports['pulsar-characters']:FetchCharacterSource(source)
    if char then
        local p = promise.new()
        local update = {}

        if isWin then
            update["$inc"] = {
                TotalAmountWon = amount,
                [string.format("AmountWon.%s", statType)] = amount,
            }
        else
            update["$inc"] = {
                TotalAmountLost = amount,
                [string.format("AmountLost.%s", statType)] = amount,
            }
        end

        exports.oxmysql:execute('SELECT * FROM casino_statistics WHERE SID = ?', { char:GetData("SID") },
            function(existingResults)
                if existingResults and #existingResults > 0 then
                    local existing = existingResults[1]
                    local stats = existing[statType] and json.decode(existing[statType]) or {}
                    local amountWon = existing.AmountWon and json.decode(existing.AmountWon) or {}
                    local amountLost = existing.AmountLost and json.decode(existing.AmountLost) or {}

                    table.insert(stats, {
                        Win = isWin,
                        Amount = amount,
                    })

                    if isWin then
                        existing.TotalAmountWon = (existing.TotalAmountWon or 0) + amount
                        amountWon[statType] = (amountWon[statType] or 0) + amount
                    else
                        existing.TotalAmountLost = (existing.TotalAmountLost or 0) + amount
                        amountLost[statType] = (amountLost[statType] or 0) + amount
                    end

                    exports.oxmysql:execute(
                        'UPDATE casino_statistics SET `' ..
                        statType ..
                        '` = ?, AmountWon = ?, AmountLost = ?, TotalAmountWon = ?, TotalAmountLost = ? WHERE SID = ?',
                        { json.encode(stats), json.encode(amountWon), json.encode(amountLost), existing.TotalAmountWon,
                            existing.TotalAmountLost, char:GetData("SID") },
                        function(affectedRows)
                            local success = false
                            if affectedRows then
                                if type(affectedRows) == "table" then
                                    success = affectedRows.affectedRows and affectedRows.affectedRows > 0
                                else
                                    success = affectedRows > 0
                                end
                            end
                            p:resolve(success)
                        end)
                else
                    local stats = { {
                        Win = isWin,
                        Amount = amount,
                    } }
                    local amountWon = {}
                    local amountLost = {}

                    if isWin then
                        amountWon[statType] = amount
                    else
                        amountLost[statType] = amount
                    end

                    exports.oxmysql:execute(
                        'INSERT INTO casino_statistics (SID, `' ..
                        statType ..
                        '`, AmountWon, AmountLost, TotalAmountWon, TotalAmountLost) VALUES (?, ?, ?, ?, ?, ?)',
                        { char:GetData("SID"), json.encode(stats), json.encode(amountWon), json.encode(amountLost), isWin and
                        amount or 0, isWin and 0 or amount },
                        function(insertId)
                            local success = false
                            if insertId then
                                if type(insertId) == "table" then
                                    success = insertId.insertId and insertId.insertId > 0
                                else
                                    success = insertId > 0
                                end
                            end
                            p:resolve(success)
                        end)
                end
            end)

        local res = Citizen.Await(p)
        return res
    end
    return false
end

function SaveCasinoBigWin(source, machine, prize, data)
    local char = exports['pulsar-characters']:FetchCharacterSource(source)
    if char then
        local p = promise.new()

        local winnerJson = json.encode({
            SID = char:GetData("SID"),
            First = char:GetData("First"),
            Last = char:GetData("Last"),
            ID = char:GetData("ID"),
        })
        local metaDataJson = json.encode(data)

        exports.oxmysql:execute(
            'INSERT INTO casino_bigwins (Type, Time, Winner, Prize, MetaData) VALUES (?, ?, ?, ?, ?)',
            { machine, os.time(), winnerJson, prize, metaDataJson },
            function(insertId)
                local success = false
                if insertId then
                    if type(insertId) == "table" then
                        success = insertId.insertId and insertId.insertId > 0
                    else
                        success = insertId > 0
                    end
                end
                p:resolve(success)
            end)

        local res = Citizen.Await(p)
        return res
    end
    return false
end
