

local logotype = ix.util.GetMaterial("mafiarp/logo.png", "noclamp")
local mxperso = hook.Run("GetMaxPlayerCharacter", LocalPlayer())
local offset = 41
local btnWidth = 285 - 32
local btnHeight = 40
local btnColors = {
	[1] = {
		Color(29, 49, 58),
		Color(29, 49, 58),
		Color(29, 49, 58),
	}
}





local btnHeight = 40
local btnColors = {
	[1] = {
		Color(29, 49, 58),
		Color(29, 49, 58),
		Color(29, 49, 58),
		Color(29, 49, 58),
		Color(29, 49, 58),
		Color(29, 49, 58)
	},
	[2] = {
		Color(248, 56, 56),
		Color(248, 56, 56, 48),
		Color(248, 56, 56),
		Color(96, 10, 10),
		Color(248, 56, 56, 225),
		Color(201, 45, 45, 160)
	},
}

local icons = {
	ix.util.GetMaterial("trex/new.png"),
	ix.util.GetMaterial("trex/chars.png"),
	ix.util.GetMaterial("trex/chars.png"),
	ix.util.GetMaterial("trex/info.png"),
	ix.util.GetMaterial("trex/exit.png"),
	ix.util.GetMaterial("trex/discord.png"),
}
surface.CreateFont("trex.main.btn", {
	font = "Nagonia",
	extended = true,
	size = 24,
	weight = 500,
	blursize = 0,
	scanlines = 0,
	antialias = true,
})
surface.CreateFont("trex.main.btn.blur", {
	font = "Nagonia",
	extended = true,
	size = 24,
	weight = 500,
	blursize = 4,
	scanlines = 2,

	additive = true,
	outline = false,
})

local shadow = ix.util.GetMaterial("trex/shadow.png")
surface.CreateFont("trex.main.warn", {
	font = "Nagonia",
	extended = true,
	size = 20,
	weight = 500,
	blursize = 0,
	scanlines = 0,
	antialias = true,
})

local gradient = surface.GetTextureID("vgui/gradient-l")
local audioFadeInTime = 2
local animationTime = 0.5
local matrixZScale = Vector(1, 1, 0.0001)

-- character menu panel
DEFINE_BASECLASS("ixSubpanelParent")
local PANEL = {}

function PANEL:Init()
	self:SetSize(self:GetParent():GetSize())
	self:SetPos(0, 0)
	ix.gui.characterLoadMenu = false  

	self.childPanels = {}
	self.subpanels = {}
	self.activeSubpanel = ""

	self.currentDimAmount = 0
	self.currentY = 0
	self.currentScale = 1
	self.currentAlpha = 255
	self.targetDimAmount = 255
	self.targetScale = 0.9
end

function PANEL:Dim(length, callback)
	length = length or animationTime
	self.currentDimAmount = 0

	self:CreateAnimation(length, {
		target = {
			currentDimAmount = self.targetDimAmount,
			currentScale = self.targetScale
		},
		easing = "outCubic",
		OnComplete = callback
	})

	self:OnDim()
end

function PANEL:Undim(length, callback)
	length = length or animationTime
	self.currentDimAmount = self.targetDimAmount

	self:CreateAnimation(length, {
		target = {
			currentDimAmount = 0,
			currentScale = 1
		},
		easing = "outCubic",
		OnComplete = callback
	})

	self:OnUndim()
end

function PANEL:OnDim()
end

function PANEL:OnUndim()
end

function PANEL:Paint(width, height)
	local amount = self.currentDimAmount
	local bShouldScale = self.currentScale != 1
	local matrix

	ix.util.DrawBlur(self, 15)

	-- draw child panels with scaling if needed
	if (bShouldScale) then
		matrix = Matrix()
		matrix:Scale(matrixZScale * self.currentScale)
		matrix:Translate(Vector(
			ScrW() * 0.5 - (ScrW() * self.currentScale * 0.5),
			ScrH() * 0.5 - (ScrH() * self.currentScale * 0.5),
			1
		))

		cam.PushModelMatrix(matrix)
		self.currentMatrix = matrix
	end

	BaseClass.Paint(self, width, height)

	if (bShouldScale) then
		cam.PopModelMatrix()
		self.currentMatrix = nil
	end

	if (amount > 0) then
		local color = Color(0, 0, 0, amount)
	end
end

vgui.Register("ixCharMenuPanel", PANEL, "ixSubpanelParent")

local PANEL = {}

-- main character menu panel
PANEL = {}

AccessorFunc(PANEL, "bUsingCharacter", "UsingCharacter", FORCE_BOOL)

function PANEL:Init()
	local parent = self:GetParent()
	local padding = self:GetPadding()
	local halfWidth = ScrW() * 0.5
	local halfPadding = padding * 0.5
	local bHasCharacter = #ix.characters > 0

	self.bUsingCharacter = LocalPlayer().GetCharacter and LocalPlayer():GetCharacter()

	self:SetSize(0, 0)
	self:SetPos(0, 0)
	self:SetAlpha(0)
	self.isAnimating = false
	self:SizeTo(ScrW(), ScrH(), 1, .1, .1, function()
		self.isAnimating = true
	end)
	self:AlphaTo(255, .8, .1)
	self.Think = function()
		if self.isAnimating then
			self:Center()
		end
	end

	if IsValid(trex_main) then

		trex_main:Remove()
		trex_main = nil
	end

	local trex_main = self
	self.background = self:Add("EditablePanel")
	self.background:SetSize(ScrW(), ScrH())
	self.background.frac = 0
	self.background.Paint = function(this, w, h)
		surface.SetDrawColor(27,27,27,0)
		surface.DrawRect(0,0,w,h)
	end

	self.addpaint = self:Add("EditablePanel")
	self.addpaint:SetSize(ScrW(), ScrH())
	self.addpaint:SetPaintedManually(true)
	self.addpaint.Paint = function(this, w, h)
		local shadow = ix.util.GetMaterial("trex/shadow.png")
		local television = ix.util.GetMaterial('trex/lignetv.png')
	
		local h = ScrH() - 70 - 155
		local clr2 = Color(255, 255, 255, 50 + 100 * math.abs(math.sin(CurTime() * 2)))
		
		local intensité = 3
	
			surface.SetMaterial(logotype)
			surface.SetDrawColor(Color(0,0,0,0))
			surface.DrawTexturedRect(ScrW() / 70, ScrH() / 6, ScrW() - ScrW()/1.6, ScrH() - ScrH()/1.23)
	
	end
	
	

	-- button list
	self.mainButtonList = self:Add("Panel")
	self.mainButtonList:Dock(BOTTOM)
	self.mainButtonList:SetTall(61)
	self.mainButtonList.Paint = function(s,w,h)
		surface.SetDrawColor(27,27,27,0)
		surface.DrawRect(0,0,w,h)
		--COMEBACK
		surface.SetDrawColor(29, 49, 58)
		surface.DrawRect(0, 60, w,1)
	end

	self.loadbutton = self:Add('trexbutton')
	self.loadbutton:SetPos(ScrW() * .0573, ScrH() *.4500 + 55)
	self.loadbutton:SetText(('CHARACTERS'):utf8upper())
	self.loadbutton:SetIcon(2)
	self.loadbutton:SizeTo(295, 50, 1, (0.25 * 2))
	self.loadbutton.DoClick = function()
		self:SlideDown()
		parent.loadCharacterPanel:SlideUp()
	end


	-- community button
	local extraURL = ix.config.Get("communityURL", "")
	local extraText = ix.config.Get("communityText", "@community")

	if (extraURL != "" and extraText != "") then
		if (extraText:sub(1, 1) == "@") then
			extraText = L(extraText:sub(2))
		end


		local info = self:Add("trexbutton")
		info:SetPos(ScrW() * .0573, ScrH() *.4500 + 55 * (2))
		info:SetText(('WEBSITE'):utf8upper())
		info:SetIcon(3)
		info:SizeTo(295, 50, 1, (0.25 * 3))
		info.DoClick = function()
			gui.OpenURL(extraURL)
		end
	end
	

	local content = self:Add("trexbutton")
	content:SetPos(ScrW() * .0573, ScrH() *.4500 + 55 * (3))
	content:SetText(('COLLECTION'):utf8upper())
	content:SetIcon(4)
	content:SizeTo(295, 50, 1, (0.25 * 4))
	content.DoClick = function()
		gui.OpenURL("https://steamcommunity.com/sharedfiles/filedetails/?id=3046299934")
	end

	local discord = self.mainButtonList:Add("ixMainMenuSelectionButtonTrex")
	discord:Dock(RIGHT)
	discord:SetText(('DISCORD'):utf8upper())
	discord:SetSize(400, 50)
	discord.DoClick = function()
		gui.OpenURL("https://discord.gg/SKY8XMt5AN")
	end

	local a = self:Add("trexbutton")
	a:SetPos(ScrW() * .0573, ScrH() *.4500 + 55 * (5))
	a:SetText(("QUIT"):utf8upper())
	a:SetIcon(5)
	a:SizeTo(295, 50, 1, (0.25 * 5))
	a.DoClick = function()
		if (self.bUsingCharacter) then
			parent:Close()
			parent.loadCharacterPanel:Remove()
			LocalPlayer():ScreenFade(SCREENFADE.IN,color_black,.9,.9)
		else
			RunConsoleCommand("disconnect")
		end
	end

	self.mainButtonList:SizeToContents()
end


function PANEL:OnDim()
	self:SetMouseInputEnabled(false)
	self:SetKeyboardInputEnabled(false)
end

function PANEL:UpdateReturnButton(bValue)
	if (bValue != nil) then
		self.bUsingCharacter = bValue
	end
end

function PANEL:OnUndim()
	self:SetMouseInputEnabled(true)
	self:SetKeyboardInputEnabled(true)

	self.bUsingCharacter = LocalPlayer().GetCharacter and LocalPlayer():GetCharacter()
	self:UpdateReturnButton()
end

function PANEL:OnClose()
	for _, v in pairs(self:GetChildren()) do
		if (IsValid(v)) then
			v:SetVisible(false)
		end
	end
end

function PANEL:PerformLayout(width, height)
	local padding = self:GetPadding()

	self.mainButtonList:SetPos(padding, height - self.mainButtonList:GetTall() - padding)
end



vgui.Register("ixCharMenuMain", PANEL, "ixCharMenuPanel")

-- container panel
PANEL = {}

function PANEL:Init()
	if (IsValid(ix.gui.loading)) then
		ix.gui.loading:Remove()
	end

	if (IsValid(ix.gui.characterMenu)) then
		if (IsValid(ix.gui.characterMenu.channel)) then
			ix.gui.characterMenu.channel:Stop()
		end

		ix.gui.characterMenu:Remove()
	end

	self:SetSize(ScrW(), ScrH())
	self:SetPos(0, 0)

	-- main menu panel
	self.mainPanel = self:Add("ixCharMenuMain")

	-- new character panel
	--self.newCharacterPanel = self:Add("ixCharMenuNew")
	--self.newCharacterPanel:SlideDown(0)

	-- load character panel
	self.loadCharacterPanel = self:Add("ixCharMenuLoad")
	self.loadCharacterPanel:SlideDown(0)

	-- notice bar
	self.notice = self:Add("ixNoticeBar")

	-- finalization
	self:MakePopup()
	self.currentAlpha = 255
	self.volume = 0

	ix.gui.characterMenu = self
	ix.gui.characterMenu.opened = true

	if (!IsValid(ix.gui.intro)) then
		self:PlayMusic()
	end

	hook.Run("OnCharacterMenuCreated", self)
end

function PANEL:PlayMusic()
	local path = "sound/" .. ix.config.Get("music")
	local url = path:match("http[s]?://.+")
	local play = url and sound.PlayURL or sound.PlayFile
	path = url and url or path

	play(path, "noplay", function(channel, error, message)
		if (!IsValid(self) or !IsValid(channel)) then
			return
		end

		channel:SetVolume(self.volume or 0)
		channel:Play()

		self.channel = channel

		self:CreateAnimation(audioFadeInTime, {
			index = 10,
			target = {volume = 1},

			Think = function(animation, panel)
				if (IsValid(panel.channel)) then
					panel.channel:SetVolume(self.volume * 0.5)
				end
			end
		})
	end)
end

function PANEL:ShowNotice(type, text)
	self.notice:SetType(type)
	self.notice:SetText(text)
	self.notice:Show()
end

function PANEL:HideNotice()
	if (IsValid(self.notice) and !self.notice:GetHidden()) then
		self.notice:Slide("up", 0.5, true)
	end
end

function PANEL:OnCharacterDeleted(character)
	if (#ix.characters == 0) then
		self:Remove()
		vgui.Create("ixCharMenu")
	else
	end

	self.loadCharacterPanel:OnCharacterDeleted(character)
end

function PANEL:OnCharacterLoadFailed(error)
	self.loadCharacterPanel:SetMouseInputEnabled(true)
	self.loadCharacterPanel:SlideUp()
	self:ShowNotice(3, error)
end

function PANEL:IsClosing()
	return self.bClosing
end

function PANEL:Close(bFromMenu)
	self.bClosing = true
	self.bFromMenu = bFromMenu

	local fadeOutTime = animationTime * 8

	self:CreateAnimation(fadeOutTime, {
		index = 1,
		target = {currentAlpha = 0},

		Think = function(animation, panel)
			panel:SetAlpha(panel.currentAlpha)
		end,

		OnComplete = function(animation, panel)
			panel:Remove()
		end
	})

	self:CreateAnimation(fadeOutTime - 0.1, {
		index = 10,
		target = {volume = 0},

		Think = function(animation, panel)
			if (IsValid(panel.channel)) then
				panel.channel:SetVolume(self.volume * 0.5)
			end
		end,

		OnComplete = function(animation, panel)
			if (IsValid(panel.channel)) then
				panel.channel:Stop()
				panel.channel = nil
			end
		end
	})

	-- hide children if we're already dimmed
	if (bFromMenu) then
		for _, v in pairs(self:GetChildren()) do
			if (IsValid(v)) then
				v:SetVisible(false)
			end
		end
	else
		-- fade out the main panel quicker because it significantly blocks the screen
		self.mainPanel.currentAlpha = 255

		self.mainPanel:CreateAnimation(animationTime * 2, {
			target = {currentAlpha = 0},
			easing = "outQuint",

			Think = function(animation, panel)
				panel:SetAlpha(panel.currentAlpha)
			end,

			OnComplete = function(animation, panel)
				panel:SetVisible(false)
			end
		})
	end

	-- relinquish mouse control
	self:SetMouseInputEnabled(false)
	self:SetKeyboardInputEnabled(false)
	gui.EnableScreenClicker(false)
end

function PANEL:Paint(width, height)
	surface.SetTexture(gradient)
	surface.SetDrawColor(0, 0, 0)
	surface.DrawTexturedRect(0, 0, width, height)
end

function PANEL:PaintOver(width, height)
	if (self.bClosing and self.bFromMenu) then
		surface.SetDrawColor(color_black)
		surface.DrawRect(0, 0, width, height)
	end
end

function PANEL:OnRemove()
	if (IsValid(self.channel)) then
		self.channel:Stop()
		self.channel = nil
	end
end

vgui.Register("ixCharMenu", PANEL, "EditablePanel")

if (IsValid(ix.gui.characterMenu)) then
	ix.gui.characterMenu:Remove()

	--TODO: REMOVE ME
	timer.Simple(0, function()
		ix.gui.characterMenu = vgui.Create("ixCharMenu")
	end)
end
