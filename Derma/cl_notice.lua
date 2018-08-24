local PANEL = {}
	local gradient = nut.util.getMaterial("vgui/gradient-d")
	local noticepanel = Material( "sci_char/description_head.png", "noclamp smooth" )

	function PANEL:Init()
		self:SetSize(256, 36)
		self:SetContentAlignment(5)
		self:SetExpensiveShadow(1, Color(0, 0, 0, 100))
		self:SetFont("nutMediumFont")
		self:SetTextColor(color_white)
		self:SetDrawOnTop(true)
	end

	function PANEL:Paint(w, h)
		nut.util.drawBlur(self, 10)

		surface.SetDrawColor(230, 230, 230, 10)
		surface.DrawRect(0, 0, w, h)

		if (self.start) then
			local w2 = math.TimeFraction(self.start, self.endTime, CurTime()) * w

			surface.SetDrawColor(nut.config.get("color"))
			surface.SetMaterial(noticepanel)
			surface.DrawTexturedRect(w2, 0, w - w2, h)
		end

		surface.SetDrawColor(255, 255, 255, 255)
		surface.SetMaterial(noticepanel)
		surface.DrawTexturedRect(0, 0, w, h)
	end
vgui.Register("nutNotice", PANEL, "DLabel")