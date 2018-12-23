---------------------------------------------------
-- SETUP
---------------------------------------------------
local _, ns			= ... -- namespace
local shortcut		= "/scrap"
local addonVersion	= GetAddOnMetadata("ScrapButton", "Version")
local welcomeMSG	= string.format("|c%sScrapButton|r loaded v%s.", ns.Config.color, addonVersion)
local defaultDB = {
	DBversion = 5,
	Debug = false,
	specificilvlbox = " ",
	CheckButtons = {
		Itemlvl = false,
		Bottom = false,
		Itemprint = false,
		boe = false,
		specificilvl = false,
		equipmentsets = false,
		azerite = false,
		Bag = {
			[0] = false,
			[1] = false,
			[2] = false,
			[3] = false,
			[4] = false,
		},
	}
}

function DebugPrint(text)
	if (ScrappinDB.Debug) then
		print(string.format("|c%sScrapDebug|r: %s", ns.Config.color, tostring(text)))
	end
end

---------------------------------------------------
-- DATABASE FUNCTIONS
---------------------------------------------------
local function CheckDatabaseKeysNil(database, default)
	for key, value in pairs(default) do
		if database[key] == nil then
			database[key] = value
		elseif (type(database[key]) == "table") then
			CheckDatabaseKeysNil(database[key], default[key])
		end
	end
end

---------------------------------------------------
-- SLASH COMMANDS
---------------------------------------------------
local commands = {
	["scrap"] = function()
		ns.Config.ToggleScrappinFrame()
	end,

	["reset"] = function()
		ScrappinDB = defaultDB
		print(string.format("|c%sScrapButton|r database has been reset.", ns.Config.color))
		ns.Config.UpdateCheckButtonStates()
	end,

	["debug"] = function()
		ScrappinDB.Debug = not ScrappinDB.Debug
		DebugPrint(" is now " .. tostring(ScrappinDB.Debug))
	end,
}

local function HandleSlashCommands(str)
	if (#str == 0) then -- player entered /scrap
		commands.scrap()
	end
	-- figure out what the player wrote
	-- insert each word into a table and remove any spaces
	local args = {}
	local path = commands

	for _, arg in ipairs({ string.split(' ', str) }) do
		if (#arg > 0) then
			table.insert(args, arg) -- args is now a table with each word
		end
	end

	-- iterate through commands until we find the correct one
	for id, arg in ipairs(args) do
		if (#arg > 0) then
			arg = arg:lower() -- make the command into lowercase
			if (path[arg]) then
				if (type(path[arg]) == "function") then
					-- if we reached a function in command,
					path[arg]()
					--[[ save this if we want any extra arguments to be passed,
						 example: /scrapper [thing] [on] (will pass "thing" + "on")
						 path[arg](select(id + 1, unpack(args))) --]]
					return
				elseif (type(path[arg]) == "table") then
					path = path[arg] -- enter found subtable
				end
			else
				commands.scrap()
				return
			end
		end
	end
end

---------------------------------------------------
-- INIT
---------------------------------------------------
function ns:Init(event, name)
	if (name ~= "ScrapButton") then return end

	SLASH_ScrapButton1 = shortcut
	SLASH_ScrapButton2 = "/scrapbutton"
	SlashCmdList.ScrapButton = HandleSlashCommands

	CheckDatabaseKeysNil(ScrappinDB, defaultDB)
	ns.Config.UpdateCheckButtonStates()

	ns.Core.CreateScrapButton()

	print(welcomeMSG)
	print(string.format("%s to open config.", shortcut))
end

local addonloadedFrame = CreateFrame("Frame")
addonloadedFrame:RegisterEvent("ADDON_LOADED")
addonloadedFrame:SetScript("OnEvent", ns.Init)