TrackingSwitch_X = LibStub("AceAddon-3.0"):NewAddon("TrackingSwitch_X", "AceConsole-3.0", "AceEvent-3.0")

local defaults = {
  profile = {
    lastNoticeVersion = 0,
    enableOnLogin = false,
    muteSwitchSound = false,
    disableWhileTargetActive = false,
    disableWhileCursorActive = true,
    disableStationary = true,
    disableResting = true,
    disableCombat = true,
    disableWhileUnmounted = false,
    disableNotTravelForm = "Option Disabled",
    timeInterval = 2,
    useCustomTracking = false,
    useCreatureTracking = false,
    trackingOption1 = "Find Minerals",
    trackingOption2 = "Find Herbs",
    trackingOption3 = nil,
    runOnceFixFlag = true,
    filterTracking = false,
    filterTrackingOffset = 0.15,
  },
}

TrackingSwitch_X.currentTrackingIndex = TrackingSwitch_X.currentTrackingIndex or 1
TrackingSwitch_X.trackingList = {}

-- local isClassic = WOW_PROJECT_ID == (WOW_PROJECT_CLASSIC or 2)
local isBCC = WOW_PROJECT_ID == (WOW_PROJECT_BURNING_CRUSADE_CLASSIC or 5)
-- local isFiveEver = f


local options = {
  name = "TrackingSwitch_X",
  handler = TrackingSwitch_X,
  type = "group",
  args = {
    enableOnLogin = {
      name = "Enable on login",
      desc = "Check to enable tracking switch on login.",
      type = "toggle",
      get = function() return TrackingSwitch_X.db.profile.enableOnLogin end,
      set = function(_, value)
        TrackingSwitch_X.db.profile.enableOnLogin = value
        TrackingSwitch_X:UpdateTimerInterval()
      end,
      width = "full",
      order = 1
    },
    muteSwitchSound = {
      name = "Mute switch sound",
      desc = "Check to mute the switch sound.",
      type = "toggle",
      get = function() return TrackingSwitch_X.db.profile.muteSwitchSound end,
      set = function(_, value)
        TrackingSwitch_X.db.profile.muteSwitchSound = value
        TrackingSwitch_X:UpdateTimerInterval()
      end,
      width = "full",
      order = 2,
    },
    filterTracking = {
      name = "Hide floating combat text",
      desc = "Hide floating combat text",
      type = "toggle",
      get = function() return TrackingSwitch_X.db.profile.filterTracking end,
      set = function(_, value)
        TrackingSwitch_X.db.profile.filterTracking = value
      end,
      width = "full",
      order = 3,
    },
    filterTrackingOffset =  { 
      name = "Increae to hide floating text",
      desc = "Adds time to hide combat text if still visible.",
      type = "range",
      min = 0.15,
      max = 1,
      step = 0.05,
      get = function() return TrackingSwitch_X.db.profile.filterTrackingOffset end,
      set = function(_, value)
        TrackingSwitch_X.db.profile.filterTrackingOffset = value
      end,
      hidden = function()
        return not TrackingSwitch_X.db.profile.filterTracking
      end,
      width = "full",   
      order = 3.1,
    },
    spacer1 = {  -- line break
      name = " ", 
      type = "description",
      fontSize = "medium",
      order = 4,
    },
    DescriptionDisableOtions = {  -- line break
      name = "|cff00ffffDisable Automatic Switching while:|r", 
      type = "description",
      fontSize = "medium",
      order = 5,
    },
    spacer2 = {  -- line break
      name = "", 
      type = "description",
      fontSize = "medium",
      order = 6,
    },
    disableWhileTargetActive = {
      name = "(Attackable) target active.",
      desc = "Check to disable switching while (attackable) target is active.",
      type = "toggle",
      get = function() return TrackingSwitch_X.db.profile.disableWhileTargetActive end,
      set = function(_, value)
        TrackingSwitch_X.db.profile.disableWhileTargetActive = value
        TrackingSwitch_X:UpdateTimerInterval()
      end,
      order = 7 ,
      width = "Half",
    },
    disableWhileCursorActive = {
      name = "Dragging spell/item.",
      desc = "Check to disable switching while dragging a spell or item.",
      type = "toggle",
      get = function() return TrackingSwitch_X.db.profile.disableWhileCursorActive end,
      set = function(_, value)
        TrackingSwitch_X.db.profile.disableWhileCursorActive = value
        TrackingSwitch_X:UpdateTimerInterval()
      end,
      order = 8,
      width = "Half",
    },
    disableStationary = {
      name = "Player is stationary.",
      desc = "Check to disable switching while stationary.",
      type = "toggle",
      get = function() return TrackingSwitch_X.db.profile.disableStationary end,
      set = function(_, value)
        TrackingSwitch_X.db.profile.disableStationary = value
        TrackingSwitch_X:UpdateTimerInterval()
      end,
      order = 9,
      width = "Full",
    },
    disableResting = {
      name = "In a town/inn.",
      desc = "Check to disable switching while in a town/inn.",
      type = "toggle",
      get = function() return TrackingSwitch_X.db.profile.disableResting end,
      set = function(_, value)
        TrackingSwitch_X.db.profile.disableResting = value
        TrackingSwitch_X:UpdateTimerInterval()
      end,
      order = 10,
      width = "Full",
    },
    disableCombat = {
      name = "In combat.",
      desc = "Check to disable switching while in combat.",
      type = "toggle",
      get = function() return TrackingSwitch_X.db.profile.disableCombat end,
      set = function(_, value)
        TrackingSwitch_X.db.profile.disableCombat = value
        TrackingSwitch_X:UpdateTimerInterval()
      end,
      order = 11,
      width = "Full",
    },
    disableWhileUnmounted = {
      name = "Player is unmounted.",
      desc = "Check to disable switching while unmounted.",
      type = "toggle",
      get = function() return TrackingSwitch_X.db.profile.disableWhileUnmounted end,
      set = function(_, value)
        TrackingSwitch_X.db.profile.disableWhileUnmounted = value
        TrackingSwitch_X:UpdateTimerInterval()
      end,
      order = 12,
      width = "Full",
    },
    disableNotTravelForm = {
      name = "Not in travel forms.",
      desc = "Check to disable switching while not in travel forms.",
      type = "select",
      values = {
        ["Option Disabled"] = "Option Disabled",
        ["Ground Form"] = "Ground Form",
        ["Flight Form"] = "Flight Form",
        ["Both Forms"] = "Both Forms",

      },
      get = function() return TrackingSwitch_X.db.profile.disableNotTravelForm end,
      set = function(_, value)
        TrackingSwitch_X.db.profile.disableNotTravelForm = value
        TrackingSwitch_X:UpdateTimerInterval()
      end,
      order = 13,
      width = "Full",
      hidden = function() return TrackingSwitch_X.playerClass ~= "DRUID" and TrackingSwitch_X.playerClass ~= "SHAMAN" end,
    },
    timeInterval = {
      name = "Time interval",
      desc = "Seconds before switch.",
      type = "range",
      min = 2,
      max = 20,
      step = 1,
      get = function() return TrackingSwitch_X.db.profile.timeInterval end,
      set = function(_, value)
        TrackingSwitch_X.db.profile.timeInterval = value
        TrackingSwitch_X:UpdateTimerInterval()
      end,
      width = "full",
    },
    useCustomTracking = {
      name = "Use custom tracking?",
      desc = "Enable custom tracking rotation instead of the default HERB/ORE behavior.",
      type = "toggle",
      get = function() return TrackingSwitch_X.db.profile.useCustomTracking end,
      set = function(_, value)
        TrackingSwitch_X.db.profile.useCustomTracking = value
        TrackingSwitch_X:RebuildTrackingList()
        TrackingSwitch_X:UpdateTimerInterval()
      end,
      width = "full",
    },
    useCreatureTracking = {
      name = "Use creature tracking?",
      desc = "Enable creature tracking options.",
      type = "toggle",
      get = function() return TrackingSwitch_X.db.profile.useCreatureTracking end,
      set = function(_, value)
        TrackingSwitch_X.db.profile.useCreatureTracking = value
        TrackingSwitch_X:RebuildTrackingList()
        TrackingSwitch_X:UpdateTimerInterval()
      end,
      hidden = function()
        return not TrackingSwitch_X.db.profile.useCustomTracking
      end,
      width = "full",
    },
    trackingOption1 = {
      name = "Tracking Option 1",
      desc = "Select the first tracking",
      type = "select",
      values = function() return TrackingSwitch_X:GetTrackingOptionValues() end,
      get = function() return TrackingSwitch_X.db.profile.trackingOption1 end,
      set = function(_, value)
        TrackingSwitch_X.db.profile.trackingOption1 = value
        TrackingSwitch_X:RebuildTrackingList()
        TrackingSwitch_X:UpdateTimerInterval()
      end,
      hidden = function()
        return not TrackingSwitch_X.db.profile.useCustomTracking
      end,
      width = 0.75,
    },
    trackingOption2 = {
      name = "Tracking Option 2",
      desc = "Select the second tracking option",
      type = "select",
      values = function() return TrackingSwitch_X:GetTrackingOptionValues() end,
      get = function() return TrackingSwitch_X.db.profile.trackingOption2 end,
      set = function(_, value)
        TrackingSwitch_X.db.profile.trackingOption2 = value
        TrackingSwitch_X:RebuildTrackingList()
        TrackingSwitch_X:UpdateTimerInterval()
      end,
      hidden = function()
        return not TrackingSwitch_X.db.profile.useCustomTracking
      end,
      width = 0.75,
    },
    trackingOption3 = {
      name = "Tracking Option 3",
      desc = "Select the third tracking option",
      type = "select",
      values = function() return TrackingSwitch_X:GetTrackingOptionValues() end,
      get = function() return TrackingSwitch_X.db.profile.trackingOption3 end,
      set = function(_, value)
        TrackingSwitch_X.db.profile.trackingOption3 = value
        TrackingSwitch_X:RebuildTrackingList()
        TrackingSwitch_X:UpdateTimerInterval()
      end,
      hidden = function()
        return not TrackingSwitch_X.db.profile.useCustomTracking
      end,
      width = 0.75,
    },

  },
}


local AceGUI = LibStub("AceGUI-3.0")

-- Map spell names to spell IDs for language-independent casting
local spellNameToID = {
  ["Find Minerals"] = 2580,
  ["Find Herbs"] = 2383,
  ["Find Treasure"] = 2481,
  ["Find Fish"] = 43308,

  ["Track Humanoids"] = 19883,
  ["Track Beasts"] = 1494,
  ["Track Undead"] = 19884,
  ["Track Hidden"] = 19885,
  ["Track Elementals"] = 19880,
  ["Track Demons"] = 19878,
  ["Track Giants"] = 19882,
  ["Track Dragonkin"] = 19879,
}



function TrackingSwitch_X:RebuildTrackingList()
  wipe(self.trackingList)

  local options = {
    self.db.profile.trackingOption1,
    self.db.profile.trackingOption2,
    self.db.profile.trackingOption3,
  }

  for _, spell in ipairs(options) do
    if spell and spell ~= "" then
      table.insert(self.trackingList, spell)
    end
  end

  self.currentTrackingIndex = 1
end

function TrackingSwitch_X:OnInitialize()

  self.db = LibStub("AceDB-3.0"):New("TrackingSwitch_XDB", defaults, true)
  if self.db.profile.disableNotTravelForm == false then
    self.db.profile.disableNotTravelForm = "Option Disabled" --Temporary fix for old DB entries.
  end

  self:RebuildTrackingList()


  print("Type /ts to toggle or /tso, /tsx for options")
  if self.db.profile.lastNoticeVersion < 1 then
    C_Timer.After(5, function()
      DEFAULT_CHAT_FRAME:AddMessage("|CFF00FFFFNew options added!|r")
      DEFAULT_CHAT_FRAME:AddMessage("|CFF00FFFFDisable tracking while target active or while moving items. Also mute switch sound.|r")
      DEFAULT_CHAT_FRAME:AddMessage("|CFF00FFFF/tsx for options!|r")
      self.db.profile.lastNoticeVersion = 1
    end)
  end
  LibStub("AceConfig-3.0"):RegisterOptionsTable("TrackingSwitch_X", options)

  self.optionsFrame = LibStub('AceConfigDialog-3.0'):AddToBlizOptions('TrackingSwitch_X', 'TrackingSwitch_X')
  self.IS_RUNNING = false
  self:RegisterChatCommand("rl", function() ReloadUI() end) -- Reloads on /rl command
  self:RegisterChatCommand("ts", "ToggleTracking")   
  self:RegisterChatCommand("tso", "OpenConfigMenu")
  self:RegisterChatCommand("tsx", "OpenConfigMenu")

  
  -- self:RegisterEvent("UPDATE_SHAPESHIFT_FORM")
  
  if self.db.profile.enableOnLogin then
    self:RebuildTrackingList()  -- build the custom tracking list first (should already run on init)
    self:ToggleTracking()
  end

  self.playerClass = select(2, UnitClass("player"))  --all CAPS class name
  ---temp? Fix to prevent option stuck on when switching characters. Can probably change to workaround to save option settings later instead of per-char db.
  if self.playerClass ~= "DRUID" and self.playerClass ~= "SHAMAN" then
    self.db.profile.disableNotTravelForm = "Option Disabled"
  end
end

function TrackingSwitch_X:OpenConfigMenu()
  LibStub("AceConfigDialog-3.0"):Open("TrackingSwitch_X")
end

function TrackingSwitch_X:UpdateTimerInterval()

  -- Stop the existing timer if it is running
  if self.trackingTimer then
    self.trackingTimer:Cancel()
  end
  -- Start a new timer if tracking is enabled
  if self.IS_RUNNING then
    self.trackingTimer = C_Timer.NewTicker(TrackingSwitch_X.db.profile.timeInterval,
      function() TrackingSwitch_X:SwitchTracking() end)
    -- print("TrackingSwitch_X is now running with an interval of " ..
      -- TrackingSwitch_X.db.profile.timeInterval .. " seconds.")
  end
end

function TrackingSwitch_X:ToggleTracking()
  self.IS_RUNNING = not self.IS_RUNNING
  if self.IS_RUNNING then
    self.trackingTimer = C_Timer.NewTicker(TrackingSwitch_X.db.profile.timeInterval,
      function() TrackingSwitch_X:SwitchTracking() end)
      -- print("TrackingSwitch_X is now running with an interval of " ..
      -- TrackingSwitch_X.db.profile.timeInterval .. " seconds.")
  else
    self.trackingTimer:Cancel()
    print("TrackingSwitch_X is now stopped.")
  end
end

function TrackingSwitch_X:SwitchTracking()
    -- Check conditions
    if (not self.db.profile.disableStationary or IsPlayerMoving()) and
       (not self.db.profile.disableResting or not IsResting()) and
       (not self.db.profile.disableCombat or not UnitAffectingCombat("player")) and
       (not self.db.profile.disableWhileTargetActive or not UnitCanAttack("player", "target")) and
       (not self.db.profile.disableWhileCursorActive or not GetCursorInfo()) and
       (not self.db.profile.disableWhileUnmounted or IsMounted())  and
       not UnitChannelInfo("player") and
       self:IsInAllowedTravelForm()    
       then

        local function castSpell(spellName)
            local spellID = spellNameToID[spellName]
            if not spellID then
                print("Unknown spell: " .. spellName)
                return
            end            
    
            local oldFloatingCombatText = GetCVar("enableFloatingCombatText")
            local oldVolume = GetCVar("Sound_EnableSFX")
            if self.db.profile.muteSwitchSound then
                SetCVar("Sound_EnableSFX", 0) -- Mute sound effects
            end
            if self.db.profile.filterTracking then
                SetCVar("enableFloatingCombatText", 0)  -- Disable floating combat text
            end                

            CastSpellByID(spellID)

            if self.db.profile.muteSwitchSound then
                SetCVar("Sound_EnableSFX", oldVolume)
            end
            if self.db.profile.filterTracking then
                C_Timer.After(self.db.profile.filterTrackingOffset, function()
                    SetCVar("enableFloatingCombatText", oldFloatingCombatText)
                end)
            end
          end

        if self.db.profile.useCustomTracking then
            if #self.trackingList == 0 then return end 

            local spellName = self.trackingList[self.currentTrackingIndex]
            if spellName ~= "" then
                castSpell(spellName)
            end

            -- advance index
            self.currentTrackingIndex = self.currentTrackingIndex + 1
            if self.currentTrackingIndex > #self.trackingList then
                self.currentTrackingIndex = 1
            end

        else
            -- default HERB/ORE fallback
            if self.currentTracking == "minerals" then
                castSpell("Find Herbs")
                self.currentTracking = "herbs"
            else
                castSpell("Find Minerals")
                self.currentTracking = "minerals"
            end
        end
    end
end

     
                -- temporarily mute

function TrackingSwitch_X:IsInAllowedTravelForm()
    local setting = self.db.profile.disableNotTravelForm
    if setting == "Option Disabled" or not setting then
        return true
    end

    local form = GetShapeshiftForm()

    if self.playerClass == "DRUID" then
        local isGround = (form == 4)   -- Ground
        local isFlight = (form == 5)   -- Flight
        if setting == "Ground Form" then
            return isGround
        elseif setting == "Flight Form" then
            return isFlight
        elseif setting == "Both Forms" then
            return isGround or isFlight
        end

    elseif self.playerClass == "SHAMAN" then
        local isGhostWolf = (form == 1) 
          if setting == "Ground Form" or setting == "Both Forms" then
              return isGhostWolf
          elseif setting == "Flight Form" then -- Might be pointless, may remove.
              return false 
          end
    end
end


function TrackingSwitch_X:GetTrackingOptionValues()  
    
    local values = {
        [""] = "None",  
        ["Find Minerals"] = "Find Minerals",
        ["Find Herbs"] = "Find Herbs",
        ["Find Treasure"] = "Find Treasure",
        ["Find Fish"] = "Find Fish",
    }

    if not isBCC then --change if forever adds fishing tracking book.
      values["Find Fish"] = nil      
    end

    -- if isFiveEver then
    --     values["Find Treasure"] = nil
    -- end


    if self.db and self.db.profile.useCreatureTracking then
        values["Track Humanoids"] = "Track Humanoids"
        values["Track Beasts"] = "Track Beasts"
        values["Track Undead"] = "Track Undead"
        values["Track Demons"] = "Track Demons"
        values["Track Elementals"] = "Track Elementals"
        values["Track Giants"] = "Track Giants"
        values["Track Dragonkin"] = "Track Dragonkin"
        values["Track Hidden"] = "Track Hidden"
    end



    return values
end