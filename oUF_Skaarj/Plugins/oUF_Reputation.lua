local _, ns = ...
local cfg = ns.cfg
local oUF = ns.oUF or oUF
assert(oUF, 'oUF Reputation was unable to locate oUF install')

if not cfg.Bar then return end

for tag, func in pairs({
	['currep'] = function()
		local __, __, min, __, value = GetWatchedFactionInfo()
		return value - min
	end,
	['maxrep'] = function()
		local __, __, min, max = GetWatchedFactionInfo()
		return max - min
	end,
	['perrep'] = function()
		local __, __, min, max, value = GetWatchedFactionInfo()
		return math.floor((value - min) / (max - min) * 100 + 0.5)
	end,
	['standing'] = function()
		local __, standing = GetWatchedFactionInfo()
		return GetText('FACTION_STANDING_LABEL' .. standing, UnitSex('player'))
	end,
	['reputation'] = function()
		return GetWatchedFactionInfo()
	end,
}) do
	oUF.Tags.Methods[tag] = func
	oUF.Tags.Events[tag] = 'UPDATE_FACTION'
end

oUF.Tags.SharedEvents.UPDATE_FACTION = true

local function Update(self, event, unit)
	local reputation = self.Reputation

	local name, standingID, min, max, value = GetWatchedFactionInfo()
	if(not name) or (UnitAffectingCombat"player") then
		return reputation:Hide()
	else
		reputation:Show()
	end
	
	reputation:EnableMouse()

	reputation:SetMinMaxValues(0, max - min)
	reputation:SetValue(value - min)
	reputation:EnableMouse()
	
	barMax, barMin = (max-min), (value-min)
	
	local Text = fs(reputation, "OVERLAY", cfg.font, cfg.fontsize, cfg.fontflag, 1, 1, 1)
	Text:SetPoint('CENTER', reputation, 'CENTER', 0, 0)
	Text:SetText(format('%s: %d / %d (%d%%)', name, barMin, barMax, ((barMin/barMax)*100) ))
	Text:Hide()
	
	reputation:SetScript('OnEnter', function(self)Text:Show()end)
	reputation:SetScript('OnLeave', function(self)Text:Hide()end)

	if(reputation.colorStanding) then
		local color = FACTION_BAR_COLORS[standing]
		reputation:SetStatusBarColor(color.r, color.g, color.b)
	end

	if(reputation.PostUpdate) then
		return reputation:PostUpdate(unit, name, standing, min, max, value)
	end
end

local function Path(self, ...)
	return (self.Reputation.Override or Update) (self, ...)
end

local function ForceUpdate(element)
	return Path(element.__owner, 'ForceUpdate', element.__owner.unit)
end

local function Enable(self, unit)
	local reputation = self.Reputation
	if(reputation) then
		reputation.__owner = self
		reputation.ForceUpdate = ForceUpdate

		self:RegisterEvent('UPDATE_FACTION', Path)

		if(not reputation:GetStatusBarTexture()) then
			reputation:SetStatusBarTexture([=[Interface\TargetingFrame\UI-StatusBar]=])
		end

		return true
	end
end

local function Disable(self)
	if(self.Reputation) then
		self:UnregisterEvent('UPDATE_FACTION', Path)
	end
end

oUF:AddElement('Reputation', Path, Enable, Disable)
