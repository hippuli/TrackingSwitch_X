TrackingSwitch_X = LibStub("AceAddon-3.0"):NewAddon("TrackingSwitch_X", "AceConsole-3.0")

local defaults = {
  profile = {
    enableOnLogin = false,
    disableStationary = true,
    disableResting = true,
    disableCombat = true,
    timeInterval = 2,
    useCustomTracking = false,
    trackingOption1 = "Find Minerals",
    trackingOption2 = "Find Herbs",
    trackingOption3 = nil,
  },
}

TrackingSwitch_X.currentTrackingIndex = TrackingSwitch_X.currentTrackingIndex or 1
TrackingSwitch_X.trackingList = {}




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

    spacer1 = {  -- line break
      name = " ", 
      type = "description",
      order = 3,
    },
    disableStationary = {
      name = "Disable tracking switch while stationary.",
      desc = "Check to disable switching while stationary.",
      type = "toggle",
      get = function() return TrackingSwitch_X.db.profile.disableStationary end,
      set = function(_, value)
        TrackingSwitch_X.db.profile.disableStationary = value
        TrackingSwitch_X:UpdateTimerInterval()
      end,
      width = "full",
    },
    disableResting = {
      name = "Disable tracking switch while in a town/inn.",
      desc = "Check to disable switching while in a town/inn.",
      type = "toggle",
      get = function() return TrackingSwitch_X.db.profile.disableResting end,
      set = function(_, value)
        TrackingSwitch_X.db.profile.disableResting = value
        TrackingSwitch_X:UpdateTimerInterval()
      end,
      width = "full",
    },
    disableCombat = {
      name = "Disable tracking switch while in combat.",
      desc = "Check to disable switching while in combat.",
      type = "toggle",
      get = function() return TrackingSwitch_X.db.profile.disableCombat end,
      set = function(_, value)
        TrackingSwitch_X.db.profile.disableCombat = value
        TrackingSwitch_X:UpdateTimerInterval()
      end,
      width = "full",
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
        TrackingSwitch_X:UpdateTimerInterval()
      end,
      width = "full",
    },
    trackingOption1 = {
      name = "Tracking Option 1",
      desc = "Select the first tracking",
      type = "select",
      values = {
        [""] = "None",  
        ["Find Minerals"] = "Find Minerals",
        ["Find Herbs"] = "Find Herbs",
        ["Find Treasure"] = "Find Treasure",
        ["Find Fish"] = "Find Fish",
      },
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
      values = {
        [""] = "None",  
        ["Find Minerals"] = "Find Minerals",
        ["Find Herbs"] = "Find Herbs",
        ["Find Treasure"] = "Find Treasure",
        ["Find Fish"] = "Find Fish",
      },
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
      values = {
        [""] = "None",  
        ["Find Minerals"] = "Find Minerals",
        ["Find Herbs"] = "Find Herbs",
        ["Find Treasure"] = "Find Treasure",
        ["Find Fish"] = "Find Fish",
      },
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


  print("Type /ts to toggle or /tso, /tsx for options")
  LibStub("AceConfig-3.0"):RegisterOptionsTable("TrackingSwitch_X", options)

  self.optionsFrame = LibStub('AceConfigDialog-3.0'):AddToBlizOptions('TrackingSwitch_X', 'TrackingSwitch_X')
  self.IS_RUNNING = false
  self:RegisterChatCommand("rl", function() ReloadUI() end) -- Reloads on /rl command
  self:RegisterChatCommand("ts", "ToggleTracking")   
  self:RegisterChatCommand("tso", "OpenConfigMenu")
  self:RegisterChatCommand("tsx", "OpenConfigMenu")
  
  if self.db.profile.enableOnLogin then
    self:RebuildTrackingList()  -- build the custom tracking list first
    self:ToggleTracking()
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
       (not self.db.profile.disableCombat or not UnitAffectingCombat("player")) then

        local function castSpell(spellName)
            if self.db.profile.muteSwitchSound then
                -- temporarily mute
                local oldVolume = GetCVar("Sound_EnableSFX")
                SetCVar("Sound_EnableSFX", 0)
                CastSpellByName(spellName)
                SetCVar("Sound_EnableSFX", oldVolume)
            else
                CastSpellByName(spellName)
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


