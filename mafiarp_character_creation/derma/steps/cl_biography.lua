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
    entry.Paint = self.PaintComboEntry
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

    -- Store custom textures for the slider bar and knob (button)
    local sliderBarTexture = Material("mafiarp/button_black.png") -- Path to your custom slider bar texture
    local sliderKnobTexture = Material("arccw/hud/hit_dot.png") -- Path to your custom slider knob texture

    -- Customize the slider's appearance
    function entry.Slider:Paint(w, h)
        -- Draw the slider bar (background) with custom texture
        surface.SetDrawColor(255, 255, 255, 255) -- White color to retain the original texture color
        surface.SetMaterial(sliderBarTexture)
        surface.DrawTexturedRect(0, h / 2 - 4, w, 8) -- Draw the bar centered vertically

        -- Optionally draw a default background if needed
        -- Example: surface.SetDrawColor(100, 100, 100, 255) -- Grey background if custom bar isn't visible
        -- surface.DrawRect(0, h / 2 - 4, w, 8)
    end

    -- Customize the knob's appearance
    function entry.Slider.Knob:Paint(w, h)
        -- Draw the slider knob with a custom texture
        surface.SetDrawColor(255, 255, 255, 255)
        surface.SetMaterial(sliderKnobTexture)
        surface.DrawTexturedRect(0, 0, w, h) -- Draw knob, adjusting size based on the knob's dimensions
    end

    -- Override the value update function
    entry.OnValueChanged = function(_, value)
        self:SetPayload(payloadName, value)
    end

    return entry
end



function PANEL:InitAdditionalFields()
    -- Gender
    self.genderLabel = self:AddLabel("gender", self.scrollPanel)
    self.genderLabel:SetZPos(6)

    self.gender = self:AddComboEntry("gender", {"Male", "Female", "Other"}, self.scrollPanel)
    self.gender:SetTall(48)
    self.gender:SetZPos(7)

    -- Date of Birth
    self.dobLabel = self:AddLabel("date of birth", self.scrollPanel)
    self.dobLabel:SetZPos(4)

    -- Create a horizontal container for the DOB dropdowns
    local dobContainer = self.scrollPanel:Add("DPanel")
    dobContainer:SetTall(45)
    dobContainer:Dock(TOP)
    dobContainer:DockMargin(0, 4, 0, 16) -- Add some margin around the container
    dobContainer:SetPaintBackground(false) -- Remove the background of the panel
    dobContainer:SetZPos(5) -- Remove the background of the panel

    local containerWidth = self.scrollPanel:GetWide()

    -- Set width percentages for each dropdown
    local dropdownWidth = containerWidth / 3 - 10 -- Subtract a bit for spacing

    -- Create the Month Dropdown
    self.dobMonth = self:AddComboEntry("dob", {}, dobContainer)
    for i = 1, 12 do
        self.dobMonth:AddChoice(string.format("%02d", i))
    end
    self.dobMonth:SetTall(40)
    --self.dobMonth:SetWide(dropdownWidth) -- Adjust width to fit horizontally
    self.dobMonth:Dock(LEFT)
    --self.dobMonth:SetZPos(5)

    -- Create the Day Dropdown
    self.dobDay = self:AddComboEntry("dob", {}, dobContainer)
    for i = 1, 31 do
        self.dobDay:AddChoice(string.format("%02d", i))
    end
    self.dobDay:SetTall(40)
    --self.dobDay:SetWide(dropdownWidth) -- Adjust width
    self.dobDay:Dock(LEFT)
    --self.dobDay:SetZPos(5)


    -- Create the Year Dropdown (1900 - 1971)
    self.dobYear = self:AddComboEntry("dob", {}, dobContainer)
    for i = 1900, 1971 do
        self.dobYear:AddChoice(tostring(i))
    end
    self.dobYear:SetTall(40)
    --self.dobYear:SetWide(dropdownWidth) -- Adjust width
    self.dobYear:Dock(LEFT)
    --self.dobDay:SetZPos(5)


    -- Height
    self.heightLabel = self:AddLabel("height (in)", self.scrollPanel)
    self.heightLabel:SetZPos(8)
    self.heightLabel:SetTall(35)

    self.height = self:AddSliderEntry("height", 48, 81, 0, self.scrollPanel)  -- Min: 100 cm, Max: 250 cm, Decimals: 1
    self.height:SetZPos(9)

    -- Weight
    self.weightLabel = self:AddLabel("weight (lbs)", self.scrollPanel)
    self.weightLabel:SetZPos(10)

    self.weight = self:AddSliderEntry("weight", 80, 300, 0, self.scrollPanel)  -- Min: 30 kg, Max: 200 kg, Decimals: 1
    self.weight:SetZPos(11)

    -- Hair Color
    self.hairColorLabel = self:AddLabel("hair color", self.scrollPanel)
    self.hairColorLabel:SetZPos(12)

    self.hairColor = self:AddComboEntry("hair_color", {"Brown", "Grey", "Black", "Blonde", "Ginger"}, self.scrollPanel)
    self.hairColor:SetTall(48)
    self.hairColor:SetZPos(13)

    -- Eye Color
    self.eyeColorLabel = self:AddLabel("eye color", self.scrollPanel)
    self.eyeColorLabel:SetZPos(14)

    self.eyeColor = self:AddComboEntry("eye_color", {"Brown", "Grey", "Blue", "Green", "Hazel", "Amber", "Red"}, self.scrollPanel)
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

    --DOB STUFF
    -- Populate Date of Birth (parse from "MM/DD/YYYY" payload)
    local dob = self:GetPayload("dob", "01/01/1900")
    local month, day, year = dob:match("(%d%d)/(%d%d)/(%d%d%d%d)")
    
    -- Set the values for the dropdowns
    self.dobMonth:SetValue(month)
    self.dobDay:SetValue(day)
    self.dobYear:SetValue(year)

    self.gender:SetValue(self:GetPayload("gender", ""))
    self.height:SetValue(self:GetPayload("height", 175))  -- Default height: 175 cm
    self.weight:SetValue(self:GetPayload("weight", 70))   -- Default weight: 70 kg
    self.hairColor:SetValue(self:GetPayload("hair_color", ""))
    self.eyeColor:SetValue(self:GetPayload("eye_color", ""))

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


    -- Validate Date of Birth
    local month = self.dobMonth:GetSelected()
    local day = self.dobDay:GetSelected()
    local year = self.dobYear:GetSelected()

    if not (month and day and year) then
        return false, "You must select a valid date of birth."
    end

    -- Combine into "MM/DD/YYYY" format and store in the dob payload
    local dobString = string.format("%02d/%02d/%04d", tonumber(month), tonumber(day), tonumber(year))
    self:SetPayload("dob", dobString)
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

function PANEL:PaintComboEntry(w, h)
    ix.util.DrawBlur(self)
	surface.SetMaterial(Material("mafiarp/faction_gradient_left.png", "noclamp smooth"))
    surface.SetDrawColor(200, 200, 200, 70)
    surface.DrawTexturedRect(0, 0, w, h)
end

vgui.Register("ixCharacterBiography", PANEL, "ixCharacterCreateStep")
