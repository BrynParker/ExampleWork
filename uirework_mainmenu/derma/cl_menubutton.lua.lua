
local buttonPadding = ScreenScale(14) * 0.5
local animationTime = 0.5
local gradup = surface.GetTextureID("vgui/gradient_up")
local icons = {
	Material("trex/new.png", "noclamp smooth"),
	Material("trex/chars.png", "noclamp smooth"),
	Material("trex/scp.png", "noclamp smooth"),
	Material("trex/info.png", "noclamp smooth"),
	Material("trex/exit.png", "noclamp smooth"),
	Material("trex/verifier.png", "noclamp smooth"),
	Material("trex/trash.png", "noclamp smooth"),
	Material("trex/return.png", "noclamp smooth"),
}
-- base menu button
DEFINE_BASECLASS("DButton")
local PANEL = {}

AccessorFunc(PANEL, "backgroundColor", "BackgroundColor")
AccessorFunc(PANEL, "backgroundAlpha", "BackgroundAlpha")

function PANEL:Init()
	self:SetFont("xpgui_big")
	self:SetTextColor(Color(255,255,255,100))
	self:SetPaintBackground(false)
	self:SetContentAlignment(5)
	self:SetTextInset(buttonPadding, 0)
    self.paintW = 0
	self.paintH = 0

	self.padding = {10, 10, 10, 10} -- left, top, right, bottom
	self.backgroundColor = Color(0, 0, 0)
	self.backgroundAlpha = 128
	self.currentBackgroundAlpha = 0
end

function PANEL:GetPadding()
	return self.padding
end

function PANEL:SetPadding(left, top, right, bottom)
	self.padding = {
		left or self.padding[1],
		top or self.padding[2],
		right or self.padding[3],
		bottom or self.padding[4]
	}
end
 
function PANEL:SetText(text, noTranslation)
	BaseClass.SetText(self, noTranslation and text:utf8upper() or L(text):utf8upper())
end

function PANEL:PaintBackground(width, height)

end

-- Initialisez une variable pour suivre l'état de l'animation
local animationProgress = 0

function PANEL:Paint(width, height)
	if self.Hovered or self.selected then
		self.paintW = Lerp(FrameTime() * 5, self.paintW, width)
		self.paintH = Lerp(FrameTime() * 5, self.paintH, height)
	else
		self.paintW = Lerp(FrameTime() * 5, self.paintW, 0)
		self.paintH = Lerp(FrameTime() * 5, self.paintH, 0)
	end
	local startX = (width - self.paintW) * 0.5 
	
	surface.SetDrawColor(Color(29, 49, 58,150))
	surface.DrawRect(0,height - self.paintH,width,self.paintH)

	surface.SetDrawColor(Color(51, 46, 146))
	surface.DrawRect(startX, 60, self.paintW, 1)
end


function PANEL:SetTextColorInternal(color)
	BaseClass.SetTextColor(self, color)
	self:SetFGColor(color)
end

function PANEL:SetTextColor(color)
	self:SetTextColorInternal(color)
	self.color = color
end

function PANEL:SetDisabled(bValue)
	local color = self.color

	if (bValue) then
		self:SetTextColorInternal(Color(math.max(color.r - 60, 0), math.max(color.g - 60, 0), math.max(color.b - 60, 0)))
	else
		self:SetTextColorInternal(color)
	end

	BaseClass.SetDisabled(self, bValue)
end

function PANEL:OnCursorEntered()
	if (self:GetDisabled()) then
		return
	end

	local color = self:GetTextColor()
	self:SetTextColorInternal(Color(math.max(color.r - 25, 0), math.max(color.g - 25, 0), math.max(color.b - 25, 0)))

	self:CreateAnimation(1, {
		target = {currentBackgroundAlpha = self.backgroundAlpha}
	})

	LocalPlayer():EmitSound("Helix.Rollover")
end

function PANEL:OnCursorExited()
	if (self:GetDisabled()) then
		return
	end

	if (self.color) then
		self:SetTextColor(self.color)
	else
		self:SetTextColor(color_white)
	end

	self:CreateAnimation(0.15, {
		target = {currentBackgroundAlpha = 0}
	})
end

function PANEL:OnMousePressed(code)
	if (self:GetDisabled()) then
		return
	end

	if (self.color) then
		self:SetTextColor(self.color)
	else
		self:SetTextColor(ix.config.Get("color"))
	end

	LocalPlayer():EmitSound("Helix.Press")

	if (code == MOUSE_LEFT and self.DoClick) then
		self:DoClick(self)
	elseif (code == MOUSE_RIGHT and self.DoRightClick) then
		self:DoRightClick(self)
	end
end

function PANEL:OnMouseReleased(key)
	if (self:GetDisabled()) then
		return
	end

	if (self.color) then
		self:SetTextColor(self.color)
	else
		self:SetTextColor(color_white)
	end
end

vgui.Register("ixButtonTrex", PANEL, "DButton")

-- selection menu button
DEFINE_BASECLASS("ixButtonTrex")
PANEL = {}

AccessorFunc(PANEL, "backgroundColor", "BackgroundColor")
AccessorFunc(PANEL, "selected", "Selected", FORCE_BOOL)
AccessorFunc(PANEL, "buttonList", "ButtonList")

function PANEL:Init()
	self.backgroundColor = color_white
	self.selected = false
	self.buttonList = {}
	self.sectionPanel = nil -- sub-sections this button has; created only if it has any sections
end

function PANEL:PaintBackground(width, height)
	local alpha = self.selected and 75 or self.currentBackgroundAlpha


	derma.SkinFunc("DrawImportantBackground", 0, 0, 65, 65, ColorAlpha(self.backgroundColor, alpha))
end

function PANEL:SetSelected(bValue, bSelectedSection)
	self.selected = bValue

	if (bValue) then
		self:OnSelected()

		if (self.sectionPanel) then
			self.sectionPanel:Show()
		elseif (self.sectionParent) then
			self.sectionParent.sectionPanel:Show()
		end
	elseif (self.sectionPanel and self.sectionPanel:IsVisible() and !bSelectedSection) then
		self.sectionPanel:Hide()
	end
end

function PANEL:SetButtonList(list, bNoAdd)
	if (!bNoAdd) then
		list[#list + 1] = self
	end

	self.buttonList = list
end

function PANEL:GetSectionPanel()
	return self.sectionPanel
end

function PANEL:AddSection(name)
	if (!IsValid(self.sectionPanel)) then
		-- add section panel to regular button list
		self.sectionPanel = vgui.Create("ixMenuSelectionList", self:GetParent())
		self.sectionPanel:Dock(self:GetDock())
		self.sectionPanel:SetParentButton(self)
	end

	return self.sectionPanel:AddButton(name, self.buttonList)
end

function PANEL:OnMousePressed(key)
	for _, v in pairs(self.buttonList) do
		if (IsValid(v) and v != self) then
			v:SetSelected(false, self.sectionParent == v)
		end
	end

	self:SetSelected(true)
	BaseClass.OnMousePressed(self, key)
end

function PANEL:OnSelected()
end

vgui.Register("ixMenuSelectionButtonTrex", PANEL, "ixButtonTrex")

DEFINE_BASECLASS("ixButtonTrex")
PANEL = {}

AccessorFunc(PANEL, "backgroundColor", "BackgroundColor")
AccessorFunc(PANEL, "selected", "Selected", FORCE_BOOL)
AccessorFunc(PANEL, "buttonList", "ButtonList")

function PANEL:Init()
	self.backgroundColor = color_white
	self.selected = false
	self.buttonList = {}
	self.sectionPanel = nil -- sub-sections this button has; created only if it has any sections
	self.icon = 0
	self.paintW = 0
	self.paintH = 0
end

function PANEL:PaintBackground(width, height)
	local alpha = self.selected and 75 or self.currentBackgroundAlpha


	derma.SkinFunc("DrawImportantBackground", 0, 0, 65, 65, ColorAlpha(self.backgroundColor, alpha))
end

function PANEL:SetSelected(bValue, bSelectedSection)
	self.selected = bValue

	if (bValue) then
		self:OnSelected()

		if (self.sectionPanel) then
			self.sectionPanel:Show()
		elseif (self.sectionParent) then
			self.sectionParent.sectionPanel:Show()
		end
	elseif (self.sectionPanel and self.sectionPanel:IsVisible() and !bSelectedSection) then
		self.sectionPanel:Hide()
	end
end

function PANEL:SetButtonList(list, bNoAdd)
	if (!bNoAdd) then
		list[#list + 1] = self
	end

	self.buttonList = list
end

function PANEL:GetSectionPanel()
	return self.sectionPanel
end

function PANEL:AddSection(name)
	if (!IsValid(self.sectionPanel)) then
		-- add section panel to regular button list
		self.sectionPanel = vgui.Create("ixMenuSelectionList", self:GetParent())
		self.sectionPanel:Dock(self:GetDock())
		self.sectionPanel:SetParentButton(self)
	end

	return self.sectionPanel:AddButton(name, self.buttonList)
end

function PANEL:SetIcon(ico)
	self.icon = math.Clamp(ico, 0, #icons)
end

function PANEL:Paint(width, height)
	if self.Hovered then
		self.paintW = Lerp(FrameTime() * 5, self.paintW, width)
		self.paintH = Lerp(FrameTime() * 5, self.paintH, height)
	else
		self.paintW = Lerp(FrameTime() * 5, self.paintW, 0)
		self.paintH = Lerp(FrameTime() * 5, self.paintH, 0)
	end
	local startX = (width - self.paintW) * 0.5 
	
	surface.SetDrawColor(Color(29, 49, 58 ,150))
	surface.DrawRect(0,height - self.paintH,width,self.paintH)

	surface.SetDrawColor(Color(29, 49, 100))
	surface.DrawRect(startX, 60, self.paintW, 1)

	if self.icon > 0 then
		surface.SetDrawColor(color_white)
		surface.SetMaterial(icons[self.icon])
		surface.DrawTexturedRect(4.5, height / 2 - 16, 32, 32)
	end
end

function PANEL:OnMousePressed(key)
	for _, v in pairs(self.buttonList) do
		if (IsValid(v) and v != self) then
			v:SetSelected(false, self.sectionParent == v)
		end
	end

	self:SetSelected(true)
	BaseClass.OnMousePressed(self, key)
end

function PANEL:OnSelected()
end

vgui.Register("ixMainMenuSelectionButtonTrex", PANEL, "ixButtonTrex")

DEFINE_BASECLASS("ixButtonTrex")
PANEL = {}

AccessorFunc(PANEL, "backgroundColor", "BackgroundColor")
AccessorFunc(PANEL, "selected", "Selected", FORCE_BOOL)
AccessorFunc(PANEL, "buttonList", "ButtonList")

function PANEL:Init()
	self.backgroundColor = color_white
	self.selected = false
	self.buttonList = {}
	self.sectionPanel = nil -- sub-sections this button has; created only if it has any sections
	self.icon = 0
	self.paintW = 0
	self.paintH = 0
end

function PANEL:PaintBackground(width, height)
	local alpha = self.selected and 75 or self.currentBackgroundAlpha


	derma.SkinFunc("DrawImportantBackground", 0, 0, 65, 65, ColorAlpha(self.backgroundColor, alpha))
end

function PANEL:SetSelected(bValue, bSelectedSection)
	self.selected = bValue

	if (bValue) then
		self:OnSelected()

		if (self.sectionPanel) then
			self.sectionPanel:Show()
		elseif (self.sectionParent) then
			self.sectionParent.sectionPanel:Show()
		end
	elseif (self.sectionPanel and self.sectionPanel:IsVisible() and !bSelectedSection) then
		self.sectionPanel:Hide()
	end
end

function PANEL:SetButtonList(list, bNoAdd)
	if (!bNoAdd) then
		list[#list + 1] = self
	end

	self.buttonList = list
end

function PANEL:GetSectionPanel()
	return self.sectionPanel
end

function PANEL:AddSection(name)
	if (!IsValid(self.sectionPanel)) then
		-- add section panel to regular button list
		self.sectionPanel = vgui.Create("ixMenuSelectionList", self:GetParent())
		self.sectionPanel:Dock(self:GetDock())
		self.sectionPanel:SetParentButton(self)
	end

	return self.sectionPanel:AddButton(name, self.buttonList)
end

function PANEL:SetIcon(ico)
	self.icon = math.Clamp(ico, 0, #icons)
end

function PANEL:Paint(width, height)
	if self.Hovered then
		self.paintW = Lerp(FrameTime() * 5, self.paintW, width)
		self.paintH = Lerp(FrameTime() * 5, self.paintH, height)
	else
		self.paintW = Lerp(FrameTime() * 5, self.paintW, 0)
		self.paintH = Lerp(FrameTime() * 5, self.paintH, 0)
	end
	local startX = (width - self.paintW) * 0.5 
	
	surface.SetDrawColor(Color(136, 0, 0,150))
	surface.DrawRect(0,height - self.paintH,width,self.paintH)

	surface.SetDrawColor(Color(180, 0, 0))
	surface.DrawRect(startX, 60, self.paintW, 1)

	if self.icon > 0 then
		surface.SetDrawColor(color_white)
		surface.SetMaterial(icons[self.icon])
		surface.DrawTexturedRect(8, height / 2 - 16, 32, 32)
	end
end

function PANEL:OnMousePressed(key)
	for _, v in pairs(self.buttonList) do
		if (IsValid(v) and v != self) then
			v:SetSelected(false, self.sectionParent == v)
		end
	end

	self:SetSelected(true)
	BaseClass.OnMousePressed(self, key)
end

function PANEL:OnSelected()
end

vgui.Register("ixMainMenuLeaveButtonTrex", PANEL, "ixButtonTrex")

-- selection menu button
DEFINE_BASECLASS("ixButtonTrex")
PANEL = {}

AccessorFunc(PANEL, "backgroundColor", "BackgroundColor")
AccessorFunc(PANEL, "selected", "Selected", FORCE_BOOL)
AccessorFunc(PANEL, "buttonList", "ButtonList")

function PANEL:Init()
	self.backgroundColor = color_white
	self.selected = false
	self.buttonList = {}
	self.sectionPanel = nil -- sub-sections this button has; created only if it has any sections
	self.paintW = 0
	self.paintH = 0
end

function PANEL:PaintBackground(width, height)
	local alpha = self.selected and 75 or self.currentBackgroundAlpha


	derma.SkinFunc("DrawImportantBackground", 0, 0, 65, 65, ColorAlpha(self.backgroundColor, alpha))
end

function PANEL:SetSelected(bValue, bSelectedSection)
	self.selected = bValue

	if (bValue) then
		self:OnSelected()

		if (self.sectionPanel) then
			self.sectionPanel:Show()
		elseif (self.sectionParent) then
			self.sectionParent.sectionPanel:Show()
		end
	elseif (self.sectionPanel and self.sectionPanel:IsVisible() and !bSelectedSection) then
		self.sectionPanel:Hide()
	end
end

function PANEL:SetButtonList(list, bNoAdd)
	if (!bNoAdd) then
		list[#list + 1] = self
	end

	self.buttonList = list
end

function PANEL:GetSectionPanel()
	return self.sectionPanel
end

function PANEL:AddSection(name)
	if (!IsValid(self.sectionPanel)) then
		-- add section panel to regular button list
		self.sectionPanel = vgui.Create("ixMenuSelectionList", self:GetParent())
		self.sectionPanel:Dock(self:GetDock())
		self.sectionPanel:SetParentButton(self)
	end

	return self.sectionPanel:AddButton(name, self.buttonList)
end

function PANEL:Paint(width, height)
	if self.Hovered then
		self.paintW = Lerp(FrameTime() * 5, self.paintW, width)
		self:SetTextColor(Color(120,120,120))
		self:SetTextColor(color_white)
	else
		self.paintW = Lerp(FrameTime() * 5, self.paintW, 0)
		self:SetTextColor(color_white)
	end
	
	local startX = (width - self.paintW) * 0.5 
	
	surface.SetDrawColor(Color(120,120,120,150))
	surface.DrawRect(startX, 0, self.paintW, height)

	surface.SetDrawColor(color_white)
	surface.DrawOutlinedRect(0,0,width,height,2)
end

function PANEL:OnMousePressed(key)
	for _, v in pairs(self.buttonList) do
		if (IsValid(v) and v != self) then
			v:SetSelected(false, self.sectionParent == v)
		end
	end

	self:SetSelected(true)
	BaseClass.OnMousePressed(self, key)
end

function PANEL:OnSelected()
end

vgui.Register("ixMenuCreationButtonTrex", PANEL, "ixButtonTrex")



local animationTime = 0.5

-- selection menu button
DEFINE_BASECLASS("ixMenuButton")
PANEL = {}

AccessorFunc(PANEL, "backgroundColor", "BackgroundColor")
AccessorFunc(PANEL, "selected", "Selected", FORCE_BOOL)
AccessorFunc(PANEL, "buttonList", "ButtonList")

function PANEL:Init()
	self:DockMargin(0, 0, 0, 0)
	self.backgroundColor = Color(0, 0, 0)
	self.backgroundAlpha = 128
	self.currentBackgroundAlpha = 0
	self.selected = false
	self.buttonList = {}
	self.sectionPanel = nil -- sub-sections this button has; created only if it has any sections
end

local gradient = surface.GetTextureID("vgui/gradient-u")
function PANEL:PaintBackground(width, height)

	if self.Hovered or self.selected then
		color2 = Color(80, 80, 80, 200)
	else
		color2 = Color(30,30,30,100)
	end

	draw.RoundedBoxEx(8 , 0, 0, width , height,color2,false,false ,false,false)
	if self.iconMaterial then
        surface.SetMaterial(self.iconMaterial)
        surface.SetDrawColor(ix.config.Get("color"))
        surface.DrawTexturedRect(5, 5, width - 10, height - 10)
	end
end


function PANEL:SetSelected(bValue, bSelectedSection)
	self.selected = bValue

	if (bValue) then
		self:OnSelected()
		if (self.sectionPanel) then
			self.sectionPanel:Show()
		elseif (self.sectionParent) then
			self.sectionParent.sectionPanel:Show()
		end
	elseif (self.sectionPanel and self.sectionPanel:IsVisible() and !bSelectedSection) then
		self.sectionPanel:Hide()
	end
end

function PANEL:SetButtonList(list, bNoAdd)
	if (!bNoAdd) then
		list[#list + 1] = self
	end

	self.buttonList = list
end

function PANEL:GetSectionPanel()
	return self.sectionPanel
end

function PANEL:AddSection(name)
	if (!IsValid(self.sectionPanel)) then
		-- add section panel to regular button list
		self.sectionPanel = vgui.Create("ixMenuSelectionListTop", self:GetParent())
		self.sectionPanel:Dock(self:GetDock())
		self.sectionPanel:SetParentButton(self)
	end

	return self.sectionPanel:AddButton(name, self.buttonList)
end

function PANEL:OnMousePressed(key)
	for _, v in pairs(self.buttonList) do
		if (IsValid(v) and v != self) then
			v:SetSelected(false, self.sectionParent == v)
		end
	end

	self:SetSelected(true)
	BaseClass.OnMousePressed(self, key)
end

function PANEL:OnSelected()
end

vgui.Register("ixMenuSelectionButtonTop", PANEL, "ixMenuButton")
