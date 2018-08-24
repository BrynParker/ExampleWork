local PANEL = {}
	local gradient = nut.util.getMaterial("vgui/gradient-u")
	local gradient2 = nut.util.getMaterial("vgui/gradient-d")
	local attribpanel = Material ("bgs/ui_combobox_options_back.png", "noclamp smooth")
	local attribgradient = Material ("bgs/ui_combobox_options_back.png")
	local plus = Material("sci_char/slider/right_n.png")

	function PANEL:Init()
		self:SetTall(30)

		self.add = self:Add("DImageButton")
		self.add:SetSize(24, 24)
		self.add:Dock(RIGHT)
		self.add:DockMargin(2, 2, 2, 2)
		self.add:SetImage("sci_char/slider/right_n.png")
		self.add.OnMousePressed = function()
			self.pressing = 1
			self:doChange()
			self.add:SetAlpha(150)
		end
		self.add.OnMouseReleased = function()
			if (self.pressing) then
				self.pressing = nil
				self.add:SetAlpha(255)
			end
		end
		self.add.OnCursorExited = self.add.OnMouseReleased

		self.sub = self:Add("DImageButton")
		self.sub:SetSize(24, 24)
		self.sub:Dock(LEFT)
		self.sub:DockMargin(2, 2, 2, 2)
		self.sub:SetImage("sci_char/slider/left_n.png")
		self.sub.OnMousePressed = function()
			self.pressing = -1
			self:doChange()
			self.sub:SetAlpha(150)
		end
		self.sub.OnMouseReleased = function()
			if (self.pressing) then
				self.pressing = nil
				self.sub:SetAlpha(255)
			end
		end
		self.sub.OnCursorExited = self.sub.OnMouseReleased

		self.value = 0
		self.deltaValue = self.value
		self.max = 10

		self.bar = self:Add("DPanel")
		self.bar:Dock(FILL)
		self.bar.Paint = function(this, w, h)
			surface.SetDrawColor(0, 0, 0, 255)
			surface.DrawRect(0, 0, w, h)

			w, h = w - 4, h - 4

			local value = self.deltaValue / self.max

			if (value > 0) then
				local color = nut.config.get("color")
				local boostedValue = self.boostValue or 0
				local add = 0

				if (self.deltaValue != self.value) then
					add = 35
				end

				-- your stat
				do
					if !(boostedValue < 0 and math.abs(boostedValue) > self.value) then
						surface.SetDrawColor(color.r + add, color.g + add, color.b + add, 0)
						surface.DrawRect(2, 2, w * value, h)

						surface.SetDrawColor(255, 255, 255, 255)
						surface.SetMaterial(attribpanel)
						surface.DrawTexturedRect(2, 2, w * value, h)
					end
				end

				-- boosted stat
				do
				if (boostedValue != 0) then

					if (boostedValue < 0) then
						local please = math.min(self.value, math.abs(boostedValue))
						boostValue = ((please or 0) / self.max) * (self.deltaValue / self.value)
					else
						boostValue = ((boostedValue or 0) / self.max) * (self.deltaValue / self.value)
					end

					if (boostedValue < 0) then
						surface.SetDrawColor(0, 0, 230, 255)

						local bWidth = math.abs(w * boostValue)
						surface.DrawRect(2 + w * value - bWidth, 2, bWidth, h)

						surface.SetDrawColor(0, 0, 230, 255)
						surface.SetMaterial(gradient)
						surface.DrawTexturedRect(2 + w * value - bWidth, 2, bWidth, h)
					else
						surface.SetDrawColor(0, 0, 230, 255)
						surface.DrawRect(2 + w * value, 2, w * boostValue, h)

						surface.SetDrawColor(0, 0, 230, 255)
						surface.SetMaterial(attribpanel)
						surface.DrawTexturedRect(2 + w * value, 2, w * boostValue, h)
					end
				end
				end
			end

			surface.SetDrawColor(255, 255, 255)
			surface.SetMaterial(attribpanel)
			surface.DrawTexturedRect(2, 2, w, h)
		end

		self.label = self.bar:Add("DLabel")
		self.label:Dock(FILL)
		self.label:SetExpensiveShadow(1, Color(0, 0, 0))
		self.label:SetContentAlignment(5)
	end

	function PANEL:Think()
		if (self.pressing) then
			if ((self.nextPress or 0) < CurTime()) then
				self:doChange()
			end
		end

		self.deltaValue = math.Approach(self.deltaValue, self.value, FrameTime() * 15)
	end

	function PANEL:doChange()
		if ((self.value == 0 and self.pressing == -1) or (self.value == self.max and self.pressing == 1)) then
			return
		end
		
		self.nextPress = CurTime() + 0.2
		
		if (self:onChanged(self.pressing) != false) then
			self.value = math.Clamp(self.value + self.pressing, 0, self.max)
		end
	end

	function PANEL:onChanged(difference)
	end

	function PANEL:getValue()
		return self.value
	end

	function PANEL:setValue(value)
		self.value = value
	end

	function PANEL:setBoost(value)
		self.boostValue = value
	end

	function PANEL:setMax(max)
		self.max = max
	end

	function PANEL:setText(text)
		self.label:SetText(text)
	end

	function PANEL:setReadOnly()
		self.sub:Remove()
		self.add:Remove()
	end
vgui.Register("nutAttribBar", PANEL, "DPanel")