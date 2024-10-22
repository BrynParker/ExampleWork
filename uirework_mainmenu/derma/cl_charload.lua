
local errorModel = "models/error.mdl"
local PANEL = {}
FACTION = FACTION or {}
FACTION.Positions = {
	[FACTION_CITIZEN] = {
        Vector( -1934.7, 5347.03, -10960 ),
		Angle( -5.81, 110, 40 )
    },
	[FACTION_POLICE] = {
		Vector( -7292.45, 1684.19, -13450 ),
		Angle( -7.15, -80, 40 )
    },

}
AccessorFunc(PANEL, "animationTime", "AnimationTime", FORCE_NUMBER)

local function SetCharacter(self, character)
	self.character = character

	if (character) then
		self:SetModel(character:GetModel())
		self:SetSkin(character:GetData("skin", 0))

		for i = 0, (self:GetNumBodyGroups() - 1) do
			self:SetBodygroup(i, 0)
		end

		local bodygroups = character:GetData("groups", nil)

		if (istable(bodygroups)) then
			for k, v in pairs(bodygroups) do
				self:SetBodygroup(k, v)
			end
		end
	else
		self:SetModel(errorModel)
	end
end

local function GetCharacter(self)
	return self.character
end

local ply = LocalPlayer()
AccessorFunc(PANEL, "animationTime", "AnimationTime", FORCE_NUMBER)
AccessorFunc(PANEL, "backgroundFraction", "BackgroundFraction", FORCE_NUMBER)

function PANEL:Init()
	local parent = self:GetParent()
	local padding = self:GetPadding()
	local halfWidth = parent:GetWide() * 0.5 - (padding * 2)
	local halfHeight = parent:GetTall() * 0.5 - (padding * 2)
	local modelFOV = (ScrW() > ScrH() * 1.8) and 102 or 78
	self.character = character
	self.backgroundAlpha = 128
	self.currentBackgroundAlpha = 0

	self.animationTime = 1
	self.backgroundFraction = 1
	ix.gui.characterLoadMenu = self
	self.activeCharacter = ClientsideModel(errorModel)

	self.activeCharacter.SetCharacter = SetCharacter
	self.activeCharacter.GetCharacter = GetCharacter

	self.panel = self:AddSubpanel("main")
	self.panel:SetTitle(nil)
	hook.Add("CalcView", self, self.View)
	

    hook.Add("PrePlayerDraw", self, function()
        return false
    end)

	hook.Add("PreDrawViewModel", self, function()
        return true 
    end)

    hook.Add("HUDShouldDraw", self, function()
        return false
    end)
	
	self.panel.OnSetActive = function()
		self:CreateAnimation(self.animationTime, {
			index = 2,
			target = {backgroundFraction = 1},
			easing = "outQuint",
		})
	end


	-- character button list
	local controlList = self.panel:Add("Panel")
	controlList:Dock(RIGHT)
	controlList:SetSize(ScrW() / 3.3, halfHeight)


	self.characterList = controlList:Add("DScrollPanel")
	self.characterList.buttons = {}
	self.characterList:Dock(FILL)

	-- right-hand side with carousel and buttons
	local infoPanel = self.panel:Add("Panel")
	infoPanel:Dock(FILL)

	local infoButtons = infoPanel:Add("Panel")
	infoButtons:Dock(LEFT)
	infoButtons:SetTall(50)
	infoButtons:SetWide(160)

	local continueButton = infoButtons:Add("trexbuttoninverser")
	continueButton:Dock(BOTTOM)
	continueButton:SetText("SELECT")
	continueButton:SetIcon(6)
	continueButton:SetSize(160, 50)
	continueButton.DoClick = function()
		local character = LocalPlayer():GetCharacter()

		if character then
			local currentChar = character:GetID()
			if currentChar == self.character:GetID() then
				return parent:ShowNotice(3, L("usingChar"))
			else
				timer.Simple( 3, function() ix.gui.characterMenu:Remove() end )
			end
		end
		
		self:SlideDown(self.animationTime, function()
			net.Start("ixCharacterChoose")
				net.WriteUInt(self.character:GetID(), 32)
			net.SendToServer()
		end, true)
	end

	local back = infoButtons:Add("trexbutton")
	back:Dock(BOTTOM)
	back:SetIcon(5)
	back:SetText("RETURN")
	back:SetSize(295, 50)
	back.DoClick = function()
		self:SlideDown()
		LocalPlayer():ScreenFade(SCREENFADE.IN, color_black,1, 1)
		vgui.Create("ixCharMenu")
	end

	-- character deletion panel
	self.delete = self:AddSubpanel("delete")
	self.delete:SetTitle(nil)
	self.delete.OnSetActive = function()
		self:CreateAnimation(self.animationTime, {
			index = 2,
			target = {backgroundFraction = 0},
			easing = "outQuint"
		})
	end


	local deleteInfo = self.delete:Add("Panel")
	deleteInfo:SetSize(parent:GetWide() * 0.5, parent:GetTall())
	deleteInfo:Dock(LEFT)

	local deleteReturn = deleteInfo:Add("trexbutton")
	deleteReturn:Dock(BOTTOM)
	deleteReturn:SetText("NO")
	deleteReturn:SetIcon(5)
	deleteReturn.DoClick = function()
		self:SetActiveSubpanel("main")
		LocalPlayer():ScreenFade(SCREENFADE.IN, color_black,1, 1)
	end

	local deleteConfirm = self.delete:Add("trexbuttoninverser")
	deleteConfirm:Dock(BOTTOM)
	deleteConfirm:SetText("         YES")
	deleteConfirm:SetIcon(6)
	deleteConfirm:DockMargin(500,0,0,0)
	deleteConfirm.DoClick = function()
		local id = self.activeCharacter:GetCharacter():GetID()

		parent:ShowNotice(1, L("deleteComplete", self.character:GetName()))
		self:Populate(id)
		self:SetActiveSubpanel("main")

		net.Start("ixCharacterDelete")
			net.WriteUInt(id, 32)
		net.SendToServer()

		LocalPlayer():ScreenFade(SCREENFADE.IN, color_black,1, 1)
	end

	local deleteNag = self.delete:Add("Panel")
	deleteNag:SetTall(parent:GetTall() * 0.5)
	deleteNag:Dock(BOTTOM)

	local deleteTitle = deleteNag:Add("DLabel")
	deleteTitle:SetFont("ixTitleFont")
	deleteTitle:SetText(L("areYouSure"):utf8upper())
	deleteTitle:SetTextColor(ix.config.Get("color"))
	deleteTitle:SizeToContents()
	deleteTitle:Dock(TOP)

	local deleteText = deleteNag:Add("DLabel")
	deleteText:SetFont("xpgui_big")
	deleteText:SetText(" "..L("deleteConfirm"))
	deleteText:SetTextColor(color_white)
	deleteText:SetContentAlignment(7)
	deleteText:Dock(FILL)

	-- finalize setup
	self:SetActiveSubpanel("main", 0)
end

function PANEL:ResetSequence(model, lastModel)
	local sequence = model:LookupSequence("idle_unarmed")

	if (sequence <= 0) then
		sequence = model:SelectWeightedSequence(ACT_IDLE)
	end

	if (sequence > 0) then
		model:ResetSequence(sequence)
	else
		local found = false

		for _, v in ipairs(model:GetSequenceList()) do
			if ((v:lower():find("idle") or v:lower():find("fly")) and v != "idlenoise") then
				model:ResetSequence(v)
				found = true

				break
			end
		end

		if (!found) then
			model:ResetSequence(4)
		end
	end

	model:SetIK(false)

	if (lastModel) then
		model:SetCycle(lastModel:GetCycle())
	end
end


function PANEL:SetActiveCharacter(character)
	self.shadeY = self:GetTall()
	self.shadeHeight = self:GetTall()

	if (self.activeCharacter:GetModel() == errorModel) then
		self.activeCharacter:SetCharacter(character)
		self:ResetSequence(self.activeCharacter)

		return
	end

	local shade = self:GetTweenAnimation(1)
	local shadeHide = self:GetTweenAnimation(2)

	if (shade) then
		shade.newCharacter = character
		return
	elseif (shadeHide) then
		shadeHide.queuedCharacter = character
		return
	end

	self:ResetSequence(self.activeCharacter)

	shade = self:CreateAnimation(self.animationTime * 0.5, {
		index = 1,
		target = {
			shadeY = 0,
			shadeHeight = self:GetTall()
		},
		easing = "linear",

		OnComplete = function(shadeAnimation, shadePanel)
			shadePanel.activeCharacter:SetCharacter(shadeAnimation.newCharacter)
			shadePanel:ResetSequence(shadePanel.activeCharacter)

			shadePanel:CreateAnimation(shadePanel.animationTime, {
				index = 2,
				target = {shadeHeight = 0},
				easing = "outQuint",

				OnComplete = function(animation, panel)
					if (animation.queuedCharacter) then
						panel:SetActiveCharacter(animation.queuedCharacter)
					end
				end
			})
		end
	})

	shade.newCharacter = character
end

function PANEL:View()
	if not self.activeCharacter or not self.activeCharacter:GetCharacter() then
        return {}
    end
	
    local index = self.activeCharacter:GetCharacter():GetFaction()
    local faction = ix.faction.indices[index]
	local data = FACTION.Positions[faction.index]
    local tbl = {}
    if data == NIL then return end
    local pos = data[1] or ply:GetPos()
    local forward = (data[2]:Forward() or ply:GetForward())
    local right = -(data[2]:Right() or ply:GetRight())
	self.activeCharacter:SetPos(pos - Vector(0, 0, 35))
    self.activeCharacter:SetAngles(Angle(0, data[2].y  or ply:GetAngles().y, 0))
    tbl.origin = pos + forward * 100 + Vector(0, 0, 0)
    tbl.angles = (pos - tbl.origin + Vector(0, 0, 7) + right * 16):Angle()
    tbl.fov = 35
    return tbl

end


function PANEL:OnCharacterDeleted(character)
	if (self.bActive and #ix.characters == 0) then
		self:SlideDown()
	end
end

function PANEL:Populate(ignoreID)
	self.characterList:Clear()
	self.characterList.buttons = {}
	local parent = self:GetParent()
	local bSelected

	-- loop backwards to preserve order since we're docking to the bottom
	for i = 1, #ix.characters do
		local id = ix.characters[i]
		local character = ix.char.loaded[id]

		if (!character or character:GetID() == ignoreID) then
			continue
		end

		local index = character:GetFaction()
		local faction = ix.faction.indices[index]
		local color = faction and faction.color or color_white
		
		local button = self.characterList:Add("ixMenuSelectionButton")
		button:SetBackgroundColor(color)
		button:SetText("")
		button:SetFont("xpgui_big")
		button:SizeToContents()
		button:Dock(TOP)
		button:SetTall(ScrH() / 10)
		button:DockMargin(0,20,0,0)
		button:SetButtonList(self.characterList.buttons)
		button.character = character
		button.Paint = function(s,w,h)
			if button.Hovered or button.selected then
				color_hover = faction.color
			else
				color_hover = Color(196, 196, 196)
			end



			surface.SetDrawColor(Color(140,140,140,240))
			surface.SetMaterial(Material("mafiarp/faction_gradient_right_lighter_round.png", "noclamp smooth"))
			surface.DrawTexturedRect(0,0,w,h)

			
			surface.SetDrawColor(color_white)
			surface.SetMaterial(faction.icon or Material("mafiarp/user.png", "noclamp smooth"))
			surface.DrawTexturedRect(0,0,ScrW()/17,h)

			draw.DrawText(character:GetName(),"xpgui_big",button:GetWide() / 5,10,color_white, TEXT_ALIGN_LEFT)
			draw.DrawText(faction.name,"xpgui_big",button:GetWide() / 5,40,color_white, TEXT_ALIGN_LEFT)
			draw.DrawText("Level: 5", "xpgui_big",button:GetWide() / 1.02,button:GetTall() / 1.45,color_white,TEXT_ALIGN_RIGHT)
		end
		button.OnSelected = function(panel)
			LocalPlayer():ScreenFade(SCREENFADE.IN, color_black,1, 1)
			self:OnCharacterButtonSelected(panel)
		end



		local localCharacter = LocalPlayer().GetCharacter and LocalPlayer():GetCharacter()

		if (localCharacter and character:GetID() == localCharacter:GetID()) then
			button:SetSelected(true)
			self.characterList:ScrollToChild(button)

			bSelected = true
		end

		local deleteButton = button:Add("trexbuttonv2")
		deleteButton:SetPos(ScrW() / 3.6,0)
		deleteButton:SetText("")
		deleteButton:SetColor(Color(255,255,255))
		deleteButton:SetIcon(7)
		deleteButton.Paint = function(s,w,h)
			surface.SetDrawColor(Color(255,255,255,240))
			surface.SetMaterial(Material("mafiarp/menu/ban.png", "noclamp smooth"))
			surface.DrawTexturedRect(4.5, h / 2 - 16, 32, 32)
		end
		deleteButton.DoClick = function(panel)
			local parentdel = panel:GetParent()
			LocalPlayer():ScreenFade(SCREENFADE.IN, color_black,1, 1)
			self:SetActiveCharacter(parentdel.character)
			self:SetActiveSubpanel("delete")
		end
	end
	
	if (!bSelected) then
		local buttons = self.characterList.buttons

		if (#buttons > 0) then
			local button = buttons[#buttons]

			button:SetSelected(true)
			self.characterList:ScrollToChild(button)
		else
			self.character = nil
		end
	end

	local charList = ix.config.Get("maxCharacters", 5) - #ix.characters
    for i = 1, charList do 

        local button2 = self.characterList:Add("ixMenuCreationButtonTrex")
        button2:SetText(("Create Character"):utf8upper())
		button2:SetMaterial(ix.util.GetMaterial("mafiarp/menu/health.png"))
        button2:SetContentAlignment(5)
        button2:SetFont("xpgui_big")
        button2:SizeToContents()
        button2:Dock(TOP)
        button2:SetTall(ScrH() / 10)
        button2:DockMargin(0,20,0,0)
        button2.DoClick = function(s,w,h)
            --parent.newCharacterPanel:SetActiveSubpanel("faction", 0)
            --parent.newCharacterPanel:SlideUp()
        end
    end

	self.characterList:SizeToContents()
end

function PANEL:OnSlideUp()
	self.bActive = true
	ix.gui.characterLoadMenu = true 
	self:Populate()
end

function PANEL:OnSlideDown()
	self.bActive = false
	ix.gui.characterLoadMenu = false  
end

function PANEL:OnRemove()
    if IsValid(self.activeCharacter) then
        self.activeCharacter:Remove()
    end
end

function PANEL:OnCharacterButtonSelected(panel)
	self:SetActiveCharacter(panel.character)
	self.character = panel.character
end

function PANEL:Paint(width, height)
end

vgui.Register("ixCharMenuLoad", PANEL, "ixCharMenuPanel")
