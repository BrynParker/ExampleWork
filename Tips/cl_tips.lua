surface.CreateFont( "fallout_hud", {
	font = "Monofonto",
	size = 28,
	weight = 100,
	blursize = 0,
	scanlines = 0,
	antialias = true,
	underline = false,
	italic = false,
	strikeout = false,
	symbol = false,
	rotary = false,
	shadow = false,
	additive = false,
	outline = false,
} )

surface.CreateFont( "fallout_hud_blur", {
	font = "Monofonto",
	size = 30,
	weight = 100,
	blursize = 3,
	scanlines = 0,
	antialias = true,
	underline = false,
	italic = false,
	strikeout = false,
	symbol = false,
	rotary = false,
	shadow = false,
	additive = false,
	outline = false,
} )

net.Receive( "tipSend", function()
	
	local text = net.ReadString()
	local dur = net.ReadUInt( 8 )
	local col = net.ReadColor()
	local pip = net.ReadUInt( 6 )
	local pos = net.ReadUInt( 4 )
	
	local tip = vgui.Create("tipPanel")
	tip:SetText( text )
	tip:SetDuration( dur )
	tip:SetColor( col )
	tip:SetPipboy( pip )
	tip:SetDock( pos )

end)

local PANEL = {}

function PANEL:Init()
	
	self.w_div = 474
	self.h_div = 228
	
	self:SetSize( self.w_div, self.h_div )
	
	self.w_pip = 128
	self.h_pip = 128
	
	self.scrW = ScrW()
	self.scrH = ScrH()
	
	self:SetPos( self.scrW/2 - self.w_div/2, self.scrH - self.h_div )
	
	self.color = Color( 255, 182, 67, 255 )
	
	self.alpha = 0
	self.target_alpha = 255
	
	self.pipboy = surface.GetTextureID( "fallout/pipboy_1" )
	self.border = surface.GetTextureID( "fallout/border" )
	
	self.text_draw_t = {}
	
	self.max_w = 320
	
end

function PANEL:SetDuration( dur )
	
	timer.Simple( dur, function() self:FadeOut() end )
	
end

function PANEL:SetDock( pos )
	
	if pos == TIP_BOTTOM_MIDDLE then
		self:SetPos( self.scrW/2 - self.w_div/2, self.scrH - self.h_div )
	elseif pos == TIP_BOTTOM_LEFT then
		self:SetPos( -10, self.scrH - self.h_div )
	elseif pos == TIP_BOTTOM_RIGHT then
		self:SetPos( self.scrW - self.w_div - 32, self.scrH - self.h_div )
	elseif pos == TIP_TOP_MIDDLE then
		self:SetPos( self.scrW/2 - self.w_div/2, -30 )
	elseif pos == TIP_TOP_LEFT then
		self:SetPos( -10, -30 )
	elseif pos == TIP_TOP_RIGHT then
		self:SetPos( self.scrW - self.w_div - 32, -30 )
	end

end

function PANEL:SetColor( col )

	self.color = col

end

function PANEL:SetPipboy( img )

	self.pipboy = surface.GetTextureID( "fallout/pipboy_" .. img )

end

function PANEL:SetText( txt )
	
	self.text_draw_t = {}
	
	local text_t = string.Explode( " ", txt )
	local line = 0
	
	surface.SetFont( "fallout_hud" )
	for k, word in pairs( text_t ) do

		local buff = (self.text_draw_t[line] or "") .. word .. " "
		local w, _ = surface.GetTextSize( buff )
		
		line = line + math.floor( w / self.max_w )
		self.text_draw_t[line] = (self.text_draw_t[line] or "") .. word .. " "
	
	end
	
end

function PANEL:FadeOut()

	self.target_alpha = 0
	timer.Simple( 3, function() self:Remove() end )
	
end

function PANEL:Paint()
	
	local pipboy = {
		texture = self.pipboy,
		color	= Color( self.color.r, self.color.g, self.color.b, self.alpha ),
		x 	= 45,
		y 	= 32 + 21,
		w 	= self.w_pip,
		h 	= self.h_pip
	}
	
	local border = {
		texture = self.border,
		color	= Color( self.color.r, self.color.g, self.color.b, self.alpha ),
		x 	= 20,
		y 	= 16,
		w 	= self.w_div,
		h 	= self.h_div
	}

	draw.TexturedQuad( pipboy )
	draw.TexturedQuad( border )
	
	
	for k, line in pairs( self.text_draw_t ) do
	
		draw.SimpleText( line, "fallout_hud_blur", 118 + 32 + 5, 100 + 1 + k * 28, Color( 0, 0, 0, self.alpha ), TEXT_ALIGN_LEFT, TEXT_ALIGN_TOP )
		draw.SimpleText( line, "fallout_hud", 118 + 32 + 5, 100 + k * 28, Color( self.color.r, self.color.g, self.color.b, self.alpha ), TEXT_ALIGN_LEFT, TEXT_ALIGN_TOP )
	
	end
	
end

function PANEL:Think()

	if math.floor( self.alpha ) == self.target_alpha or math.ceil( self.alpha ) == self.target_alpha then return end
	
	self.alpha = Lerp( 0.04, self.alpha, self.target_alpha )

end

vgui.Register( "tipPanel", PANEL )