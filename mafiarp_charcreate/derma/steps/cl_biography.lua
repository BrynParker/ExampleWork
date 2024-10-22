local PANEL = {}

local HIGHLIGHT = Color(255, 255, 255, 50)

-- Helper function to capitalize the first letter of a string
local function capitalizeFirstLetter(str)
    return (str:gsub("^%l", string.upper))
end

function PANEL:Init()
    self.scrollPanel = self:Add("DScrollPanel")
    self.scrollPanel:Dock(FILL)


    self.nameLabel = self:AddLabel("name", self.scrollPanel)
    self.nameLabel:SetZPos(0)

    self.name = self:AddTextEntry("name", self.scrollPanel)
    self.name:SetTall(48)
    self.name.onTabPressed = function()
        self.desc:RequestFocus()
    end
    self.name:SetZPos(1)

    self.descLabel = self:AddLabel("description", self.scrollPanel)
    self.descLabel:SetZPos(2)

    self.desc = self:AddTextEntry("description", self.scrollPanel)
    self.desc:SetTall(self.name:GetTall() * 3)
    self.desc.onTabPressed = function()
        self.name:RequestFocus()
    end
    self.desc:SetMultiline(true)
    self.desc:SetZPos(3)

    -- Add additional fields here
    self:InitAdditionalFields()

    self:Register("Background")
end

function PANEL:AddLabel(text, parent)
    local label = parent:Add("DLabel")
    label:Dock(TOP)
    label:SetText(capitalizeFirstLetter(text))
    label:SetFont("ixPluginCharButtonFont")
    label:DockMargin(0, 8, 0, 8) -- Adding margin to prevent cut off
    label:SetTall(24) -- Set height to ensure enough space
    return label
end

function PANEL:AddTextEntry(payloadName, parent)
    local entry = parent:Add("DTextEntry")
    entry:Dock(TOP)
    entry:SetFont("ixPluginCharButtonFont")
    entry.Paint = self.PaintTextEntry
    entry:DockMargin(0, 4, 0, 16)
    entry.OnValueChange = function(_, value)
        self:SetPayload(payloadName, string.Trim(value))
    end
    entry.payloadName = payloadName
    entry.OnKeyCodeTyped = function(name, keyCode)
        if (keyCode == KEY_TAB) then
            entry:onTabPressed()
            return true
        end
    end
    entry:SetUpdateOnType(true)
    return entry
end

function PANEL:AddComboEntry(payloadName, options, parent)
    local entry = parent:Add("DComboBox")
    entry:Dock(TOP)
    entry:SetFont("ixPluginCharButtonFont")
    entry:SetSortItems(false)
    entry:DockMargin(0, 4, 0, 16)
    for _, option in ipairs(options) do
        entry:AddChoice(option)
    end
    entry.OnSelect = function(_, index, value, data)
        self:SetPayload(payloadName, data or value)
    end
    return entry
end

function PANEL:AddSliderEntry(payloadName, min, max, decimals, parent)
    local entry = parent:Add("DNumSlider")
    entry:Dock(TOP)
    entry:SetMin(min)
    entry:SetMax(max)
    entry:SetDecimals(decimals)
    entry:SetText("")
    entry.OnValueChanged = function(_, value)
        self:SetPayload(payloadName, value)
    end
    return entry
end

function PANEL:InitAdditionalFields()
    -- Date of Birth
    self.dobLabel = self:AddLabel("date of birth", self.scrollPanel)
    self.dobLabel:SetZPos(4)

    self.dob = self:AddTextEntry("dob", self.scrollPanel)
    self.dob:SetTall(48)
    self.dob.onTabPressed = function()
        self.name:RequestFocus()
    end
    self.dob:SetZPos(5)
    self.dob.AllowInput = function(s, text)
        local strAllowedNumericCharacters = "1234567890/"
        if not string.find(strAllowedNumericCharacters, text, 1, true) then
            return true
        end
        if string.len(s:GetValue()) >= 10 then
            return true
        end
        return false
    end

    -- Gender
    self.genderLabel = self:AddLabel("gender", self.scrollPanel)
    self.genderLabel:SetZPos(6)

    self.gender = self:AddComboEntry("gender", {"Male", "Female", "Other"}, self.scrollPanel)
    self.gender:SetTall(48)
    self.gender:SetZPos(7)

    -- Height
    self.heightLabel = self:AddLabel("height", self.scrollPanel)
    self.heightLabel:SetZPos(8)
    self.heightLabel:SetTall(35)

    self.height = self:AddSliderEntry("height", 100, 250, 1, self.scrollPanel)  -- Min: 100 cm, Max: 250 cm, Decimals: 1
    self.height:SetZPos(9)

    -- Weight
    self.weightLabel = self:AddLabel("weight", self.scrollPanel)
    self.weightLabel:SetZPos(10)

    self.weight = self:AddSliderEntry("weight", 30, 200, 1, self.scrollPanel)  -- Min: 30 kg, Max: 200 kg, Decimals: 1
    self.weight:SetZPos(11)

    -- Hair Color
    self.hairColorLabel = self:AddLabel("hair color", self.scrollPanel)
    self.hairColorLabel:SetZPos(12)

    self.hairColor = self:AddTextEntry("hair_color", self.scrollPanel)
    self.hairColor:SetTall(48)
    self.hairColor:SetZPos(13)

    -- Eye Color
    self.eyeColorLabel = self:AddLabel("eye color", self.scrollPanel)
    self.eyeColorLabel:SetZPos(14)

    self.eyeColor = self:AddTextEntry("eye_color", self.scrollPanel)
    self.eyeColor:SetTall(48)
    self.eyeColor:SetZPos(15)
end

function PANEL:Display()
    local faction = self:GetPayload("faction")
    local info = ix.faction.indices[faction]
    local default, override

    if (info and info.GetDefaultName) then
        default, override = info:GetDefaultName(LocalPlayer())
    end

    if (override) then
        self:SetPayload("name", default)
        self.nameLabel:SetText(default)
        self.nameLabel:DockMargin(0, 0, 0, 10)
        self.name:SetVisible(false)
    else
        self:SetPayload("name", "")
        self.nameLabel:SetVisible(true)
        self.name:SetVisible(true)
        self.name:SetText(self:GetPayload("name", ""))
    end

    self.desc:SetText(self:GetPayload("description", ""))

    -- Additional fields
    self.dob:SetText(self:GetPayload("dob", ""))
    self.gender:SetValue(self:GetPayload("gender", ""))
    self.height:SetValue(self:GetPayload("height", 175))  -- Default height: 175 cm
    self.weight:SetValue(self:GetPayload("weight", 70))   -- Default weight: 70 kg
    self.hairColor:SetText(self:GetPayload("hair_color", ""))
    self.eyeColor:SetText(self:GetPayload("eye_color", ""))

    -- Delay focus to avoid docking issues
    timer.Simple(0, function()
        if IsValid(self.name) then
            self.name:RequestFocus()
        end
    end)
end

function PANEL:Validate()
    if (self.name:IsVisible()) then
        local res = {self:ValidateCharVar("name")}
        if (res[1] == false) then
            return unpack(res)
        end
    end
    return self:ValidateCharVar("description")
end

-- self refers to the text entry
function PANEL:PaintTextEntry(w, h)
    ix.util.DrawBlur(self)
	surface.SetMaterial(Material("mafiarp/faction_gradient_left.png", "noclamp smooth"))
    surface.SetDrawColor(200, 200, 200, 70)
    surface.DrawTexturedRect(0, 0, w, h)
    self:DrawTextEntryText(color_white, HIGHLIGHT, HIGHLIGHT)
end

vgui.Register("ixCharacterBiography", PANEL, "ixCharacterCreateStep")
