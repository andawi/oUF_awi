local name, ns = ...
local cfg = ns.cfg
local _, class = UnitClass('player')

local backdrop = {
    bgFile = [=[Interface\ChatFrame\ChatFrameBackground]=],
    insets = {top = 0, left = 0, bottom = 0, right = 0},
}

local backdrop_1px = {
    bgFile = [=[Interface\ChatFrame\ChatFrameBackground]=],
    insets = {top = -1, left = -1, bottom = -1, right = -1},
}

local OnEnter = function(self)
    UnitFrame_OnEnter(self)
    self.Highlight:Show()	
end

local OnLeave = function(self)
    UnitFrame_OnLeave(self)
    self.Highlight:Hide()	
end

local Highlight = function(self) 
    self.Highlight = self.Health:CreateTexture(nil, "OVERLAY")
    self.Highlight:SetAllPoints(self)
    self.Highlight:SetTexture([=[Interface\Buttons\WHITE8x8]=])
    self.Highlight:SetVertexColor(1,1,1,.1)
    self.Highlight:SetBlendMode("ADD")
    self.Highlight:Hide()
end
	
local ChangedTarget = function(self)
    if UnitIsUnit('target', self.unit) then
        self.TargetBorder:Show()
    else
        self.TargetBorder:Hide()
    end
end

local FocusTarget = function(self)
    if UnitIsUnit('focus', self.unit) then
        self.FocusHighlight:Show()
    else
        self.FocusHighlight:Hide()
    end
end

local dropdown = CreateFrame('Frame', name .. 'DropDown', UIParent, 'UIDropDownMenuTemplate')

local function menu(self)
	dropdown:SetParent(self)
	return ToggleDropDownMenu(1, nil, dropdown, self:GetName(), -3, 0)
end

local init = function(self)
	local unit = self:GetParent().unit
	local menu, name, id

	if(not unit) then
		return
	end

	if(UnitIsUnit(unit, "player")) then
		menu = "SELF"
    elseif(UnitIsUnit(unit, "vehicle")) then
		menu = "VEHICLE"
	elseif(UnitIsUnit(unit, "pet")) then
		menu = "PET"
	elseif(UnitIsPlayer(unit)) then
		id = UnitInRaid(unit)
		if(id) then
			menu = "RAID_PLAYER"
			name = GetRaidRosterInfo(id)
		elseif(UnitInParty(unit)) then
			menu = "PARTY"
		else
			menu = "PLAYER"
		end
	else
		menu = "TARGET"
		name = RAID_TARGET_ICON
	end

	if(menu) then
		UnitPopup_ShowMenu(self, menu, unit, name, id)
	end
end

UIDropDownMenu_Initialize(dropdown, init, 'MENU')

local GetTime = GetTime
local floor, fmod = floor, math.fmod
local day, hour, minute = 86400, 3600, 60

local FormatTime = function(s)
    if s >= day then
        return format("%dd", floor(s/day + 0.5))
    elseif s >= hour then
        return format("%dh", floor(s/hour + 0.5))
    elseif s >= minute then
        return format("%dm", floor(s/minute + 0.5))
    end

    return format("%d", fmod(s, minute))
end

local CreateAuraTimer = function(self,elapsed)
    self.elapsed = (self.elapsed or 0) + elapsed
	if self.elapsed >= 0.1 then
		self.timeLeft = self.expires - GetTime()
		if self.timeLeft > 0 then
			local time = FormatTime(self.timeLeft)
				self.remaining:SetText(time)
			if self.timeLeft < 6 then
				self.remaining:SetTextColor(0.69, 0.31, 0.31)
			else
				self.remaining:SetTextColor(0.84, 0.75, 0.65)
			end
		else
			self.remaining:Hide()
			self:SetScript("OnUpdate", nil)
		end
		self.elapsed = 0
	end
end


local UpdateAuraTrackerTime = function(self, elapsed)
	if self.active then
		self.timeleft = self.timeleft - elapsed
		if self.timeleft <= 5 then
			self.text:SetTextColor(1, 0, 0) 
		else
			self.text:SetTextColor(1, 1, 1) 
		end
		if self.timeleft <= 0 then
			self.icon:SetTexture('')
			self.text:SetText('')
		end	
		self.text:SetFormattedText('%.1f', self.timeleft)
	end
end

local auraIcon = function(auras, button)
    local c = button.count
    c:ClearAllPoints()
    c:SetFontObject(nil)
    c:SetFont(cfg.aura_font, cfg.aura_fontsize, cfg.aura_fontflag)
    c:SetTextColor(.8, .8, .8)
    auras.disableCooldown = cfg.disableCooldown
    button.icon:SetTexCoord(.1, .9, .1, .9)
	if cfg.border then
        auras.showDebuffType = true
        button.overlay:SetTexture(cfg.buttonTex)
        button.overlay:SetPoint("TOPLEFT", button, "TOPLEFT", -2, 2)
        button.overlay:SetPoint("BOTTOMRIGHT", button, "BOTTOMRIGHT", 2, -2)
        button.overlay:SetTexCoord(0, 1, 0.02, 1)
        button.overlay.Hide = function(self) self:SetVertexColor(0.33, 0.59, 0.33) end
		c:SetPoint("BOTTOMRIGHT")
		button.bg = framebd(button, button)
	else
        button.overlay:Hide()
		auras.showDebuffType = true
		button.overlay:SetTexture(nil)
		c:SetPoint("BOTTOMRIGHT", 3, -1)
        button:SetBackdrop(backdrop_1px)
	    button:SetBackdropColor(0, 0, 0, 1)
        button.glow = CreateFrame("Frame", nil, button)
        button.glow:SetPoint("TOPLEFT", button, "TOPLEFT", -4, 4)
        button.glow:SetPoint("BOTTOMRIGHT", button, "BOTTOMRIGHT", 4, -4)
        button.glow:SetFrameLevel(button:GetFrameLevel()-1)
        button.glow:SetBackdrop({bgFile = "", edgeFile = "Interface\\AddOns\\Media\\glowTex",
        edgeSize = 5,insets = {left = 3,right = 3,top = 3,bottom = 3,},})
	end
    local remaining = fs(button, "OVERLAY", cfg.aura_font, cfg.aura_fontsize, cfg.aura_fontflag, .8, .8, .8)
    remaining:SetPoint("TOPLEFT")
    button.remaining = remaining
end

local PostUpdateIcon = function(icons, unit, icon, index, offset)
	local name, _, _, _, dtype, duration, expirationTime, unitCaster = UnitAura(unit, index, icon.filter)

	local texture = icon.icon
	if icon.isPlayer or UnitIsFriend('player', unit) or not icon.isDebuff then
		texture:SetDesaturated(false)
	else
		texture:SetDesaturated(true)
	end

	if duration and duration > 0 then
		icon.remaining:Show()
	else
		icon.remaining:Hide()
	end
		
	if not cfg.border then
		if icon.isDebuff then
		    local r,g,b = icon.overlay:GetVertexColor()
		    icon.glow:SetBackdropBorderColor(r,g,b,1)
	    else 
		    icon.glow:SetBackdropBorderColor(0,0,0,1)
	    end
    end
		
    icon.duration = duration
    icon.expires = expirationTime
    icon:SetScript("OnUpdate", CreateAuraTimer)
    
end

local CustomFilter = function(icons, ...)
    local _, icon, name, _, _, _, _, _, _, caster = ...
    local isPlayer

    if (caster == 'player' or caster == 'vechicle') then
        isPlayer = true
    end

    if((icons.onlyShowPlayer and isPlayer) or (not icons.onlyShowPlayer and name)) then
        icon.isPlayer = isPlayer
        icon.owner = caster
        return true
    end
end

local PostUpdateHealth = function(health, unit)
	if(UnitIsDead(unit)) then
		health:SetValue(0)
	elseif(UnitIsGhost(unit)) then
		health:SetValue(0)
	elseif not (UnitIsConnected(unit)) then
	    health:SetValue(0)
	end
end
	
local PostAltUpdate = function(self, min, cur, max)
    local per = math.floor((cur/max)*100)		
	if per < 30 then
		self:SetStatusBarColor(0, 1, 0)
	elseif per < 60 then
		self:SetStatusBarColor(1, 1, 0)
	else
		self:SetStatusBarColor(1, 0, 0)
	end
end

local UpdateComboPoint = function(self, event, unit)
	if(unit == 'pet') then return end	
	local cpoints = self.CPoints
	local cp
	if (UnitHasVehicleUI("player") or UnitHasVehicleUI("vehicle")) then
		cp = GetComboPoints('vehicle', 'target')
	else
		cp = GetComboPoints('player', 'target')
	end

	for i=1, 5 do
		if(i <= cp) then
			cpoints[i]:SetAlpha(1)
		else
			cpoints[i]:SetAlpha(0.2)
		end
	end
		
	if UnitExists("target") and UnitCanAttack("player", "target") and (not UnitIsDead("target")) then
		for i=1, 5 do
			cpoints:Show()
		end
			
	else
		for i=1, 5 do
			cpoints:Hide()
		end
			
	end
end

local AWIcon = function(AWatch, icon, spellID, name, self)			
	local count = fs(icon, "OVERLAY", cfg.font, 8, cfg.fontflag, 1, 1, 1)
	count:SetPoint("BOTTOMRIGHT", icon, 5, -5)
	icon.count = count
	icon.cd:SetReverse(true)
end

local createAuraWatch = function(self, unit)
	if cfg.showAuraWatch then
		local auras = CreateFrame("Frame", nil, self)
		auras:SetAllPoints(self.Health)
		auras.onlyShowPresent = cfg.onlyShowPresent
		auras.anyUnit = cfg.anyUnit
		auras.icons = {}
		auras.PostCreateIcon = AWIcon
		
		for i, v in pairs(cfg.spellIDs[class]) do
			local icon = CreateFrame("Frame", nil, auras)
			icon.spellID = v[1]
			icon:SetSize(6, 6)
			if v[3] then
			    icon:SetPoint(v[3])
			else
			    icon:SetPoint("BOTTOMLEFT", self.Health, "BOTTOMRIGHT", -7 * i, 0)
			end
			icon:SetBackdrop(backdrop_1px)
	        icon:SetBackdropColor(0, 0, 0, 1)
			
			local tex = icon:CreateTexture(nil, 'ARTWORK')
			tex:SetAllPoints(icon)
			tex:SetTexCoord(.1, .9, .1, .9)
			tex:SetTexture(cfg.texture)
			tex:SetVertexColor(unpack(v[2]))
			icon.icon = tex
		
			auras.icons[v[1]] = icon
		end
		self.AuraWatch = auras
	end
end


local RaidIcon = function(self)
	ricon = self.Health:CreateTexture(nil, "OVERLAY")
	ricon:SetTexture(cfg.raidIcons)
	self.RaidIcon = ricon
end
    
local Resurrect = function(self) 
    res = CreateFrame('Frame', nil, self)
	res:SetSize(22, 22)
	res:SetPoint('CENTER', self)
	res:SetFrameStrata'HIGH'
    res:SetBackdrop(backdrop_1px)
    res:SetBackdropColor(.2, .6, 1)
    res.icon = res:CreateTexture(nil, 'OVERLAY')
	res.icon:SetTexture[[Interface\Icons\Spell_Holy_Resurrection]]
	res.icon:SetTexCoord(.1, .9, .1, .9)
    res.icon:SetAllPoints(res)
	self.ResurrectIcon = res
end

local Healcomm = function(self) 
	local mhb = createStatusbar(self.Health, cfg.texture, nil, nil, self:GetWidth(), 0.33, 0.59, 0.33, 0.75)
	mhb:SetPoint("TOPLEFT", self.Health:GetStatusBarTexture(), "TOPRIGHT")
	mhb:SetPoint("BOTTOMLEFT", self.Health:GetStatusBarTexture(), "BOTTOMRIGHT")

	local ohb = createStatusbar(self.Health, cfg.texture, nil, nil, self:GetWidth(), 0.33, 0.59, 0.33, 0.75)
	ohb:SetPoint("TOPLEFT", self.Health:GetStatusBarTexture(), "TOPRIGHT")
	ohb:SetPoint("BOTTOMLEFT", self.Health:GetStatusBarTexture(), "BOTTOMRIGHT")

    self.HealPrediction = {
	myBar = mhb,
	otherBar = ohb,
	maxOverflow = 1,}
			
	self.MyHealBar = mhb
	self.OtherHealBar = ohb
end

local Setfocus = function(self) 
	local ModKey = 'Shift'
    local MouseButton = 1
    local key = ModKey .. '-type' .. (MouseButton or '')
	if(self.unit == 'focus') then
	    self:SetAttribute(key, 'macro')
		self:SetAttribute('macrotext', '/clearfocus')
	else
		self:SetAttribute(key, 'focus')
    end
end

local Portraits = function(self) 
    self.Portrait = CreateFrame("PlayerModel", nil, self)
	self.Portrait:SetAllPoints(self.Health)
	self.Portrait:SetAlpha(0.2)
	self.Portrait:SetFrameLevel(self.Health:GetFrameLevel())
end   

local Shared = function(self, unit)

    self.menu = menu
	
	self:SetBackdrop(backdrop)
	self:SetBackdropColor(0, 0, 0)
	
    self:SetScript("OnEnter", OnEnter)
    self:SetScript("OnLeave", OnLeave)
    self:RegisterForClicks"AnyUp"
	
    self.framebd = framebd(self, self)
	
	self.DebuffHighlight = cfg.DebuffHighlight
	self.DebuffHighlightFilter = cfg.DebuffHighlightFilter

    local h = createStatusbar(self, cfg.texture, nil, nil, nil, cfg.Color.Health.r, cfg.Color.Health.g, cfg.Color.Health.b, 1)
    h:SetPoint"TOP"
	h:SetPoint"LEFT"
	h:SetPoint"RIGHT"
	
	local hbg = h:CreateTexture(nil, "BACKGROUND")
    hbg:SetAllPoints(h)
    hbg:SetTexture(cfg.texture)
   
    h.frequentUpdates = false
	
	if cfg.class_colorbars then
        h.colorClass = true
        h.colorReaction = true
		hbg.multiplier = .2
	else
		hbg:SetVertexColor(.5, .5, .5, .2)
    end
	
	if cfg.Smooth then h.Smooth = true end
	
	h.bg = hbg
    self.Health = h
	h.PostUpdate = PostUpdateHealth

    if not (unit == "targettarget" or unit == "pet" or unit == "focustarget") then
        local p = createStatusbar(self, cfg.texture, nil, nil, nil, 1, 1, 1, 1)
		p:SetPoint"LEFT"
		p:SetPoint"RIGHT"
        p:SetPoint("BOTTOM", h, 0, -(cfg.power_height+1)) 
		
        p.frequentUpdates = true
        
	    if cfg.Smooth then p.Smooth = true end

        local pbg = p:CreateTexture(nil, "BACKGROUND")
        pbg:SetAllPoints(p)
        pbg:SetTexture(cfg.texture)
        pbg.multiplier = .2
		
		if cfg.class_colorbars then 
            p.colorPower = true
        else
            p.colorClass = true
        end
	
        p.bg = pbg
        self.Power = p
    end
	
	local l = h:CreateTexture(nil, "OVERLAY")
	if (unit == "raid") then
	    l:SetPoint("BOTTOMLEFT", h, "TOPLEFT", -1, -2)
        l:SetSize(10, 10)
	else
	    l:SetPoint("BOTTOMLEFT", h, "TOPLEFT", -2, -4)
        l:SetSize(16, 16)
	end
    self.Leader = l

    local ml = h:CreateTexture(nil, 'OVERLAY')
	    ml:SetPoint("LEFT", l, "RIGHT")
	if (unit == "raid") then
        ml:SetSize(10, 10)
    else
	    ml:SetSize(14, 14)
	end
    self.MasterLooter = ml

	local a = h:CreateTexture(nil, "OVERLAY")
	if (unit == "raid") then
	    a:SetPoint("BOTTOMLEFT", h, "TOPLEFT", -1, -2)
        a:SetSize(10, 10)
	else
	    a:SetPoint("BOTTOMLEFT", h, "TOPLEFT", -2, -4)
        a:SetSize(16, 16)
	end
	self.Assistant = a

	local rc = h:CreateTexture(nil, "OVERLAY")
	rc:SetSize(14, 14)
	if (unit == "raid") then
	    rc:SetPoint("BOTTOM", h)
	else
        rc:SetPoint("CENTER", h)
	end
	self.ReadyCheck = rc
	
	RaidIcon(self)
	Highlight(self)
	Setfocus(self)
	
	self:SetScale(cfg.scale) 
end

local UnitSpecific = {
    player = function(self, ...)
        Shared(self, ...)
		
		self:SetSize(cfg.width, cfg.health_height+cfg.power_height+1)
		self.Health:SetHeight(cfg.health_height)
		self.Power:SetHeight(cfg.power_height)
		self.unit = "player"
		
		if cfg.portraits then Portraits(self) end
	
	    if cfg.healcomm then Healcomm(self) end
		
		local name = fs(self.Health, "OVERLAY", cfg.font, cfg.fontsize, cfg.fontflag, 1, 1, 1)
        name:SetPoint("LEFT", self.Health, 4, 0)
        name:SetJustifyH"LEFT"
		if cfg.class_colorbars then
		    self:Tag(name, '[skaarj:lvl] [long:name]')
		else
		    self:Tag(name, '[skaarj:lvl] [skaarj:color][long:name]')
		end
		
		local htext = fs(self.Health, "OVERLAY", cfg.font, cfg.fontsize, cfg.fontflag, 1, 1, 1)
        htext:SetPoint("RIGHT", self.Health, -2, 0)
		htext.frequentUpdates = .1
        self:Tag(htext, '[skaarj:hp][skaarj:pp]')
		
		self.RaidIcon:SetSize(23, 23)
	    self.RaidIcon:SetPoint("TOP", self.Health, 0, 11)
		
		if cfg.auras then
            local d = CreateFrame("Frame", nil, self)
			d.size = 24
			d.spacing = 4
			d.num = cfg.player_debuffs_num 
            d:SetPoint("BOTTOMLEFT", self, "TOPLEFT", 1, 7)
			d:SetSize(cfg.width, d.size)
            d.initialAnchor = "TOPLEFT"
            d["growth-y"] = "UP"
            d.PostCreateIcon = auraIcon
            d.PostUpdateIcon = PostUpdateIcon
            d.CustomFilter = CustomFilter
            self.Debuffs = d
        end			
		
		local ct = self.Health:CreateTexture(nil, 'OVERLAY')
        ct:SetSize(20, 20)
        ct:SetPoint('CENTER', self.Health)
        self.Combat = ct

		local r = fs(self.Health, "OVERLAY", cfg.symbol, 15, "OUTLINE", 1, 1, 1)
	    r:SetPoint("BOTTOMLEFT", 0, -10)
	    r:SetText("|cff5F9BFFR|r")
	    self.Resting = r
		
		local PvP = self.Health:CreateTexture(nil, 'OVERLAY')
        PvP:SetSize(28, 28)
        PvP:SetPoint('BOTTOMLEFT', self.Health, 'TOPRIGHT', -15, -20)
        self.PvP = PvP
		
        if cfg.specific_power then 
		    if (class == "DEATHKNIGHT" or class == "PALADIN" or class == "MONK") then
                local c
                if class == "DEATHKNIGHT" then 
                    c = 6
			    elseif class == "PALADIN" then
	                local numMax = UnitPowerMax("player", SPELL_POWER_HOLY_POWER)
					c = numMax
                elseif class == "MONK" then
	                local numMax = UnitPowerMax("player", SPELL_POWER_LIGHT_FORCE)
					c = numMax 							
                end

                local b = CreateFrame("Frame", nil, self)
				b:SetFrameStrata("LOW")
                b:SetPoint("TOPRIGHT", self, "BOTTOMRIGHT", 0, -1)
                b:SetSize(cfg.width, cfg.specific_power_height)
				b.bd = framebd(b, b)

                local i = c
                for index = 1, c do
                    b[i] = createStatusbar(b, cfg.texture, nil, cfg.specific_power_height, (cfg.width+1)/c-1, 1, 1, 1, 1)
				
				    if i == c then
                        b[i]:SetPoint("RIGHT", b)
                    else
                        b[i]:SetPoint("RIGHT", b[i+1], "LEFT", -1, 0)
                    end

                    if class == "PALADIN" then
                        local color = self.colors.power["HOLY_POWER"]
                        b[i]:SetStatusBarColor(color[1], color[2], color[3])   
				    elseif class == "MONK" then
				        local color = self.colors.power["LIGHT_FORCE"]
                        b[i]:SetStatusBarColor(color[1], color[2], color[3]) 
                    end 

                    b[i].bg = b[i]:CreateTexture(nil, "BACKGROUND")
                    b[i].bg:SetAllPoints(b[i])
                    b[i].bg:SetTexture(cfg.texture)
                    b[i].bg.multiplier = .2

                    i=i-1
                end

                if class == "DEATHKNIGHT" then
                    self.Runes = b
                end
            end
		
		    			
			if class == "PRIEST" then
			    sob = CreateFrame("Frame", self:GetName().."_ShadowOrbsBar", self)
				sob:SetFrameStrata("LOW")
			    sob:SetPoint("TOPRIGHT", self, "BOTTOMRIGHT", 0, -1)
			    sob:SetSize(cfg.width, cfg.specific_power_height)
			    sob.bd = framebd(sob, sob)

			    for i = 1, 3 do
				    sob[i] = createStatusbar(sob, cfg.texture, nil, cfg.specific_power_height, (cfg.width+1)/3-1, 0.70, 0.32, 0.75, 1)
				    if i == 1 then
					    sob[i]:SetPoint("LEFT", sob, "LEFT")
				    else
					    sob[i]:SetPoint("LEFT", sob[i-1], "RIGHT", 1, 0)
				    end
				
				    sob[i].bg = sob[i]:CreateTexture(nil, "BORDER")
                    sob[i].bg:SetAllPoints(sob[i])
                    sob[i].bg:SetTexture(cfg.texture)
                    sob[i].bg.multiplier = .2
				
				   self.ShadowOrbsBar = sob
			    end
		    end
        
            if class == "DRUID" then
                local ebar = CreateFrame("Frame", nil, self)
				ebar:SetFrameStrata("LOW")
                ebar:SetPoint("TOPRIGHT", self, "BOTTOMRIGHT", 0, -1)
                ebar:SetSize(cfg.width, cfg.specific_power_height)
				ebar.bd = framebd(ebar, ebar)

                local lbar = createStatusbar(ebar, cfg.texture, nil, cfg.specific_power_height, cfg.width, 0, .4, 1, 1)
                lbar:SetPoint("LEFT", ebar, "LEFT")
                ebar.LunarBar = lbar

                local sbar = createStatusbar(ebar, cfg.texture, nil, cfg.specific_power_height, cfg.width, 1, .6, 0, 1)
                sbar:SetPoint("LEFT", lbar:GetStatusBarTexture(), "RIGHT")
                ebar.SolarBar = sbar

                ebar.Spark = sbar:CreateTexture(nil, "OVERLAY")
                ebar.Spark:SetTexture[[Interface\CastingBar\UI-CastingBar-Spark]]
                ebar.Spark:SetBlendMode("ADD")
                ebar.Spark:SetAlpha(0.5)
                ebar.Spark:SetHeight(26)
                ebar.Spark:SetPoint("LEFT", sbar:GetStatusBarTexture(), "LEFT", -15, 0)
				
				ebar.Text = fs(ebar.SolarBar, "OVERLAY", cfg.font, cfg.fontsize, cfg.fontflag, 0.8, 0.8, 0.8)
                ebar.Text:SetPoint("CENTER", ebar)
                self:Tag(ebar.Text, "[skaarj:EclipseDirection]")
					
				self.EclipseBar = ebar
            end
						
		end
		
		if class == "DRUID" and cfg.DruidMana then
		    local color = self.colors.power["MANA"]
		    local DruidMana = createStatusbar(self, cfg.texture, nil, cfg.specific_power_height, cfg.width, color[1], color[2], color[3], 1)
			DruidMana:SetFrameStrata("LOW")
            DruidMana:SetPoint("TOPRIGHT", self, "BOTTOMRIGHT", 0, -1)
		    DruidMana.bd = framebd(DruidMana, DruidMana)
			
            local bg = DruidMana:CreateTexture(nil, 'BACKGROUND')
            bg:SetAllPoints(DruidMana)
            bg.multiplier = 0.2
			
            self.DruidMana = DruidMana
            self.DruidMana.bg = bg
		end
		
		if cfg.AltPowerBar then
	       local altp = createStatusbar(self, cfg.texture, nil, cfg.AltPowerBar_Height, cfg.AltPowerBar_Width, 1, 1, 1, 1)
           altp:SetPoint(unpack(cfg.AltPowerBar_pos))
           altp.bg = altp:CreateTexture(nil, 'BORDER')
           altp.bg:SetAllPoints(altp)
           altp.bg:SetTexture(cfg.texture)
           altp.bg:SetVertexColor(1, 0, 0, 0.2)
           altp.bd = framebd(altp, altp)
           altp.Text = fs(altp, "OVERLAY", cfg.font, cfg.fontsize, cfg.fontflag, 0.8, 0.8, 0.8)
           altp.Text:SetPoint("CENTER")
           self:Tag(altp.Text, "[skaarj:altpower]")
           altp.PostUpdate = PostAltUpdate
           self.AltPowerBar = altp
	    end
    end,

    target = function(self, ...)
        Shared(self, ...)
		
		self:SetSize(cfg.width, cfg.health_height+cfg.power_height+1)
		self.Health:SetHeight(cfg.health_height)
		self.Power:SetHeight(cfg.power_height)
		self.unit = "target"
		
		if cfg.healcomm then Healcomm(self) end
		
		if cfg.portraits then Portraits(self) end
		
		local name = fs(self.Health, "OVERLAY", cfg.font, cfg.fontsize, cfg.fontflag, 1, 1, 1)
        name:SetPoint("LEFT", self.Health, 4, 0)
        name:SetJustifyH"LEFT"
		if cfg.class_colorbars then
		    self:Tag(name, '[skaarj:lvl] [long:name]')
		else 
		    self:Tag(name, '[skaarj:lvl] [skaarj:color][long:name]')
		end

		local htext = fs(self.Health, "OVERLAY", cfg.font, cfg.fontsize, cfg.fontflag, 1, 1, 1)
        htext:SetPoint("RIGHT", self.Health, -2, 0)
		htext.frequentUpdates = .1
        self:Tag(htext, '[skaarj:hp][skaarj:pp]')
		
		self.RaidIcon:SetSize(23, 23)
	    self.RaidIcon:SetPoint("TOP", self.Health, 0, 11)
		
		if cfg.auras then
            local b = CreateFrame("Frame", nil, self)
			b.size = 24
			b.spacing = 4
		    b.num = cfg.target_buffs_num
            b:SetSize(b.size*4+b.spacing*3, b.size)
		    b:SetPoint("TOPLEFT", self, "TOPRIGHT", 5, 0)
            b.initialAnchor = "TOPLEFT" 
            b["growth-y"] = "DOWN"
            b.PostCreateIcon = auraIcon
            b.PostUpdateIcon = PostUpdateIcon
            self.Buffs = b

            local d = CreateFrame("Frame", nil, self)
			d.size = 24
			d.spacing = 4
		    d.num = cfg.target_debuffs_num
            d:SetPoint("BOTTOMLEFT", self, "TOPLEFT", 1, 7)
			d:SetSize(cfg.width, d.size)
            d.initialAnchor = "TOPLEFT"
            d["growth-y"] = "UP"
            d.onlyShowPlayer = cfg.onlyShowPlayer
            d.PostCreateIcon = auraIcon
            d.PostUpdateIcon = PostUpdateIcon
            d.CustomFilter = CustomFilter
            self.Debuffs = d       
        end
		
		if cfg.specific_power then
		    if class == "DRUID" or class == "ROGUE" then
		        local cp = CreateFrame("Frame", nil, self)
		        local c = 5
		        local color = self.colors.class[class]
                cp:SetPoint("TOPRIGHT", self, "BOTTOMRIGHT", 0, -1)
                cp:SetSize(cfg.width, cfg.specific_power_height)
			    cp.bd = framebd(cp, cp)
		        local i = c
                for index = 1, c do
                    cp[i] = createStatusbar(cp, cfg.texture, nil, cfg.specific_power_height, (cfg.width+1)/c-1, color[1], color[2], color[3], 1)
				
                    if i == c then
                        cp[i]:SetPoint("RIGHT", cp)
                    else
                        cp[i]:SetPoint("RIGHT", cp[i+1], "LEFT", -1, 0)
                    end

                    cp[i].bg = cp[i]:CreateTexture(nil, "BACKGROUND")
                    cp[i].bg:SetAllPoints(cp[i])
                    cp[i].bg:SetTexture(cfg.texture)
                    cp[i].bg.multiplier = .2

                    i=i-1
                end
			
		        self.CPoints = cp
		        self.CPoints.Override = UpdateComboPoint
			end
		end
		
		local q = fs(self.Health, "OVERLAY", cfg.font, 22, cfg.fontflag, 1, 1, 1)
	    q:SetPoint('TOP', self.Health,'RIGHT', -5, -7)
	    q:SetText("|cff8AFF30!|r")
	    self.QuestIcon = q

        local ph = self.Health:CreateTexture(nil, 'OVERLAY')
        ph:SetSize(24, 24)
        ph:SetPoint('CENTER', self.Health, 'BOTTOMLEFT', 3, -3)
        self.PhaseIcon = ph
		
		local PvP = self.Health:CreateTexture(nil, 'OVERLAY')
        PvP:SetSize(28, 28)
        PvP:SetPoint('BOTTOMLEFT', self.Health, 'TOPRIGHT', -15, -20)
        self.PvP = PvP
    end,

    focus = function(self, ...)
        Shared(self, ...)
		
		self:SetSize(cfg.width, cfg.health_height+cfg.power_height+1)
		self.Health:SetHeight(cfg.health_height)
		self.Power:SetHeight(cfg.power_height)
		self.unit = "focus"
		
		if cfg.healcomm then Healcomm(self) end
		
		local name = fs(self.Health, "OVERLAY", cfg.font, cfg.fontsize, cfg.fontflag, 1, 1, 1)
        name:SetPoint("LEFT", self.Health, 4, 0)
        name:SetJustifyH"LEFT"
		if cfg.class_colorbars then
		    self:Tag(name, '[skaarj:lvl] [long:name]')
		else
		    self:Tag(name, '[skaarj:lvl] [skaarj:color][long:name]')
		end
		
		local htext = fs(self.Health, "OVERLAY", cfg.font, cfg.fontsize, cfg.fontflag, 1, 1, 1)
        htext:SetPoint("RIGHT", self.Health, -2, 0)
		htext.frequentUpdates = .1
        self:Tag(htext, '[skaarj:hp][skaarj:pp]')
		
		self.RaidIcon:SetSize(23, 23)
	    self.RaidIcon:SetPoint("TOP", self.Health, 0, 11)
		
        if cfg.auras then 
            local a = CreateFrame("Frame", nil, self)
			a.size = 24
			a.spacing = 4
			a:SetPoint("BOTTOMLEFT", self, "TOPLEFT", 1, 7)
            a:SetSize(cfg.width, a.size)
            a.gap = true
            a.initialAnchor = "TOPLEFT"
			a["growth-y"] = "UP"
            a.PostCreateIcon = auraIcon
            a.PostUpdateIcon = PostUpdateIcon
            self.Auras = a
        end
    end,

	boss = function(self, ...)
        Shared(self, ...)
		
	    self:SetSize(cfg.boss_width, cfg.boss_health_height+cfg.boss_power_height+1)
		self.Health:SetHeight(cfg.boss_health_height)
		self.Power:SetHeight(cfg.boss_power_height)
		self.unit = "boss"
		
		local name = fs(self.Health, "OVERLAY", cfg.font, cfg.fontsize, cfg.fontflag, 1, 1, 1)
        name:SetPoint("LEFT", self.Health, 4, 0)
        name:SetJustifyH"LEFT"
		if cfg.class_colorbars then
		    self:Tag(name, '[long:name]')
		else
		    self:Tag(name, '[skaarj:color][long:name]')
		end
		
		local htext = fs(self.Health, "OVERLAY", cfg.font, cfg.fontsize, cfg.fontflag, 1, 1, 1)
        htext:SetPoint("RIGHT", self.Health, -2, 0)
		htext.frequentUpdates = true
        self:Tag(htext, '[party:hp]')
		
		self.RaidIcon:SetSize(20, 20)
	    self.RaidIcon:SetPoint("TOP", self.Health, 0, 10)
		
		if cfg.auras then 
            local b = CreateFrame("Frame", nil, self)
			b.size = 24
			b.spacing = 4
			b.num = 3
            b:SetSize(b.num*b.size+b.spacing*(b.num-1), b.size)
            b:SetPoint("TOPLEFT", self, "TOPRIGHT", 5, 0)
            b.initialAnchor = "TOPLEFT"
            b.PostCreateIcon = auraIcon
            b.PostUpdateIcon = PostUpdateIcon
            self.Buffs = b       
        end
    end,

    pet = function(self, ...)
        Shared(self, ...)
		
		self:SetSize(cfg.pet_width, cfg.pet_height)
		
		local name = fs(self.Health, "OVERLAY", cfg.font, cfg.fontsize, cfg.fontflag, 1, 1, 1)
        name:SetPoint("CENTER", self.Health)
		if cfg.class_colorbars then
		    self:Tag(name, '[short:name]')
		else
		    self:Tag(name, '[skaarj:color][short:name]')
		end
	    
		self.RaidIcon:SetSize(20, 20)
	    self.RaidIcon:SetPoint("TOP", self.Health, 0, 10)
		
        if cfg.auras then 
            local d = CreateFrame("Frame", nil, self)
			d.size = 24
			d.spacing = 4
			d.num = 3
            d:SetSize(d.num*d.size+d.spacing*(d.num-1), d.size)
            d:SetPoint("TOPRIGHT", self, "TOPLEFT", -5, 0)
            d.initialAnchor = "TOPRIGHT"
			d["growth-x"] = "LEFT"
            d.PostCreateIcon = auraIcon
            d.PostUpdateIcon = PostUpdateIcon
            self.Debuffs = d
        end
    end,

    targettarget = function(self, ...)
	    Shared(self, ...)
				 
	    self:SetSize(cfg.pet_width, cfg.pet_height)
		
		local name = fs(self.Health, "OVERLAY", cfg.font, cfg.fontsize, cfg.fontflag, 1, 1, 1)
        name:SetPoint("CENTER", self.Health)
		if cfg.class_colorbars then
		    self:Tag(name, '[short:name]')
		else
		    self:Tag(name, '[skaarj:color][short:name]')
		end
		
		self.RaidIcon:SetSize(20, 20)
	    self.RaidIcon:SetPoint("TOP", self.Health, 0, 10)
		 
        if cfg.auras then 
            local d = CreateFrame("Frame", nil, self)
			d.size = 24
			d.spacing = 4
			d.num = 3
            d:SetSize(d.num*d.size+d.spacing*(d.num-1), d.size)
            d:SetPoint("TOPLEFT", self, "TOPRIGHT", 5, 0)
            d.initialAnchor = "TOPLEFT"
            d.PostCreateIcon = auraIcon
            d.PostUpdateIcon = PostUpdateIcon
            self.Debuffs = d
        end
    end,
	
	party = function(self, ...)
		Shared(self, ...)
		
		self.Health:SetHeight(cfg.party_health_height)
		self.Power:SetHeight(cfg.party_power_height)
		self.unit = "party"
		
		if cfg.healcomm then Healcomm(self) end
		
		Resurrect(self)
		
		local lfd = fs(self.Health, "OVERLAY", cfg.symbol, 14, OUTLINE, 1, 1, 1)
		lfd:SetPoint("LEFT", self.Health, 4, 0)
		lfd:SetJustifyH"LEFT"
	    self:Tag(lfd, '[skaarj:LFD]')
		
		local name = fs(self.Health, "OVERLAY", cfg.font, cfg.fontsize, cfg.fontflag, 1, 1, 1)
        name:SetPoint("LEFT", lfd, "RIGHT", 0, 0)
        name:SetJustifyH"LEFT"
		if cfg.class_colorbars then
		    self:Tag(name, ' [long:name] [skaarj:lvl]')
		else
		    self:Tag(name, ' [skaarj:color][long:name] [skaarj:lvl]')
		end
		
		local htext = fs(self.Health, "OVERLAY", cfg.font, cfg.fontsize, cfg.fontflag, 1, 1, 1)
        htext:SetPoint("RIGHT", self.Health, -2, 0)
		htext.frequentUpdates = true
        self:Tag(htext, '[party:hp]')
		
		self.RaidIcon:SetSize(20, 20)
	    self.RaidIcon:SetPoint("TOP", self.Health, 0, 10)
		
		if cfg.auras then
           local d = CreateFrame("Frame", nil, self)
			d.size = 24
			d.spacing = 4
			d.num = 3
            d:SetSize(d.num*d.size+d.spacing*(d.num-1), d.size)
            d:SetPoint("TOPLEFT", self, "TOPRIGHT", 5, 0)
            d.initialAnchor = "TOPLEFT"
            d.PostCreateIcon = auraIcon
            d.PostUpdateIcon = PostUpdateIcon
            self.Debuffs = d
	    end
		
		local ph = self.Health:CreateTexture(nil, 'OVERLAY')
        ph:SetSize(24, 24)
        ph:SetPoint('CENTER', self.Health, 'BOTTOMLEFT', 3, -3)
        self.PhaseIcon = ph
    end,
	
	arena = function(self, ...)
		Shared(self, ...)
		
		self:SetSize(cfg.arena_width, cfg.arena_health_height+cfg.arena_power_height+1)
		self.Health:SetHeight(cfg.arena_health_height)
		self.Power:SetHeight(cfg.arena_power_height)
		self.unit = "arena"
		
		if cfg.healcomm then Healcomm(self) end
		
		local name = fs(self.Health, "OVERLAY", cfg.font, cfg.fontsize, cfg.fontflag, 1, 1, 1)
        name:SetPoint("LEFT", self.Health, 4, 0)
        name:SetJustifyH"LEFT"
		if cfg.class_colorbars then
		    self:Tag(name, '[long:name]')
		else
		    self:Tag(name, '[skaarj:color][long:name]')
		end
		
		local htext = fs(self.Health, "OVERLAY", cfg.font, cfg.fontsize, cfg.fontflag, 1, 1, 1)
        htext:SetPoint("RIGHT", self.Health, -2, 0)
		htext.frequentUpdates = true
        self:Tag(htext, '[party:hp]')
		
		local PvP = self.Health:CreateTexture(nil, 'OVERLAY')
        PvP:SetSize(28, 28)
        PvP:SetPoint('BOTTOMLEFT', self.Health, 'TOPRIGHT', -15, -20)
        self.PvP = PvP
		
		local at = CreateFrame('Frame', nil, self)
		at:SetAllPoints(t)
		at:SetFrameStrata('HIGH')
		at.icon = at:CreateTexture(nil, 'ARTWORK')
		at.icon:SetAllPoints(at)
		at.icon:SetTexCoord(0.07,0.93,0.07,0.93)
		at.text = at:CreateFontString(nil, 'OVERLAY', 'NumberFontNormal')
		at.text:SetPoint('CENTER', at, 0, 0)
		at:SetScript('OnUpdate', UpdateAuraTrackerTime)
		self.AuraTracker = at
		
    end,
	
	arenatarget = function(self, ...)
		Shared(self, ...)
		
		self:SetSize(50, cfg.arena_health_height+cfg.arena_power_height+1)
		self.Health:SetHeight(cfg.arena_health_height)
		self.Power:SetHeight(cfg.arena_power_height)
		
		local name = fs(self.Health, "OVERLAY", cfg.font, cfg.fontsize, cfg.fontflag, 1, 1, 1)
        name:SetPoint("CENTER", self.Health)
        name:SetJustifyH"CENTER"
		if cfg.class_colorbars then
		    self:Tag(name, '[veryshort:name]')
		else
		    self:Tag(name, '[skaarj:color][veryshort:name]')
		end	
    end,

    raid = function(self, ...)
		Shared(self, ...)
		
		self.Health:SetHeight(cfg.raid_health_height)
		self.Power:SetHeight(cfg.raid_power_height)
		
		local name = fs(self.Health, "OVERLAY", cfg.font, cfg.fontsize, cfg.fontflag, 1, 1, 1)
		name:SetPoint("LEFT", self.Health, 6, 5)
	    name:SetJustifyH"LEFT"
		if cfg.class_colorbars then
	        self:Tag(name, '[veryshort:name]')
		else
		    self:Tag(name, '[skaarj:color][veryshort:name]')
		end

        local htext = fs(self.Health, "OVERLAY", cfg.font, cfg.fontsize, cfg.fontflag, 1, 1, 1)
        htext:SetPoint("RIGHT", self.Health, 0, -8)
		htext.frequentUpdates = true
        self:Tag(htext, '[skaarj:info]')		
		
		local lfd = fs(self.Health, "OVERLAY", cfg.symbol, 12, "", 1, 1, 1)
		lfd:SetPoint("BOTTOMLEFT", 6, 1)
	    self:Tag(lfd, '[skaarj:LFD]')	
		
		self.RaidIcon:SetSize(14, 14)
	    self.RaidIcon:SetPoint("TOP", self.Health, 2, 7)
		
		if cfg.healcomm then Healcomm(self) end
		
		Resurrect(self)
		createAuraWatch(self)
		
	    if cfg.RaidDebuffs then
	       local d = CreateFrame('Frame', nil, self)
	       d:SetSize(22, 22)
	       d:SetPoint('CENTER', self)
	       d:SetFrameStrata'HIGH'
	       d:SetBackdrop(backdrop_1px)
	       d.icon = d:CreateTexture(nil, 'OVERLAY')
	       d.icon:SetTexCoord(.1,.9,.1,.9)
	       d.icon:SetAllPoints(d)
	       d.time = fs(d, "OVERLAY", cfg.aura_font, cfg.aura_fontsize, cfg.aura_fontflag, 0.8, 0.8, 0.8)
	       d.time:SetPoint('TOPLEFT', d, 'TOPLEFT', 0, 0)
		   d.count = fs(d, "OVERLAY", cfg.aura_font, cfg.aura_fontsize, cfg.aura_fontflag, 0.8, 0.8, 0.8)
	       d.count:SetPoint('BOTTOMRIGHT', d, 'BOTTOMRIGHT', 2, 0)
		   self.RaidDebuffs = d
	    end

		local tborder = CreateFrame("Frame", nil, self)
        tborder:SetPoint("TOPLEFT", self, "TOPLEFT")
        tborder:SetPoint("BOTTOMRIGHT", self, "BOTTOMRIGHT")
        tborder:SetBackdrop(backdrop_1px)
        tborder:SetBackdropColor(.8, .8, .8, 1)
        tborder:SetFrameLevel(1)
        tborder:Hide()
        self.TargetBorder = tborder
		
		local fborder = CreateFrame("Frame", nil, self)
        fborder:SetPoint("TOPLEFT", self, "TOPLEFT")
        fborder:SetPoint("BOTTOMRIGHT", self, "BOTTOMRIGHT")
        fborder:SetBackdrop(backdrop_1px)
        fborder:SetBackdropColor(.6, .8, 0, 1)
        fborder:SetFrameLevel(1)
        fborder:Hide()
        self.FocusHighlight = fborder
	    
		self:RegisterEvent('PLAYER_TARGET_CHANGED', ChangedTarget)
        self:RegisterEvent('RAID_ROSTER_UPDATE', ChangedTarget)
		self:RegisterEvent('PLAYER_FOCUS_CHANGED', FocusTarget)
        self:RegisterEvent('RAID_ROSTER_UPDATE', FocusTarget)
    end,
}

UnitSpecific.focustarget = UnitSpecific.pet
UnitSpecific.maintank = UnitSpecific.party

oUF:RegisterStyle("Skaarj", Shared)

for unit,layout in next, UnitSpecific do
    oUF:RegisterStyle('Skaarj - ' .. unit:gsub("^%l", string.upper), layout)
end

local spawnHelper = function(self, unit, ...)
    if(UnitSpecific[unit]) then
        self:SetActiveStyle('Skaarj - ' .. unit:gsub("^%l", string.upper))
    elseif(UnitSpecific[unit:match('[^%d]+')]) then 
        self:SetActiveStyle('Skaarj - ' .. unit:match('[^%d]+'):gsub("^%l", string.upper))
    else
        self:SetActiveStyle'Skaarj'
    end

    local object = self:Spawn(unit)
    object:SetPoint(...)
    return object
end

oUF:Factory(function(self)

    spawnHelper(self, "player", "CENTER", cfg.unit_positions.Player.x, cfg.unit_positions.Player.y)
    spawnHelper(self, "target", "CENTER", cfg.unit_positions.Target.x, cfg.unit_positions.Target.y)
    spawnHelper(self, "targettarget", "RIGHT", "oUF_SkaarjTarget", cfg.unit_positions.Targettarget.x, cfg.unit_positions.Targettarget.y)
    spawnHelper(self, "focus", "CENTER", cfg.unit_positions.Focus.x, cfg.unit_positions.Focus.y)
    spawnHelper(self, "focustarget", "LEFT", "oUF_SkaarjFocus", cfg.unit_positions.Focustarget.x, cfg.unit_positions.Focustarget.y)
    spawnHelper(self, "pet", "LEFT", "oUF_SkaarjPlayer", cfg.unit_positions.Pet.x, cfg.unit_positions.Pet.y)

    if cfg.boss then
	    for i = 1, MAX_BOSS_FRAMES do
            spawnHelper(self, 'boss' .. i, "RIGHT", cfg.unit_positions.Boss.x, cfg.unit_positions.Boss.y - (52 * i))
        end
    end
	
	if cfg.arena then
		local arena = {}
		local arenatarget = {}
		
		self:SetActiveStyle'Skaarj - Arena'
		for i = 1, 5 do
			arena[i] = self:Spawn("arena"..i, "oUF_Arena"..i)
			if i == 1 then
				arena[i]:SetPoint("RIGHT", UIParent, cfg.unit_positions.Arena.x, cfg.unit_positions.Arena.y)
			else
				arena[i]:SetPoint("TOP", arena[i-1], "BOTTOM", 0, -18)
			end
		end
		
		self:SetActiveStyle'Skaarj - Arenatarget'
		for i = 1, 5 do
			arenatarget[i] = self:Spawn("arena"..i.."target", "oUF_SkaarjArena"..i.."target")
			if i == 1 then
				arenatarget[i]:SetPoint("TOPLEFT", arena[i], "TOPRIGHT", 5, 0)
			else
				arenatarget[i]:SetPoint("TOP", arenatarget[i-1], "BOTTOM", 0, -18)
			end
		end
	end
	
    if cfg.party then
  
        self:SetActiveStyle'Skaarj - Party'
  
        for i = 1, 4 do
			local party = "PartyMemberFrame" .. i
			local frame = _G[party]

			frame:UnregisterAllEvents()
			frame.Show = function() end
			frame:Hide()

			_G[party .. "HealthBar"]:UnregisterAllEvents()
			_G[party .. "ManaBar"]:UnregisterAllEvents()
		end

        local party = self:SpawnHeader('oUF_Party', nil, "custom [@raid6,exists] hide; show" --"custom [@raid6,exists] hide; show"
	    ,'showPlayer',false,'showSolo',false,"showParty",true,"yOffset", -18,--"template", "oUF_Party",
	    'oUF-initialConfigFunction', ([[self:SetWidth(%d) self:SetHeight(%d)]]):format(cfg.party_width, cfg.party_health_height+cfg.party_power_height+1))
        party:SetPoint("LEFT", UIParent, cfg.unit_positions.Party.x, cfg.unit_positions.Party.y)
    end
	
	if cfg.tank then
	
	    self:SetActiveStyle'Skaarj - Maintank'

	    local maintank = self:SpawnHeader('oUF_MainTank', nil, 'raid',
	    'oUF-initialConfigFunction', ([[self:SetWidth(%d) self:SetHeight(%d)]]):format(cfg.party_width, cfg.party_health_height+cfg.party_power_height+1),
	    'showRaid', true,
	    'groupFilter', 'MAINTANK',
	    'yOffset', 20,
	    'point' , 'BOTTOM')
	    maintank:SetPoint("LEFT", UIParent, cfg.unit_positions.Tank.x, cfg.unit_positions.Tank.y)
	end
	
	if cfg.disableRaidFrameManager then
	    CompactRaidFrameManager:UnregisterAllEvents()
        CompactRaidFrameManager:HookScript("OnShow", function(s) s:Hide() end)
        CompactRaidFrameManager:Hide()
    
        CompactRaidFrameContainer:UnregisterAllEvents()
        CompactRaidFrameContainer:HookScript("OnShow", function(s) s:Hide() end)
        CompactRaidFrameContainer:Hide()
    end 
	
	if cfg.raid then
	
	    self:SetActiveStyle'Skaarj - Raid'
	
	    local raid = oUF:SpawnHeader(nil, nil, "custom [@raid6,exists] show; hide", --"custom [@raid6,exists] show; hide"
        'oUF-initialConfigFunction', ([[self:SetWidth(%d) self:SetHeight(%d)]]):format(cfg.raid_width, cfg.raid_health_height+cfg.raid_power_height+1),
        'showPlayer', true,
        'showSolo', false,
        'showParty', false,
        'showRaid', true,
        'xoffset', 5,
        'yOffset', -5,
        'point', "TOP",
        'groupFilter', '1,2,3,4,5,6,7,8',
        'groupingOrder', '1,2,3,4,5,6,7,8',
        'groupBy', 'GROUP',
        'maxColumns', 8,
        'unitsPerColumn', 5,
        'columnSpacing', 5,
        'columnAnchorPoint', "LEFT")
        raid:SetPoint("TOPLEFT", UIParent, "TOPLEFT", cfg.unit_positions.Raid.x, cfg.unit_positions.Raid.y)
	end
end)