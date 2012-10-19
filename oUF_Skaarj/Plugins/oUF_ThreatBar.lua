local _, ns = ...
local cfg = ns.cfg
local oUF = ns.oUF or oUF
assert(oUF, 'oUF_ThreatBar was unable to locate oUF install.')

if not cfg.TreatBar then return end

local aggroColors = {
	[1] = {0, 1, 0},
	[2] = {1, 1, 0},
	[3] = {1, 0, 0},
}

local function update(self, event, unit)
	if( UnitAffectingCombat(self.unit) ) then
		local _, _, threatpct, rawthreatpct, _ = UnitDetailedThreatSituation(self.unit, self.tar)
		
		if( self.useRawThreat ) then
			threatval = rawthreatpct or 0
		else
			threatval = threatpct or 0
		end
		
		self:SetValue(threatval)
		if( self.Text ) then
			self.Text:SetFormattedText("%3.f%%", threatval)
		end
		
		if( threatval < 30 ) then
			self:SetStatusBarColor(unpack(self.Colors[1]))
		elseif( threatval >= 30 and threatval < 70 ) then
			self:SetStatusBarColor(unpack(self.Colors[2]))
		else
			self:SetStatusBarColor(unpack(self.Colors[3]))
		end
		
	end
end

local function enable(self)
	local bar = self.ThreatBar
	if( bar ) then
		bar:Hide()
		bar:SetMinMaxValues(0, bar.maxThreatVal or 100)

		self:RegisterEvent("PLAYER_REGEN_ENABLED", function(self) self.ThreatBar:Hide() end)
		self:RegisterEvent("PLAYER_REGEN_DISABLED", function(self) self.ThreatBar:Show() end)
		
		bar:SetScript("OnUpdate", update)
		
		bar.Colors = (self.ThreatBar.Colors or aggroColors)
		bar.unit = self.unit
		
		if( self.usePlayerTarget ) then
			bar.tar = "playertarget"
		else
			bar.tar = bar.unit.."target"
		end

		return true
	end
end

local function disable(self)
	local bar = self.ThreatBar
	if( bar ) then
		bar:UnregisterEvent("PLAYER_REGEN_ENABLED")
		bar:UnregisterEvent("PLAYER_REGEN_DISABLED")
		bar:Hide()
		bar:SetScript("OnEvent", nil)
	end
end

oUF:AddElement("ThreatBar", function() return end, enable, disable)