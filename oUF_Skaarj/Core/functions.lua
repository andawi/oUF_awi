local name, ns = ...
local cfg = ns.cfg

-----------------------------------------------------------------------------------------

framebd = function(parent, anchor) 
    local frame = CreateFrame("Frame", nil, parent)
    frame:SetFrameStrata("BACKGROUND")
    frame:SetPoint("TOPLEFT", anchor, "TOPLEFT", -4, 4)
    frame:SetPoint("BOTTOMRIGHT", anchor, "BOTTOMRIGHT", 4, -4)
    frame:SetBackdrop({
    edgeFile = "Interface\\AddOns\\Media\\glowTex", edgeSize = 5,
    bgFile = [=[Interface\ChatFrame\ChatFrameBackground]=],
    insets = {left = 3, right = 3, top = 3, bottom = 3}})
    frame:SetBackdropColor(.05, .05, .05)
    frame:SetBackdropBorderColor(0, 0, 0)
    return frame
end

-----------------------------------------------------------------------------------------

local fixStatusbar = function(bar)
    bar:GetStatusBarTexture():SetHorizTile(false)
    bar:GetStatusBarTexture():SetVertTile(false)
end

createStatusbar = function(parent, tex, layer, height, width, r, g, b, alpha)
    local bar = CreateFrame"StatusBar"
    bar:SetParent(parent)
    if height then
        bar:SetHeight(height)
    end
    if width then
        bar:SetWidth(width)
    end
    bar:SetStatusBarTexture(tex, layer)
    bar:SetStatusBarColor(r, g, b, alpha)
    fixStatusbar(bar)
    return bar
end

-----------------------------------------------------------------------------------------

fs = function(parent, layer, font, fontsiz, outline, r, g, b, justify)
    local string = parent:CreateFontString(nil, layer)
    string:SetFont(font, fontsiz, outline)
    string:SetShadowOffset(cfg.shadowoffsetX, cfg.shadowoffsetY)
    string:SetTextColor(r, g, b)
    if justify then
        string:SetJustifyH(justify)
    end
    return string
end