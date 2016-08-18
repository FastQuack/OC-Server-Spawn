--[[
Spawn program made by DeGariless
]]--

require("term").clear()
print("Initializing Spawn Program")

print("Adding Custom Libraries")
local component = require("component")
local computer = require("computer")
local inet = require("internet")
local term = require("term")

print("Adding Components")
local fs = component.filesystem
local gpu = component.gpu
if not component.isAvailable("onlinedetector") then
  error("Could not find an Online Detector attached to the computer")
end
local od = component.onlinedetector

local file = io.open("/lib/json.lua", "r")
if file == nil then
  file = io.open("/lib/json.lua", "w")
  print("Downloading JSON library")
  local result, response = pcall(inet.request, "http://regex.info/code/JSON.lua")
  if result then
    print("Success")
    for chunk in response do
      file:write(chunk)
    end
  end
  file:close()
  print("file saved to /lib/json.lua")
end
file = nil

print("Loading JSON library")
local JSON = loadfile("/lib/json.lua")()
print("\n " .. JSON.AUTHOR_NOTE .. [[

 - Simple JSON encoding and decoding in pure Lua.
 -
 - Copyright 2010-2016 Jeffery Friedl
 - http://regex.info/blog
 - Latest version: regex.info.blog.lua.json
 -
 - This code is released under a Creative Commons CC-BY "Attribution" License:
 - http://creativecommons.org/licenses/by/3.0/deed.en_US
]])
os.sleep(5)

--######################
--## GLOBAL VARIABLES ##
--######################
print("Setting global variables.")

VERSION = "1.1.0"
local args = {...}

local PAGETIME = 15  -- Default is 15
local TABWIDTH = 20

--Resolution
local w = 87 -- Default: 87
local h = 25 -- Default: 25



--################
--## LOAD FILES ##
--################
print("Loading Files.")

file = io.open("Rules.txt", "r")
if file == nil then
  print("Rules.txt not found. Creating default file.")
  file = io.open("Rules.txt", "w")
  file:write("Add server rules in Rules.txt")
  file:close()
  file = io.open("Rules.txt", "r")
end
local rules = file:read("*all")
file:close()
file = nil

file = io.open("PlayerData.json", "r")
if file == nil then
  print("PlayerData.json not found. Creating default file.")
  file = io.open("PlayerData.json", "w")
  file:write('{"owner":[],"staff":[],"players":[]}')
  file:close()
  file = io.open("PlayerData.json", "r")
end
local playerData = JSON:decode( file:read("*all") )
file:close()
file = nil

file = io.open("Announcements.txt", "r")
if file == nil then
  print("Announcements.txt not found. Creating default file.")
  file = io.open("Announcements.txt", "w")
  file:write("  There are no server announcementes at this time.")
  file:close()
  file = io.open("Announcements.txt", "r")
end
local announcements = file:read("*all")
file:close()
file = nil

file = io.open("FAQ.txt", "r")
if file == nil then
  print("FAQ.txt not found. Creating default file.")
  file = io.open("FAQ.txt", "w")
  file:write("  Q: I can haz free diamonds?\n  A: Nope")
  file:close()
  file = io.open("FAQ.txt", "r")
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
  local data = nil
  req = inet.request("http://www.timeapi.org/utc/now?format=%25Y%25j%25H%25M")
  if not pcall(function () data = req() end) then
    req:close()
    return nil
  end
  if #data ~= 11 then
    return nil
  end
  return data
end


local function timeDif(pTime, curTime)
  pTime = tostring(pTime)
  local cYear = curTime:sub(1,4)
  local cDay = curTime:sub(5,7)
  local cHour = curTime:sub(8,9)
  local cMin = curTime:sub(10,11)
  local pYear = pTime:sub(1,4)
  local pDay = pTime:sub(5,7)
  local pHour = pTime:sub(8,9)
  local pMin = pTime:sub(10,11)
  local dYear = cYear - pYear
  local dDay = cDay - pDay
  local dHour = cHour - pHour
  local dMin = cMin - pMin
  local dif = math.floor(((dYear * 365 + dDay) * 24 + dHour) * 60 + dMin)  --dif is in minutes
  if dif < 2 then
    return "a moment ago"
  elseif dif < 60 then
    return(dif.." minutes ago")
  end
  dif = math.floor(dif/6+0.5)/10  --dif is in hours
  if dif == 1 then
    return "1 hour ago"
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
  for _, onlinePlayer in ipairs(od.getPlayerList()) do
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
  file:write(JSON:encode_pretty(playerData))
  file:close()
end

local function lastseen(player, curTime)
  if od.isPlayerOnline(player.name) then
    return "Online"
  else
    return timeDif(player.lastseen, curTime)
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
  print("  Owner\n  "..string.rep("-", 60))
  gpu.setForeground(theme.textHigh)
  term.write("  Name"..string.rep(" ", TABWIDTH - 4).."Last seen\n")
  gpu.setForeground(theme.text)
  for k,v in ipairs(playerData.owner) do
    term.write("  "..v.name)
    term.write(string.rep(".", TABWIDTH - #v.name))
    local status = lastseen(v, curTime)
    if status == "Online" then
      gpu.setForeground(theme.online)
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
  print("  Players\n  "..string.rep("-", 60))
  gpu.setForeground(theme.textHigh)
  term.write("  Name"..string.rep(" ", TABWIDTH-4).."Last seen\n")
  gpu.setForeground(theme.text)
  for k, v in ipairs(playerData.players) do
    term.write("  " .. v.name)
    term.write(string.rep(".", TABWIDTH - #v.name))
    local status = lastseen(v, curTime)
    if status == "Online" then
      gpu.setForeground(theme.online)
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
print("Starting Program in 5 seconds!")

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

local err = nil
while err == "too long without yeilding" or err == nil do
  pcall(function () os.sleep(5) end)
  _, err = pcall(main)
end


--#################
--## ERROR CATCH ##
--#################

gpu.setBackground(0x001100)
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
print("  " .. err)
gpu.setForeground(0xFFFFFF)
print()
while true do os.sleep(60) end