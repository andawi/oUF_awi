 local addon, ns = ...
 local cfg = CreateFrame("Frame")

  -----------------------------
  -- Media
  -----------------------------
  
local mediaPath = "Interface\\AddOns\\Media\\"
cfg.texture = mediaPath.."texture"
cfg.font, cfg.fontsize, cfg.shadowoffsetX, cfg.shadowoffsetY, cfg.fontflag = mediaPath.."pixel.ttf", 8, 0, 0,  "Outlinemonochrome" -- "" for none THINOUTLINE Outlinemonochrome
cfg.symbol = mediaPath.."symbol.ttf"
cfg.buttonTex = mediaPath.."gloss"
cfg.raidIcons = mediaPath.."raidicons"
  
  -----------------------------
  -- Unit Frames 
  -----------------------------
  
cfg.scale = 1  

cfg.party = true
cfg.raid = true
cfg.boss = true
cfg.tank = true
cfg.arena = true
  
--player, target, focus 
cfg.width = 250 
cfg.health_height = 30
cfg.power_height = 3
cfg.specific_power_height = 6
-- raid
cfg.raid_width = 60
cfg.raid_health_height = 30
cfg.raid_power_height = 3
--boss
cfg.boss_width = 170
cfg.boss_health_height = 30
cfg.boss_power_height = 3
--arena
cfg.arena_width = 170
cfg.arena_health_height = 30
cfg.arena_power_height = 3
--party, tank
cfg.party_width = 170
cfg.party_health_height = 30
cfg.party_power_height = 3
--pet, targettarget, focustarget
cfg.pet_width = 90
cfg.pet_height = 30

cfg.disableRaidFrameManager = true
cfg.portraits = false
cfg.healcomm = false
cfg.specific_power = true

cfg.AltPowerBar = true
cfg.AltPowerBar_pos = {'CENTER', UIParent, 0, -295}
cfg.AltPowerBar_Width = 250
cfg.AltPowerBar_Height = 12

-- Unit Frames Positions

 cfg.unit_positions = { 				
             Player = { x= -260, y= -300},  
             Target = { x=	260, y= -300},  
       Targettarget = { x=    0, y=  -65},  
              Focus = { x= -260, y=  100},  
        Focustarget = { x=    0, y=  -65},  
                Pet = { x=	  0, y=  -65},  
               Boss = { x=  -300,y=  250},  
               Tank = { x=	 10, y=  100},  
               Raid = { x=	 10, y=  -10},   
	          Party = { x=	 10, y=  250},
              Arena = { x= -300, y=  250},			  
}

  -----------------------------
  -- Auras 
  -----------------------------
  
cfg.auras = true  -- disable all auras
cfg.border = false
cfg.onlyShowPlayer = false -- only show player debuffs on target
cfg.disableCooldown = true -- hide omniCC
cfg.aura_font, cfg.aura_fontsize, cfg.aura_fontflag = mediaPath.."pixel.ttf", 8, "Outlinemonochrome" 
cfg.player_debuffs_num = 18
cfg.target_debuffs_num = 18
cfg.target_buffs_num = 8

  -----------------------------
  -- Plugins 
  -----------------------------
  
cfg.SpellRange = true
cfg.TotemBar = false
cfg.Smooth = true
cfg.DruidMana = true
cfg.AuraBars = false

--Threat
cfg.TreatBar = true 
cfg.TreatBar_pos = {'CENTER', UIParent, 0, -311}
cfg.TreatBar_Width = 250
cfg.TreatBar_Height = 12

--Experience/Reputation
cfg.Bar = true 
cfg.Bar_pos_x = 0
cfg.Bar_pos_y = -8
cfg.Bar_Width = 250
cfg.Bar_Height = 7

--GCD
cfg.gcd = true
cfg.gcd_pos = {'BOTTOM', UIParent, 0, 200}
cfg.gcd_Width = 229
cfg.gcd_Height = 12

 --RaidDebuffs
cfg.RaidDebuffs = true
cfg.ShowDispelableDebuff = true
cfg.FilterDispellableDebuff = true 
cfg.MatchBySpellName = false

--DebuffHighlight
cfg.DebuffHighlight = true
cfg.DebuffHighlightFilter = true

--AuraWatch
 cfg.showAuraWatch = true
 cfg.onlyShowPresent = true
 cfg.anyUnit = true
 
cfg.spellIDs = {
	DRUID = {
	{94447, {0.2, 0.8, 0.2}},			    -- Lifebloom
	{8936, {0.8, 0.4, 0}, "TOPLEFT"},			-- Regrowth
	{102342, {0.38, 0.22, 0.1}},		    -- Ironbark
	{48438, {0.4, 0.8, 0.2}, "BOTTOMLEFT"},	-- Wild Growth
	{774, {0.8, 0.4, 0.8},"TOPRIGHT"},		-- Rejuvenation
	},
	MONK = {
	{119611, {0.2, 0.7, 0.7}},			-- Renewing Mist
	{124682, {0.4, 0.8, 0.2}},			-- Enveloping Mist
	{124081, {0.7, 0.4, 0}},			-- Zen Sphere
	{116849, {0.81, 0.85, 0.1}},		-- Life Cocoon
	},
	PALADIN = {
	{20925, {0.9, 0.9, 0.1}},	            -- Sacred Shield
	{6940, {0.89, 0.1, 0.1}, "BOTTOMLEFT"}, -- Hand of Sacrifice
	{114039, {0.4, 0.6, 0.8}, "BOTTOMLEFT"},-- Hand of Purity
	{1022, {0.2, 0.2, 1}, "BOTTOMLEFT"},	-- Hand of Protection
	{1038, {0.93, 0.75, 0}, "BOTTOMLEFT"},  -- Hand of Salvation
	{1044, {0.89, 0.45, 0}, "BOTTOMLEFT"},  -- Hand of Freedom
	{114163, {0.9, 0.6, 0.4}, "RIGHT"},	    -- Eternal Flame
	{53563, {0.7, 0.3, 0.7}, "TOPRIGHT"},   -- Beacon of Light
	},
	PRIEST = {
	{33076, {0.2, 0.7, 0.2}},			-- Prayer of Mending
	{33206, {0.89, 0.1, 0.1}},			-- Pain Suppress
	{47788, {0.86, 0.52, 0}},			-- Guardian Spirit
	{6788, {1, 0, 0}, "BOTTOMLEFT"},	-- Weakened Soul
	{17, {0.81, 0.85, 0.1}, "TOPLEFT"},	-- Power Word: Shield
	{139, {0.4, 0.7, 0.2}, "TOPRIGHT"}, -- Renew
	},
	SHAMAN = {
	{974, {0.2, 0.7, 0.2}},				  -- Earth Shield
	{61295, {0.7, 0.3, 0.7}, "TOPRIGHT"}, -- Riptide
	{51945, {0.7, 0.4, 0}, "TOPLEFT"},	  -- Earthliving
	},
	DEATHKNIGHT = {
	{49016, {0.89, 0.89, 0.1}},			-- Unholy Frenzy
	},
	HUNTER = {
	{34477, {0.2, 0.2, 1}},				-- Misdirection
	},
	MAGE = {
	{111264, {0.2, 0.2, 1}},			-- Ice Ward
	},
	ROGUE = {
	{57933, {0.89, 0.1, 0.1}},			-- Tricks of the Trade
	},
	WARLOCK = {
	{20707, {0.7, 0.32, 0.75}},			-- Soulstone
	},
	WARRIOR = {
	{114030, {0.2, 0.2, 1}},			  -- Vigilance
	{3411, {0.89, 0.1, 0.1}, "TOPRIGHT"}, -- Intervene
	},
 }
 
  -----------------------------
  -- Castbars 
  -----------------------------

-- Player

cfg.player_castbar = true
cfg.player_cb_pos = {"BOTTOM", UIParent, 15, 155}
cfg.player_cb_Width = 235
cfg.player_cb_Height = 25

-- Target

cfg.target_castbar = true
cfg.target_cb_pos_x = 0
cfg.target_cb_pos_y = -8
cfg.target_cb_Height = 16
cfg.target_cb_Width = (cfg.width - (cfg.target_cb_Height + 3))

-- Focus

cfg.focus_castbar = true
cfg.focus_cb_pos_x = 0
cfg.focus_cb_pos_y = -8
cfg.focus_cb_Height = 16
cfg.focus_cb_Width = (cfg.width - (cfg.focus_cb_Height + 3))


-- Boss

cfg.boss_castbar = true
cfg.boss_cb_pos_x = 0
cfg.boss_cb_pos_y = -1
cfg.boss_cb_Height = 16
cfg.boss_cb_Width = (cfg.boss_width - (cfg.boss_cb_Height + 3))

-- Party

cfg.party_castbar = true
cfg.party_cb_pos_x = 0
cfg.party_cb_pos_y = -1
cfg.party_cb_Height = 16
cfg.party_cb_Width = (cfg.party_width - (cfg.party_cb_Height + 3))

-- Arena

cfg.arena_castbar = true
cfg.arena_cb_pos_x = 0
cfg.arena_cb_pos_y = -1
cfg.arena_cb_Height = 16
cfg.arena_cb_Width = ((cfg.arena_width+cfg.arena_health_height+cfg.arena_power_height+1+3) - (cfg.arena_cb_Height + 3))


  -----------------------------
  -- Colors 
  -----------------------------
  
cfg.class_colorbars = false
  
  cfg.Color = { 				
       Health = {r =  0.3,	g =  0.3, 	b =  0.3},
	  Castbar = {r =  0,	g =  0.7, 	b =  1  },
		  GCD = {r =  0.55,	g =  0.57, 	b =  0.61},
  }

  -----------------------------
  -- Handover
  -----------------------------
  
ns.cfg = cfg