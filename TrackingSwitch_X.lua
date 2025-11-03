TrackingSwitch_X = LibStub("AceAddon-3.0"):NewAddon("TrackingSwitch_X", "AceConsole-3.0")

local defaults = {
  profile = {
    disableStationary = true,
    disableResting = true,
    disableCombat = true,
    timeInterval = 2,
  },
}

local options = {
  name = "TrackingSwitch_X",
  handler = TrackingSwitch_X,
  type = "group",
  args = {
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
    -- trackingOption1 = {
    --   name = "Tracking Option 1",
    --   desc = "Select the first tracking option PlaceHolder",
    --   type = "select",
    --   values = {
    --     ["Find Minerals"] = "Find Minerals",
    --     ["Find Herbs"] = "Find Herbs",
    --     -- Add more options as needed
    --   },
    --   get = function() return TrackingSwitch_X.db.profile.trackingOption1 end,
    --   set = function(_, value)
    --     TrackingSwitch_X.db.profile.trackingOption1 = value
    --     TrackingSwitch_X:UpdateTimerInterval()
    --   end,
    --   width = "half",
    -- },
    -- trackingOption2 = {
    --   name = "Tracking Option 2",
    --   desc = "Select the second tracking option PlaceHolder",
    --   type = "select",
    --   values = {
    --     ["Find Minerals"] = "Find Minerals",
    --     ["Find Herbs"] = "Find Herbs",
    --     -- Add more options as needed
    --   },
    --   get = function() return TrackingSwitch_X.db.profile.trackingOption2 end,
    --   set = function(_, value)
    --     TrackingSwitch_X.db.profile.trackingOption2 = value
    --     TrackingSwitch_X:UpdateTimerInterval()
    --   end,
    --   width = "half",
    -- },
    -- trackingOption3 = {
    --   name = "Tracking Option 3",
    --   desc = "Select the third tracking option PlaceHolder",
    --   type = "select",
    --   values = {
    --     ["Find Minerals"] = "Find Minerals",
    --     ["Find Herbs"] = "Find Herbs",
    --     -- Add more options as needed
    --   },
    --   get = function() return TrackingSwitch_X.db.profile.trackingOption3 end,
    --   set = function(_, value)
    --     TrackingSwitch_X.db.profile.trackingOption3 = value
    --     TrackingSwitch_X:UpdateTimerInterval()
    --   end,
    --   width = "half",
    -- },
  },
}


local AceGUI = LibStub("AceGUI-3.0")




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
  -- Check if conditions are met to proceed
  if (not self.db.profile.disableStationary or IsPlayerMoving()) and
      (not self.db.profile.disableResting or not IsResting()) and
      (not self.db.profile.disableCombat or not UnitAffectingCombat("player")) then
    local currentTrackingIndex = GetTrackingTexture()

    -- Check the current tracking spell and switch to the other one
    if currentTrackingIndex == 136025 then
      CastSpellByName("Find Herbs")
    else
      CastSpellByName("Find Minerals")
    end

    -- print("Switched tracking to:", GetTrackingTexture())
  else
    -- print("Conditions not met. Skipping tracking switch.")
  end
end
