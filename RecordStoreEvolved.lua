---@diagnostic disable: undefined-global


----------- VARIABLES -----------

local version = 1.0


local config = json.load_file("RecordStoreEvolved.json") or {}
config.Version = config.Version == nil and 1.0 or config.Version
config.Enabled = config.Enabled == nil and true or config.Enabled
config.RecordSoundEnabled = config.RecordSoundEnabled == nil and true or config.RecordSoundEnabled
config.SavedSoundId = config.SavedSoundId == nil and 3819689307 or config.SavedSoundId
config._Records = config._Records == nil and {} or config._Records


local sounds = {
    ["Transportation Start"]        = 133292522,
    ["Wyvern Riding Skill Trigger"] = 3819689307,
    ["Wyvern Riding Wire Gauge"]    = 1162374642,
    ["Wyvern Riding Skill Gauge"]   = 2462913113
}


local weapons = {
    ["0"]   = "GS",
    ["1"]   = "SA",
    ["2"]   = "LS",
    ["3"]   = "LBG",
    ["4"]   = "HBG",
    ["5"]   = "Hammer",
    ["6"]   = "GL",
    ["7"]   = "Lance",
    ["8"]   = "SnS",
    ["9"]   = "DB",
    ["10"]  = "HH",
    ["11"]  = "CB",
    ["12"]  = "IG",
    ["13"]  = "Bow"
}


local filteredList = {}
for k,v in pairs(sounds) do
    filteredList[v] = k
end


----------- MANAGERS -----------


local isManagersInitialized = false
local gm = {}
gm.ChatManager = {}
gm.ChatManager.r = "snow.gui.ChatManager"
gm.QuestManager = {}
gm.QuestManager.r = "snow.QuestManager"
gm.LobbyManager = {}
gm.LobbyManager.r = "snow.LobbyManager"
gm.PlayerManager = {}
gm.PlayerManager.r = "snow.player.PlayerManager"


----------- FUNCTIONS -----------


local function SaveSettings()
    if json.load_file("RecordStoreEvolved.json") ~= config then
        json.dump_file("RecordStoreEvolved.json", config)
    end
end


local function GetCurrentUTCTimeEpoch()
    return os.time(os.date("!*t"))
end


local function TableHasElements(table)
    for _,__ in pairs(table) do
        return true
    end

    return false
end


local function GetTableLastIndex(table, toString)
    local length = 0
    for _,__ in pairs(table) do
        length = length + 1
    end

    if toString == true then
        return tostring(length)
    end

    return length
end


local function GetWeaponTypeId()
    local player = gm.PlayerManager.i:call("findMasterPlayer")
    local weaponTypeField = sdk.find_type_definition("snow.player.PlayerBase"):get_field("_playerWeaponType")

    return tostring(weaponTypeField:get_data(player))
end


local function FormatRecordTimeString(record)
    local minutes = 0
    local seconds = record % 60
      
    for i = 1, record, 1
    do
        if i % 60 == 0 then
            minutes = minutes + 1
        end
    end

    local secondsThreeDecimals = string.format("%.3f", seconds)
    local secondsFormatted = secondsThreeDecimals:gsub("%.", "''")
    return  minutes .. "'" .. secondsFormatted
end


local function PrintRecordsForActiveQuest()
    if gm.QuestManager.i:call("isActiveQuest") then
        local questId = tostring(gm.QuestManager.i:call("get_ActiveQuestNo"))
        if config._Records[questId] then
            local anyRecordsForWeaponType = false
            local weaponId = GetWeaponTypeId()
            local message = "<COL YEL>" .. weapons[weaponId] .. "</COL> records for this quest: <COL YEL>(" .. questId .. ")</COL>"

            if config._Records[questId]["1"] and config._Records[questId]["1"][weaponId] then
                local lastIndex = GetTableLastIndex(config._Records[questId]["1"][weaponId], true)
                local lastElement = config._Records[questId]["1"][weaponId][lastIndex]
                message = message .. "\nSolo Record: <COL YEL>" ..  FormatRecordTimeString(lastElement.time) .. "</COL>"
                if not anyRecordsForWeaponType then anyRecordsForWeaponType = true end
            end

            if config._Records[questId]["2"] and config._Records[questId]["2"][weaponId] then
                local lastIndex = GetTableLastIndex(config._Records[questId]["2"][weaponId], true)
                local lastElement = config._Records[questId]["2"][weaponId][lastIndex]
                message = message .. "\n2-Man Record: <COL YEL>" ..  FormatRecordTimeString(lastElement.time) .. "</COL>"
                if not anyRecordsForWeaponType then anyRecordsForWeaponType = true end
            end

            if config._Records[questId]["3"] and config._Records[questId]["3"][weaponId] then
                local lastIndex = GetTableLastIndex(config._Records[questId]["3"][weaponId], true)
                local lastElement = config._Records[questId]["3"][weaponId][lastIndex]
                message = message .. "\n3-Man Record: <COL YEL>" ..  FormatRecordTimeString(lastElement.time) .. "</COL>"
                if not anyRecordsForWeaponType then anyRecordsForWeaponType = true end
            end

            if config._Records[questId]["4"] and config._Records[questId]["4"][weaponId] then
                local lastIndex = GetTableLastIndex(config._Records[questId]["4"][weaponId], true)
                local lastElement = config._Records[questId]["4"][weaponId][lastIndex]
                message = message .. "\n4-Man Record: <COL YEL>" ..  FormatRecordTimeString(lastElement.time) .. "</COL>"
                if not anyRecordsForWeaponType then anyRecordsForWeaponType = true end
            end

            if not anyRecordsForWeaponType then 
                message = "Quest <COL YEL>(" .. questId .. ")</COL> has records, but not for <COL YEL>" .. weapons[weaponId] .. "</COL>"
            end

            gm.ChatManager.i:call("reqAddChatInfomation", message, 2289944406)
        else
            local message = "No records for this quest <COL YEL>(" .. questId .. ")</COL>"
            gm.ChatManager.i:call("reqAddChatInfomation", message, 2289944406)
        end
    else
        gm.ChatManager.i:call("reqAddChatInfomation", "No active quest", 2289944406)
    end
end


-- local function DeleteRecordForActiveQuest()
--     if gm.QuestManager.i:call("isActiveQuest") then
--         local questId = tostring(gm.QuestManager.i:call("get_ActiveQuestNo"))
--         if config.Records[questId] then
--             local partySize = tostring(gm.LobbyManager.i:call("getQuestPlayerCount"))
--             local weaponId = GetWeaponTypeId()

--             if config.Records[questId][partySize] and config.Records[questId][partySize][weaponId] then
--                 config.Records[questId][partySize][weaponId] = nil

--                 if not TableHasElements(config.Records[questId][partySize]) then
--                     config.Records[questId][partySize] = nil
--                 end

--                 if not TableHasElements(config.Records[questId]) then
--                     config.Records[questId] = nil
--                 end

--                 SaveSettings()

--                 local message = "Deleted record of party size <COL YEL>" .. partySize .. "</COL> for this quest <COL YEL>(" .. questId .. ")</COL>"
--                 gm.ChatManager.i:call("reqAddChatInfomation", message, 2289944406)
--             else
--                 local message = "No <COL YEL>" .. weapons[weaponId] .. "</COL> records of party size <COL YEL>" .. partySize .. "</COL> for this quest <COL YEL>(" .. questId .. ")</COL>"
--                 gm.ChatManager.i:call("reqAddChatInfomation", message, 2289944406)
--             end
--         else
--             local message = "No records for this quest <COL YEL>(" .. questId .. ")</COL>"
--             gm.ChatManager.i:call("reqAddChatInfomation", message, 2289944406)
--         end
--      else
--         gm.ChatManager.i:call("reqAddChatInfomation", "No active quest", 2289944406)
--     end
-- end


local function FormatRecordString(newRecord, oldRecord, partySize, weaponType)
    local newRecordString = FormatRecordTimeString(newRecord)
    local oldRecordString = FormatRecordTimeString(oldRecord)

    local recordString = "New <COL YEL>" .. weaponType .. "</COL> Solo Record: <COL YEL>" .. newRecordString .. "</COL>"

    if (partySize > 1) then
        recordString = "New <COL YEL>" .. weaponType .. "</COL> " .. partySize .. "-Man Record: <COL YEL>" .. newRecordString .. "</COL>"
    end

    if oldRecord ~= (gm.QuestManager.i:call("getQuestMaxTimeMin") * 60) then
        recordString = recordString .. "\nOld Record: <COL YEL>" .. oldRecordString .. "</COL>"
    end

    return recordString
end


local function MapRecordsToNewFormat()
    local oldRecords = config._Records
    local weaponId = GetWeaponTypeId()

    local mappedRecords = {}
    for questId, entries in pairs(oldRecords) do
        mappedRecords[questId] = {}

        for partySize, _ in pairs(entries) do
            mappedRecords[questId][partySize] = {}
            mappedRecords[questId][partySize][weaponId] = {}
            -- mappedRecords[questId][partySize][weaponId] = recordTime

            for recordNumber, entryData in pairs(mappedRecords[questId][partySize][weaponId]) do
                local recordNumberString = tostring(recordNumber)
                mappedRecords[questId][partySize][weaponId][recordNumberString] = {}
                mappedRecords[questId][partySize][weaponId][recordNumberString]["time"] = {}
                mappedRecords[questId][partySize][weaponId][recordNumberString]["time"] = entryData.time
                mappedRecords[questId][partySize][weaponId][recordNumberString]["epoch"] = {}
                mappedRecords[questId][partySize][weaponId][recordNumberString]["epoch"] = entryData.epoch
            end
        end
    end

    return mappedRecords
end


local function UpdateConfigVersionAndRecords()
    config.Version = version

    if TableHasElements(config._Records) then
        local formattedRecords = MapRecordsToNewFormat()

        config._Records = {}
        config._Records = formattedRecords
        gm.ChatManager.i:call("reqAddChatInfomation", "Existing records mapped to\nversion <COL YEL>" .. config.Version .. "</COL>", 1 and 2289944406)
    end

    SaveSettings()
end


local function ValidateManagers()
    if isManagersInitialized then
        return true
    end

    local success = true
    for k,v in pairs(gm) do
        v.i = sdk.get_managed_singleton(v.r)
        if not v.i then
            if success then success = false end
        end
    end

    isManagersInitialized = success

    return isManagersInitialized
end


local function ValidateRecords(questId, partySize, weaponType)
    if not config._Records[questId] then
        config._Records[questId] = {}
    end

    if not config._Records[questId][partySize] then
        config._Records[questId][partySize] = {}
    end

    if not config._Records[questId][partySize][weaponType] then
        config._Records[questId][partySize][weaponType] = {}
    end

    -- if not config.Records[questId][partySize][weaponType]["1"] then
    --     config.Records[questId][partySize][weaponType]["1"] = {}
    -- end

    if GetTableLastIndex(config._Records[questId][partySize][weaponType], false) == 0 then
        config._Records[questId][partySize][weaponType]["1"] = {}
    end

    for recordNumber, _ in pairs(config._Records[questId][partySize][weaponType]) do
        local recordNumberString = tostring(recordNumber)
        if not config._Records[questId][partySize][weaponType][recordNumberString] then
            config._Records[questId][partySize][weaponType][recordNumberString] = {}
        end

        if not config._Records[questId][partySize][weaponType][recordNumberString]["time"] then
            config._Records[questId][partySize][weaponType][recordNumberString]["time"] = gm.QuestManager.i:call("getQuestMaxTimeMin") * 60
        end

        if not config._Records[questId][partySize][weaponType][recordNumberString]["epoch"] then
            config._Records[questId][partySize][weaponType][recordNumberString]["epoch"] = -1
        end
    end
end


local function QuestClear()
    if not ValidateManagers() then
        return
    end

    if not config.Enabled then
        return
    end
    
    local partySize = gm.LobbyManager.i:call("getQuestPlayerCount")
    if partySize < 1 or partySize > 4 then
        gm.ChatManager.i:call("reqAddChatInfomation", "Invalid party size: <COL YEL>" .. partySize .. "</COL>. Not storing record", 1 and 2140680201)
        return
    end

    if config.Version ~= version then
        UpdateConfigVersionAndRecords()
    end

    local questId = tostring(gm.QuestManager.i:call("get_ActiveQuestNo"))
    local questTime = tonumber(string.format("%.3f", gm.QuestManager.i:call("getQuestElapsedTimeSec")))
    local weaponTypeId = GetWeaponTypeId()
    local partySizeString = tostring(partySize)

    ValidateRecords(questId, partySizeString, weaponTypeId)

    local currentRecordIndex = GetTableLastIndex(config._Records[questId][partySizeString][weaponTypeId], false)
    local currentRecordIndexString = tostring(currentRecordIndex)
    local currentRecord = config._Records[questId][partySizeString][weaponTypeId][currentRecordIndexString]
    if questTime >= currentRecord.time then
        return
    end

    -- nextRecordIndex = currentRecord.epoch != -1 ? currentRecordIndex + 1 : currentRecordIndex
    local nextRecordIndex = currentRecord.epoch ~= -1 and currentRecordIndex + 1 or currentRecordIndex
    local nextRecordIndexString = tostring(nextRecordIndex)
    config._Records[questId][partySizeString][weaponTypeId][nextRecordIndexString] = {}
    config._Records[questId][partySizeString][weaponTypeId][nextRecordIndexString]["time"] = questTime
    config._Records[questId][partySizeString][weaponTypeId][nextRecordIndexString]["epoch"] = GetCurrentUTCTimeEpoch()
    SaveSettings()

    local message = FormatRecordString(questTime, currentRecord.time, partySize, weapons[weaponTypeId])
    gm.ChatManager.i:call("reqAddChatInfomation", message, config.RecordSoundEnabled and config.SavedSoundId or 0)
end


----------- HOOKS -----------


sdk.hook(
    sdk.find_type_definition("snow.QuestManager"):get_method("setQuestClear"),
    nil,
    QuestClear
)


----------- CALLBACKS -----------


re.on_draw_ui(function()
    if imgui.tree_node("Record Store Evolved") then
        if ValidateManagers() then
            if config.Version ~= version then
                if gm.PlayerManager.i:call("findMasterPlayer") and TableHasElements(config._Records) then
                    if imgui.button("Update Records") then
                        UpdateConfigVersionAndRecords()
                    end
                end
            end

            _, config.Enabled = imgui.checkbox("Enable Record Storing", config.Enabled)
            _, config.RecordSoundEnabled = imgui.checkbox("Enable Record Sound", config.RecordSoundEnabled)
            if config.RecordSoundEnabled then
                _, config.SavedSoundId = imgui.combo(" ", config.SavedSoundId, filteredList)
                imgui.same_line()

                if imgui.button("Play") then
                    gm.ChatManager.i:call("reqAddChatInfomation", "Playing Record Sound", config.SavedSoundId)
                end
            end

            if imgui.button("Print records for active quest") then
                PrintRecordsForActiveQuest()
            end

            -- imgui.spacing()

            -- if imgui.button("Delete record for active quest") then
            --     DeleteRecordForActiveQuest()
            -- end
        else
            imgui.text("Failing to initialize managers")
        end

        imgui.tree_pop()
    end
end)


re.on_config_save(function()
    SaveSettings()
end)


---------------------------------