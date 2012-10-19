local sValue = function(val)
	if (val >= 1e6) then
        return ("%.fm"):format(val / 1e6)
    elseif (val >= 1e3) then
        return ("%.fk"):format(val / 1e3)
    else
        return ("%d"):format(val)
    end
end

local function utf8sub(string, i, dots)
  local bytes = string:len()
  if bytes <= i then
    return string
  else
    local len, pos = 0, 1
    while pos <= bytes do
      len = len + 1
      local c = string:byte(pos)
      if c > 0 and c <= 127 then
        pos = pos + 1
      elseif c >= 194 and c <= 223 then
        pos = pos + 2
      elseif c >= 224 and c <= 239 then
        pos = pos + 3
      elseif c >= 240 and c <= 244 then
        pos = pos + 4
      end
      if len == i then break end
    end

    if len == i and pos <= bytes then
      return string:sub(1, pos - 1)..(dots and "..." or "")
    else
      return string
    end
  end
end	

local function hex(r, g, b)
    if not r then return "|cffFFFFFF" end

    if(type(r) == 'table') then
        if(r.r) then r, g, b = r.r, r.g, r.b else r, g, b = unpack(r) end
    end
    return ('|cff%02x%02x%02x'):format(r * 255, g * 255, b * 255)
end

oUF.colors.power['MANA'] = {.31,.45,.63}
oUF.colors.power['RAGE'] = {.69,.31,.31}

oUF.Tags.Methods['skaarj:lvl'] = function(u) 
    local level = UnitLevel(u)
    local typ = UnitClassification(u)
    local color = GetQuestDifficultyColor(level)
	
	if level == MAX_PLAYER_LEVEL then
       return nil
    end

    if level <= 0 then
        level = "??" 
    end

    if typ=="rareelite" then
        return hex(color)..level..'r+'
    elseif typ=="elite" then
        return hex(color)..level..'+'
    elseif typ=="rare" then
        return hex(color)..level..'r'
    else
        return hex(color)..level
    end
end

oUF.Tags.Methods['skaarj:hp']  = function(u) 
    local min, max = UnitHealth(u), UnitHealthMax(u)
    if UnitIsDead(u) then
        return "|cff559655 Dead|r"
    elseif UnitIsGhost(u) then
        return "|cff559655 Ghost|r"
    elseif not UnitIsConnected(u) then
        return "|cff559655 D/C|r"	
	elseif(min<max) then
    return ('|cffAF5050'..sValue(min)).." | "..math.floor(min/max*100+.5).."%"
	else
	return ('|cff559655'..sValue(min))
	end
end
oUF.Tags.Events['skaarj:hp'] = 'UNIT_HEALTH'

oUF.Tags.Methods['skaarj:pp'] = function(u)
    local power = UnitPower(u)
	if UnitIsDead(u) or UnitIsGhost(u) or not UnitIsConnected(u) then
        return nil
    elseif power > 0 then
	local _, str, r, g, b = UnitPowerType(u)
        local t = oUF.colors.power[str]

        if t then
            r, g, b = t[1], t[2], t[3]
        end
        return ('|cff559655 || ')..hex(r, g, b)..sValue(power)
    else 
	sValue(power)
    end
end
oUF.Tags.Events['skaarj:pp'] = 'UNIT_POWER'

oUF.Tags.Methods['skaarj:color'] = function(u, r)
    local reaction = UnitReaction(u, "player")
    if (UnitIsTapped(u) and not UnitIsTappedByPlayer(u)) then
        return hex(oUF.colors.tapped)
    elseif (UnitIsPlayer(u)) then
        local _, class = UnitClass(u)
        return hex(oUF.colors.class[class])
    elseif reaction then
        return hex(oUF.colors.reaction[reaction])
    else
        return hex(1, 1, 1)
    end
end
oUF.Tags.Events['skaarj:color'] = 'UNIT_REACTION UNIT_HEALTH'

oUF.Tags.Methods['long:name'] = function(u, r)
    local name = UnitName(realUnit or u or r)
    return utf8sub(name, 15, false)
end
oUF.Tags.Events['long:name'] = 'UNIT_NAME_UPDATE'

oUF.Tags.Methods['short:name'] = function(u, r)
    local name = UnitName(realUnit or u or r)
    return utf8sub(name, 10, false)
end
oUF.Tags.Events['short:name'] = 'UNIT_NAME_UPDATE'

oUF.Tags.Methods['veryshort:name'] = function(u, r)
    local name = UnitName(realUnit or u or r)
    return utf8sub(name, 5, false)
end
oUF.Tags.Events['veryshort:name'] = 'UNIT_NAME_UPDATE'

oUF.Tags.Methods['skaarj:info'] = function(u)
    if UnitIsDead(u) then
        return "|cff559655 Dead|r"
    elseif UnitIsGhost(u) then
        return "|cff559655 Ghost|r"
    elseif not UnitIsConnected(u) then
        return "|cff559655 D/C|r"
    end
end
oUF.Tags.Events['skaarj:info'] = 'UNIT_HEALTH'


oUF.Tags.Methods['party:hp']  = function(u) 
    local min, max = UnitHealth(u), UnitHealthMax(u)
	if UnitIsDead(u) then
        return "|cff559655 Dead|r"
    elseif UnitIsGhost(u) then
        return "|cff559655 Ghost|r"
    elseif not UnitIsConnected(u) then
        return "|cff559655 D/C|r"
	else	
    return ('|cff559655'..math.floor(min/max*100+.5).."%")
	end
end
oUF.Tags.Events['party:hp'] = 'UNIT_HEALTH'

oUF.Tags.Methods['skaarj:altpower'] = function(u)
	local cur = UnitPower(u, ALTERNATE_POWER_INDEX)
	local max = UnitPowerMax(u, ALTERNATE_POWER_INDEX)
    local per = floor(cur/max*100)
    return format("%s%%", per > 0 and per or 0)
end
oUF.Tags.Events['skaarj:altpower'] = "UNIT_POWER UNIT_MAXPOWER"

oUF.Tags.Methods['skaarj:demonik_fury'] = function(u)
    local spec = GetSpecialization()
	local power = UnitPower('player', SPELL_POWER_DEMONIC_FURY)
	if spec == SPEC_WARLOCK_DEMONOLOGY then
	return sValue(power)
	else return nil end
end
oUF.Tags.Events['skaarj:demonik_fury'] = "UNIT_POWER PLAYER_SPECIALIZATION_CHANGED PLAYER_TALENT_UPDATE"

oUF.Tags.Methods['skaarj:LFD'] = function(u)
	local role = UnitGroupRolesAssigned(u)
	if role == "HEALER" then
		return "|cff8AFF30H|r"
	elseif role == "TANK" then
		return "|cff5F9BFFT|r"
	elseif role == "DAMAGER" then
		return "|cffFF6161D|r"
	end
end
oUF.Tags.Events['skaarj:LFD'] = 'PLAYER_ROLES_ASSIGNED PARTY_MEMBERS_CHANGED'

oUF.Tags.Methods['skaarj:EclipseDirection'] = function(u)
    local direction = GetEclipseDirection()
	if direction == "sun" then
		return "|cff4478BC>>|r"
	elseif direction == "moon" then
		return "|cffE5994C<<|r"
	end
end
oUF.Tags.Events['skaarj:EclipseDirection'] = "UNIT_POWER ECLIPSE_DIRECTION_CHANGE"