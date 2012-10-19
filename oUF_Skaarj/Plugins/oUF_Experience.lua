local _, ns = ...
local cfg = ns.cfg
local oUF = ns.oUF or oUF
assert(oUF, 'oUF Experience was unable to locate oUF install')

if not cfg.Bar then return end

for tag, func in pairs({
	['curxp'] = function(unit)
		return UnitXP(unit)
	end,
	['maxxp'] = function(unit)
		return UnitXPMax(unit)
	end,
	['perxp'] = function(unit)
		return math.floor(UnitXP(unit) / UnitXPMax(unit) * 100 + 0.5)
	end,
	['currested'] = function()
		return GetXPExhaustion()
	end,
	['perrested'] = function(unit)
		local rested = GetXPExhaustion()
		if(rested and rested > 0) then
			return math.floor(rested / UnitXPMax(unit) * 100 + 0.5)
		end
	end,
}) do
	oUF.Tags.Methods[tag] = func
	oUF.Tags.Events[tag] = 'PLAYER_XP_UPDATE PLAYER_LEVEL_UP UPDATE_EXHAUSTION'
end

local function Update(self, event, unit)
	if(self.unit ~= unit) then return end

	local experience = self.Experience
	local min, max = UnitXP(unit), UnitXPMax(unit)
	if(experience.PreUpdate) then experience:PreUpdate(unit) end

	if(UnitLevel(unit) == MAX_PLAYER_LEVEL or UnitHasVehicleUI('player')) then
		return experience:Hide()
	else
		experience:Show()
	end
	
	experience:EnableMouse()
	
	local Text = fs(experience, "OVERLAY", cfg.font, cfg.fontsize, cfg.fontflag, 1, 1, 1)
	Text:SetPoint('CENTER', experience, 'CENTER', 0, 0)
	if(exhaustion) then
		Text:SetText(format('XP: %d / %d (%d%%) |cff0090ff+ %d (%d%%)', min, max, min / max * 100, exhaustion, exhaustion / max * 100))
	else
	    Text:SetText(format('XP: %d / %d (%d%%)', min, max, min / max * 100))
	end
	Text:Hide()
	
	experience:SetScript('OnEnter', function(self)Text:Show()end)
	experience:SetScript('OnLeave', function(self)Text:Hide()end)

	local min, max = UnitXP(unit), UnitXPMax(unit)
	experience:SetMinMaxValues(0, max)
	experience:SetValue(min)

	if(experience.Rested) then
		local exhaustion = GetXPExhaustion() or 0
		experience.Rested:SetMinMaxValues(0, max)
		experience.Rested:SetValue(math.min(min + exhaustion, max))
	end

	if(experience.PostUpdate) then
		return experience:PostUpdate(unit, min, max)
	end
end

local function Path(self, ...)
	return (self.Experience.Override or Update) (self, ...)
end

local function ForceUpdate(element)
	return Path(element.__owner, 'ForceUpdate', element.__owner.unit)
end

local function Enable(self, unit)
	local experience = self.Experience
	if(experience) then
		experience.__owner = self
		experience.ForceUpdate = ForceUpdate

		self:RegisterEvent('PLAYER_XP_UPDATE', Path)
		self:RegisterEvent('PLAYER_LEVEL_UP', Path)

		local rested = experience.Rested
		if(rested) then
			self:RegisterEvent('UPDATE_EXHAUSTION', Path)
			rested:SetFrameLevel(experience:GetFrameLevel() - 1)

			if(not rested:GetStatusBarTexture()) then
				rested:SetStatusBarTexture([=[Interface\TargetingFrame\UI-StatusBar]=])
			end
		end

		if(not experience:GetStatusBarTexture()) then
			experience:SetStatusBarTexture([=[Interface\TargetingFrame\UI-StatusBar]=])
		end

		return true
	end
end

local function Disable(self)
	local experience = self.Experience
	if(experience) then
		self:UnregisterEvent('PLAYER_XP_UPDATE', Path)
		self:UnregisterEvent('PLAYER_LEVEL_UP', Path)

		if(experience.Rested) then
			self:UnregisterEvent('UPDATE_EXHAUSTION', Path)
		end
	end
end

oUF:AddElement('Experience', Path, Enable, Disable)
