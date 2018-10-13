AUTHORS_NOTE = [[Spawn program made by DeGariless]]

require("term").clear() local args = {...}



--######################
--## GLOBAL VARIABLES ##
--######################
print("Initializing Global Variables")

local TIMEZONEDB_API_KEY = "YOUR_TIMEZONEDB_API_KEY_GOES_HERE"
local VERSION = "1.1.1"
local PAGETIME = 12   --Default: 12
local TABWIDTH = 20   --Default: 20

--Resolution
local w = 87  --Default: 87
local h = 25  --Default: 25

if TIMEZONEDB == "YOUR_TIMEZONEDB_API_KEY_GOES_HERE" then 
  print("You needs a TimezoneDB API key")
  print("Press any key to continue...")
  event.pull("key_down")
  error()
end

--###############
--## LIBRARIES ##
--###############
print("Adding Custom Libraries")

local component = require("component")
local computer = require("computer")
local inet = require("internet")
local term = require("term")



--################
--## COMPONENTS ##
--################
print("Adding Components")

assert(component.isAvailable("debug"), "No debug card installed")
local db = component.debug
local fs = component.filesystem
local gpu = component.gpu



local file = io.open("/usr/lib/json4lua.lua", "r")
if file == nil then
  file = io.open("/usr/lib/json4lua.lua", "w")
  print("Downloading JSON4Lua library")
  local result, response = pcall(inet.request, "https://raw.githubusercontent.com/craigmj/json4lua/master/json/json.lua")
  assert(result, "Could not download JSON4Lua library")
  print("Success")
  for chunk in response do
    file:write(chunk)
  end
  file:close()
  print("file saved to /usr/lib/json4lua.lua")
end
file = nil
print("Loading JSON4Lua library")
local json = require("json4lua")


--################
--## LOAD FILES ##
--################
print("Loading Files.")

file = io.open("/Rules.txt", "r")
if file == nil then
  print("Rules.txt not found. Creating default file.")
  file = io.open("/Rules.txt", "w")
  file:write("Add server rules in Rules.txt")
  file:close()
  file = io.open("/Rules.txt", "r")
end
local rules = file:read("*all")
file:close()
file = nil

file = io.open("/PlayerData.json", "r")
if file == nil then
  print("PlayerData.json not found. Creating default file.")
  file = io.open("/PlayerData.json", "w")
  file:write('{"owner":[],"staff":[],"players":[]}')
  file:close()
  file = io.open("/PlayerData.json", "r")
end
local playerData = json.decode( file:read("*all") )
file:close()
file = nil

file = io.open("/Announcements.txt", "r")
if file == nil then
  print("Announcements.txt not found. Creating default file.")
  file = io.open("/Announcements.txt", "w")
  file:write("  There are no server announcements at this time.")
  file:close()
  file = io.open("/Announcements.txt", "r")
end
local announcements = file:read("*all")
file:close()
file = nil

file = io.open("/FAQ.txt", "r")
if file == nil then
  print("FAQ.txt not found. Creating default file.")
  file = io.open("/FAQ.txt", "w")
  file:write("  Q: How can I protect my base?\n  A: Edit this answer in /FAQ.txt")
  file:close()
  file = io.open("/FAQ.txt", "r")
end
local faq = file:read("*all")
file:close()
file = nil



--###########
--## THEME ##
--###########
print("Setting theme.")

local theme = {
  bgLow = 0x004422,
  bg = 0x006633,
  bgHigh = 0x669966,
  textLow = 0x999955,
  text = 0xCC9933,
  textHigh = 0xFFCC99,
  online = 0x44FF44,
  never = 0xFF8888,
  err = 0xFF0000  
}

--###############
--## FUNCTIONS ##
--###############
print("Setting functions.")


local function centerPrint(string, y)
  local start = math.floor( (w - string:len()) / 2 )
  term.setCursor(start, y)
  term.write(string)
end

local function title(string)
  gpu.setBackground(theme.bgHigh)
  gpu.setForeground(theme.textHigh)
  gpu.fill(1, 1, w, 4, " ")
  centerPrint(string, 2)
end

local function clear()
  gpu.setBackground(theme.bg)
  gpu.setForeground(theme.text)
  gpu.fill(1, 5, w, h-4, " ")
  term.setCursor(1, 6)
end

local function writeFile(fileName)
  local file = io.open(fileName, "r")
  local text = file:read("*all")
  file:close()
  term.write(text)  
end

local function time()  
  local req = nil
  local data = ""
  req = inet.request("http://api.timezonedb.com/v2.1/get-time-zone?key=" .. TIMEZONEDB_API_KEY .. "&format=json&by=zone&zone=America/Los_Angeles")
  for line in req do
    data = data .. line
  end
  return json.decode(data).timestamp
end


local function timeHuman(dif)
  --dif is in seconds
  if dif < 5 then
    return "a moment ago"
  elseif dif < 60 then
    return(dif .. " seconds ago")
  end
  dif = math.floor(dif/6+0.5)/10  -- convert dif to minutes
  if dif <= 1 then
    return "a minute ago"
  elseif dif < 60 then
    return(dif .. " minutes ago")
  end 
  dif = math.floor(dif/6+0.5)/10  -- convert dif to hours
  if dif == 1 then
    return "an hour ago"
  elseif dif < 24 then
    return(dif.." hours ago")
  end
  dif = math.floor(dif/24)  --dif is in days
  if dif == 1 then
    return "yesterday"
  elseif dif < 7 then
    return(dif.." days ago")
  elseif dif < 14 then
      return "last week"
  elseif dif < 30 then
    return(math.floor(dif/7).." weeks ago")
  elseif dif < 61 then
    return "last month"
  elseif dif < 365 then
    return(math.floor(dif/30.5).." months ago")
  end
  dif = math.floor(dif/36.5+0.5)/10  -- dif is in years
  if dif == 1 then
    return "last year"
  else
    return(dif.." years ago")
  end 
end

local function orderPlayerData()
  local orderedPlayers = {}

  for _, player in pairs(playerData.players) do
    local found = false
    for k, oPlayer in pairs(orderedPlayers) do
      if tonumber(player.lastseen) > tonumber(oPlayer.lastseen) then
        found = true
        table.insert(orderedPlayers, k, player)
        break
      end
    end
    if not found then
      table.insert(orderedPlayers,  #orderedPlayers+1, player)
    end
  end
  playerData.players = orderedPlayers
end


local function updatePlayerData(curTime)
  for _, onlinePlayer in ipairs(db.getPlayers()) do
    local found = false
    for _, v in pairs(playerData.owner) do
      if onlinePlayer == v.name then
        v.lastseen = curTime
        found = true
        break
      end 
    end
    if not found then
      for _, v in pairs(playerData.staff) do
        if onlinePlayer == v.name then
          v.lastseen = curTime
          found = true
          break
        end
      end
    end
    if not found then
      for _, v in pairs(playerData.players) do
        if onlinePlayer == v.name then
          v.lastseen = curTime
          found = true
          break
        end
      end
    end
    if not found then
      newPlayerData = {name = onlinePlayer, lastseen = curTime, firstseen = curTime}
      table.insert(playerData.players, newPlayerData)
    end
  end
  orderPlayerData()  
  local file = io.open("PlayerData.json", "w")
  file:write(json.encode(playerData))
  file:close()
end

local function lastseen(player, curTime)
  local status = db.getPlayer(player.name).getGameType()
  if status == "spectator" or status == nil then
    if player.lastseen == 0 then
      return "Never"
    end
    return timeHuman(curTime - player.lastseen)
  else
    return "Online"
  end
end


--
--TAB GENERATOR
--

local function tabs(...)
  term.setCursor(1, 4)
  local args = {...}
  local highTab = args[#args]
  gpu.setBackground(theme.bgHigh)
  gpu.setForeground(theme.textLow)
  for i=1, #args-1 do
    term.write(" ")
    if i == highTab then
      gpu.setForeground(theme.textHigh)
      gpu.setBackground(theme.bg)
      term.write(" ".. args[i] .." ")
      gpu.setForeground(theme.textLow)
      gpu.setBackground(theme.bgHigh)
    else
      gpu.setBackground(theme.bgLow)
      term.write(" "..args[i].." ")
      gpu.setBackground(theme.bgHigh)
    end
  end
  gpu.setBackground(theme.bg)
  gpu.setForeground(theme.text)
end



--
--PAGE GENERATORS
--

local function rulesPage()
  term.write(rules)
end


local function lastseenPage(curTime)
  print("  Owner "..string.rep("_", 93))
  gpu.setForeground(theme.textHigh)
  term.write("  Name"..string.rep(" ", TABWIDTH - 4).."Last seen\n")
  gpu.setForeground(theme.text)
  for k,v in ipairs(playerData.owner) do
    term.write("  "..v.name)
    term.write(string.rep(".", TABWIDTH - #v.name))
    local status = lastseen(v, curTime)
    if status == "Online" then
      gpu.setForeground(theme.online)
    elseif status == "Never" then
      gpu.setForeground(theme.never)
    end
    term.write(status)
    gpu.setForeground(theme.text)
    if k%2 == 0 then
      print()
    else
      term.write(string.rep(" ", TABWIDTH - #status - 2))
    end
  end
  term.write("\n\n")
  
  print("  Staff "..string.rep("_", 93))
  gpu.setForeground(theme.textHigh)
  term.write("  Name"..string.rep(" ", TABWIDTH - 4).."Last seen\n")
  gpu.setForeground(theme.text)
  for k,v in ipairs(playerData.staff) do
    term.write("  "..v.name)
    term.write(string.rep(".", TABWIDTH - #v.name))
    local status = lastseen(v, curTime)
    if status == "Online" then
      gpu.setForeground(theme.online)
    elseif status == "Never" then
      gpu.setForeground(theme.never)
    end
    term.write(status)
    gpu.setForeground(theme.text)
    if k%2 == 0 then
      print()
    else
      term.write(string.rep(" ", TABWIDTH - #status - 2))
    end
  end
  term.write("\n\n")

  print("  Players "..string.rep("_", 91))
  gpu.setForeground(theme.textHigh)
  term.write("  Name"..string.rep(" ", TABWIDTH-4).."Last seen\n")
  gpu.setForeground(theme.text)
  for k, v in ipairs(playerData.players) do
    term.write("  " .. v.name)
    term.write(string.rep(".", TABWIDTH - #v.name))
    local status = lastseen(v, curTime)
    if status == "Online" then
      gpu.setForeground(theme.online)
    elseif status == "Never" then
      gpu.setForeground(theme.never)
    end
    term.write(status)
    gpu.setForeground(theme.text)
    if k%2 == 0 then
      print()
    else
      term.write(string.rep(" ", TABWIDTH - #status - 2))
    end
    local _, y = term.getCursor()
    if y >= h then
      return
    end
  end
end

local function announcementsPage()
  term.write(announcements)
end

local function faqPage()
  term.write(faq)
end

--###################
--## MAIN FUNCTION ##
--###################
print("Starting Program")

local function main()
  gpu.setResolution(w, h)
  title("Welcome to the server!")
  while true do
    tabs("Rules","Players","Announcements","FAQ",1)
    clear()
    rulesPage()
    os.sleep(PAGETIME)
    local curTime = time()
    if curTime then
      updatePlayerData(curTime)
      tabs("Rules","Players","Announcements","FAQ",2)
      clear()
      lastseenPage(curTime)
      os.sleep(PAGETIME)
    end
    tabs("Rules","Players","Announcements","FAQ",3)
    clear()
    announcementsPage()
    os.sleep(PAGETIME)
    tabs("Rules","Players","Announcements","FAQ",4)
    clear()
    faqPage()
    os.sleep(PAGETIME)
  end
end



--##########
--## MAIN ##
--##########

local _, traceback, _ = xpcall(main, debug.traceback)



--#################
--## ERROR CATCH ##
--#################

gpu.setBackground(0x000000)
gpu.setForeground(0xFFFFFF)
gpu.fill(1, 1, w, h, " ")
term.setCursor(1, 1)
print()
print("  Oh noes! The spawn program has crashed D:")
print("  Please create an issue on github")
print("  http://github.com/DeGariless/OC-Server-Spawn/")
print("  make sure to include this error message...")
print("  -----------")
gpu.setForeground(theme.err)
print(traceback)
gpu.setForeground(0xFFFFFF)
print()
print("  Press any key to continue...")
event.pull("key_down")
