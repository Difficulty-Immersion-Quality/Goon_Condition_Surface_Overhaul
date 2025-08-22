-- Helper: Find statuses with the same StackId
local function GetStatusStackId(status)
    local stat = Ext.Stats.Get(status)
    return stat and stat.StackId or nil
end

local function FindActiveStatusWithStackId(character, stackId, excludeStatus)
    local statuses = Ext.Entity.Get(character).StatusManager.Statuses
    for _, s in ipairs(statuses) do
        if s.StatusId ~= excludeStatus then
            local stat = Ext.Stats.Get(s.StatusId)
            if stat and stat.StackId == stackId then
                return s.StatusId
            end
        end
    end
    return nil
end

-- Helper: Get the duration of a status on a character
local function GetStatusDuration(character, status)
    local statuses = Ext.Entity.Get(character).StatusManager.Statuses
    for _, s in ipairs(statuses) do
        if s.StatusId == status then
            return s.CurrentLifeTime or 0
        end
    end
    return 0
end

-- Helper: Set the duration of a status on a character
local function SetStatusDuration(character, status, newDuration)
    Osi.RemoveStatus(character, status)
    Osi.ApplyStatus(character, status, math.floor(newDuration * 6), 1, character) -- duration in seconds (6s per round)
end

-- Listener: Do the thing
Ext.Osiris.RegisterListener("StatusAttemptFailed", 4, "after", function(object, status, causee, storyActionID)
    local stackId = GetStatusStackId(status)
    if not stackId then return end

    local existingStatus = FindActiveStatusWithStackId(object, stackId, status)
    if existingStatus then
        -- You still need to determine the attempted duration (replace 2 with actual value if possible)
        local attemptedDuration = 2
        local currentDuration = GetStatusDuration(object, existingStatus) / 6
        local newDuration = currentDuration + attemptedDuration
        SetStatusDuration(object, existingStatus, newDuration)
        Ext.Utils.Print(string.format("[StatusCombiner] %s failed, extended %s (StackId: %s) on %s to %d rounds", status, existingStatus, stackId, object, newDuration))
    end
end)