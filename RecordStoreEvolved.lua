----------- VARIABLES -----------

local version = 1.1

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
  ["0"]  = "GS",
  ["1"]  = "SA",
  ["2"]  = "LS",
  ["3"]  = "LBG",
  ["4"]  = "HBG",
  ["5"]  = "Hammer",
  ["6"]  = "GL",
  ["7"]  = "Lance",
  ["8"]  = "SnS",
  ["9"]  = "DB",
  ["10"] = "HH",
  ["11"] = "CB",
  ["12"] = "IG",
  ["13"] = "Bow"
}

local filteredList = {}
for k, v in pairs(sounds) do
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
gm.GuildCardManager = {}
gm.GuildCardManager.r = "snow.GuildCardManager"


----------- FUNCTIONS -----------

local function SaveSettings()
  if json.load_file("RecordStoreEvolved.json") ~= config then
    json.dump_file("RecordStoreEvolved.json", config)
  end
end

local function GetCurrentUTCTimestamp()
  ---@diagnostic disable-next-line: param-type-mismatch
  return os.time(os.date("!*t"))
end

local function TableHasElements(table)
  for _, __ in pairs(table) do
    return true
  end

  return false
end

local function GetTableLength(table)
  local length = 0
  for _, __ in pairs(table) do
    length = length + 1
  end

  return length
end

local function GetWeaponTypeId()
  local player = gm.PlayerManager.i:call("findMasterPlayer")
  local weaponTypeField = sdk.find_type_definition("snow.player.PlayerBase"):get_field("_playerWeaponType")

  return tostring(weaponTypeField:get_data(player))
end

local function GetGuildCardUniqueId()
  local guidType = sdk.find_type_definition("System.Guid");

  local guildCard = gm.GuildCardManager.i:get_field("_GuildCard")
  local playerGuildCard = guildCard:get_field("MyData")
  local guildCardId = playerGuildCard:get_field("GuildCardID")

  return tostring(guidType:get_method("ToString()"):call(guildCardId))
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
  return minutes .. "'" .. secondsFormatted
end

local function PrintRecordsForActiveQuest()
  if gm.QuestManager.i:call("isActiveQuest") then
    local guildCardId = GetGuildCardUniqueId()
    local questId = tostring(gm.QuestManager.i:call("get_ActiveQuestNo"))
    if config._Records[guildCardId][questId] then
      local anyRecordsForWeaponType = false
      local weaponId = GetWeaponTypeId()
      local message = "<COL YEL>" .. weapons[weaponId] .. "</COL> records for this quest: <COL YEL>(" .. questId .. ")</COL>"

      if config._Records[guildCardId][questId]["1"] and config._Records[guildCardId][questId]["1"][weaponId] then
        local lastIndex = GetTableLength(config._Records[guildCardId][questId]["1"][weaponId])
        local lastElement = config._Records[guildCardId][questId]["1"][weaponId][lastIndex]
        message = message .. "\nSolo Record: <COL YEL>" .. FormatRecordTimeString(lastElement.completionTime) .. "</COL>"
        if not anyRecordsForWeaponType then anyRecordsForWeaponType = true end
      end

      if config._Records[guildCardId][questId]["2"] and config._Records[guildCardId][questId]["2"][weaponId] then
        local lastIndex = GetTableLength(config._Records[guildCardId][questId]["2"][weaponId])
        local lastElement = config._Records[guildCardId][questId]["2"][weaponId][lastIndex]
        message = message .. "\n2-Man Record: <COL YEL>" .. FormatRecordTimeString(lastElement.completionTime) .. "</COL>"
        if not anyRecordsForWeaponType then anyRecordsForWeaponType = true end
      end

      if config._Records[guildCardId][questId]["3"] and config._Records[guildCardId][questId]["3"][weaponId] then
        local lastIndex = GetTableLength(config._Records[guildCardId][questId]["3"][weaponId])
        local lastElement = config._Records[guildCardId][questId]["3"][weaponId][lastIndex]
        message = message .. "\n3-Man Record: <COL YEL>" .. FormatRecordTimeString(lastElement.completionTime) .. "</COL>"
        if not anyRecordsForWeaponType then anyRecordsForWeaponType = true end
      end

      if config._Records[guildCardId][questId]["4"] and config._Records[guildCardId][questId]["4"][weaponId] then
        local lastIndex = GetTableLength(config._Records[guildCardId][questId]["4"][weaponId])
        local lastElement = config._Records[guildCardId][questId]["4"][weaponId][lastIndex]
        message = message .. "\n4-Man Record: <COL YEL>" .. FormatRecordTimeString(lastElement.completionTime) .. "</COL>"
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

-- TODO: handle removing records
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

  if oldRecord ~= -1 then
    recordString = recordString .. "\nOld Record: <COL YEL>" .. oldRecordString .. "</COL>"
  end

  return recordString
end

local function MapRecordsToNewFormat()
  local oldRecords = config._Records
  local guildCardId = GetGuildCardUniqueId()

  local newRecords = {}
  newRecords[guildCardId] = {}
  for questId, entries in pairs(oldRecords) do
    newRecords[guildCardId][questId] = {}

    for partySize, _ in pairs(entries) do
      newRecords[guildCardId][questId][partySize] = {}

      for weaponId, _ in pairs(entries[partySize]) do
        newRecords[guildCardId][questId][partySize][weaponId] = {}

        for _, recordData in pairs(entries[partySize][weaponId]) do
          local data = {
            completionTime = recordData.time,
            timestamp = recordData.epoch
          }
          table.insert(newRecords[guildCardId][questId][partySize][weaponId], data)
        end
      end
    end
  end

  return newRecords
end

local function UpdateConfigVersionAndRecords()
  if TableHasElements(config._Records) then
    local formattedRecords = MapRecordsToNewFormat()
    if formattedRecords ~= nil and TableHasElements(formattedRecords) then
      config.Version = version

      config._Records = {}
      config._Records = formattedRecords

      gm.ChatManager.i:call("reqAddChatInfomation", "Existing records mapped to\nversion <COL YEL>" .. config.Version .. "</COL>", 1 and 2289944406)

      SaveSettings()

      return
    end

    print("Unable to map old records to new format.")
    gm.ChatManager.i:call("reqAddChatInfomation", "Unable to map old records to new format.", 1 and 2289944406)
  end
end

local function ValidateManagers()
  if isManagersInitialized then
    return true
  end

  local success = true
  for _, v in pairs(gm) do
    v.i = sdk.get_managed_singleton(v.r)
    if not v.i then
      if success then success = false end
    end
  end

  isManagersInitialized = success

  return isManagersInitialized
end

local function ValidateRecords(guildCardId, questId, partySize, weaponType)
  if not config._Records[guildCardId] then
    config._Records[guildCardId] = {}
  end

  if not config._Records[guildCardId][questId] then
    config._Records[guildCardId][questId] = {}
  end

  if not config._Records[guildCardId][questId][partySize] then
    config._Records[guildCardId][questId][partySize] = {}
  end

  if not config._Records[guildCardId][questId][partySize][weaponType] then
    config._Records[guildCardId][questId][partySize][weaponType] = {}
  end

  for i = 1, GetTableLength(config._Records[guildCardId][questId][partySize][weaponType]) do
    if not config._Records[guildCardId][questId][partySize][weaponType][i] then
      config._Records[guildCardId][questId][partySize][weaponType][i] = {}
      config._Records[guildCardId][questId][partySize][weaponType][i]["completionTime"] = -1
      config._Records[guildCardId][questId][partySize][weaponType][i]["timestamp"] = -1
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
  local guildCardId = GetGuildCardUniqueId()
  local weaponTypeId = GetWeaponTypeId()
  local partySizeString = tostring(partySize)

  ValidateRecords(guildCardId, questId, partySizeString, weaponTypeId)

  local currentRecordIndex = GetTableLength(config._Records[guildCardId][questId][partySizeString][weaponTypeId])
  local currentRecord = config._Records[guildCardId][questId][partySizeString][weaponTypeId][currentRecordIndex]
  if currentRecord ~= nil and questTime >= currentRecord.completionTime then
    return
  end

  local nextRecordIndex = currentRecordIndex + 1
  config._Records[guildCardId][questId][partySizeString][weaponTypeId][nextRecordIndex] = {}
  config._Records[guildCardId][questId][partySizeString][weaponTypeId][nextRecordIndex]["completionTime"] = questTime
  config._Records[guildCardId][questId][partySizeString][weaponTypeId][nextRecordIndex]["timestamp"] = GetCurrentUTCTimestamp()

  SaveSettings()

  local message = FormatRecordString(questTime, currentRecord and currentRecord.completionTime or -1, partySize, weapons[weaponTypeId])
  gm.ChatManager.i:call("reqAddChatInfomation", message, config.RecordSoundEnabled and config.SavedSoundId or 0)
end


----------- HOOKS -----------

sdk.hook(sdk.find_type_definition("snow.QuestManager"):get_method("setQuestClear"), nil, QuestClear)


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

      -- TODO: handle removing records
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