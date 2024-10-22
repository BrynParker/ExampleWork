local PLUGIN = PLUGIN

PLUGIN.name = "MafiaRP Character Menu"
PLUGIN.description = ""
PLUGIN.author = "Civic Networks"
PLUGIN.license = [[
]]

ix.util.Include("derma/cl_menubutton.lua.lua")
ix.char.RegisterVar("model", {
	field = "model",
	fieldType = ix.type.string,
	default = "models/error.mdl",
	index = 3,
	OnSet = function(character, value)
		local client = character:GetPlayer()

		if (IsValid(client) and client:GetCharacter() == character) then
			client:SetModel(value)
		end

		character.vars.model = value
	end,
	OnGet = function(character, default)
		return character.vars.model or default
	end,
	OnDisplay = function(self, container, payload)
		local scroll = container:Add("DScrollPanel")
		scroll:Dock(FILL)
		scroll.Paint = function(panel, width, height)
			derma.SkinFunc("DrawImportantBackground", 0, 0, width, height, Color(255, 255, 255, 25))
		end

		local layout = scroll:Add("DIconLayout")
		layout:Dock(FILL)
		layout:SetSpaceX(1)
		layout:SetSpaceY(1)

		local faction = ix.faction.indices[payload.faction]

		if (faction) then
			local models = faction:GetModels(LocalPlayer())

			for k, v in SortedPairs(models) do
				local icon = layout:Add("SpawnIcon")
				icon:SetSize(128, 256)
				icon:SetTooltip(false)
				icon:InvalidateLayout(true)
				icon.DoClick = function(this)
    			    payload:Set("model", k)
   		 		end
    

                    
                    
                    
				icon.PaintOver = function(this, w, h)
					if (payload.model == k) then
						local color = ix.config.Get("color", color_white)

						surface.SetDrawColor(color.r, color.g, color.b, 200)

						for i = 1, 3 do
							local i2 = i * 2
							surface.DrawOutlinedRect(i, i, w - i2, h - i2)
						end
					end
				end

				if (isstring(v)) then
					icon:SetModel(v)
				else
					icon:SetModel(v[1], v[2] or 0, v[3])
				end
			end
		end

		return scroll
	end,
	OnValidate = function(self, value, payload, client)
		local faction = ix.faction.indices[payload.faction]

		if (faction) then
			local models = faction:GetModels(client)

			if (!payload.model or !models[payload.model]) then
				return false, "needModel"
			end
		else
			return false, "needModel"
		end
	end,
	OnAdjust = function(self, client, data, value, newData)
		local faction = ix.faction.indices[data.faction]

		if (faction) then
			local model = faction:GetModels(client)[value]

			if (isstring(model)) then
				newData.model = model
			elseif (istable(model)) then
				newData.model = model[1]

				-- save skin/bodygroups to character data
				local bodygroups = {}

				for i = 1, #model[3] do
					bodygroups[i - 1] = tonumber(model[3][i]) or 0
				end

				newData.data = newData.data or {}
				newData.data.skin = model[2] or 0
				newData.data.groups = bodygroups
			end
		end
	end,
	ShouldDisplay = function(self, container, payload)
		local faction = ix.faction.indices[payload.faction]
		return #faction:GetModels(LocalPlayer()) > 1
	end
})

ix.char.RegisterVar("description", {
	field = "description",
	fieldType = ix.type.text,
	default = "",
	index = 2,
	OnValidate = function(self, value, payload)
		value = string.Trim((tostring(value):gsub("\r\n", ""):gsub("\n", "")))
		local minLength = ix.config.Get("minDescriptionLength", 16)

		if (value:utf8len() < minLength) then
			return false, "descMinLen", minLength
		elseif (!value:find("%s+") or !value:find("%S")) then
			return false, "invalid", "description"
		end

		return value
	end,
	OnPostSetup = function(self, panel, payload)

		local faction = ix.faction.indices[payload.faction]
		if (faction) then
			if (faction.customDesc) then
				payload:Set("description", faction.customDesc)
				panel:SetText(faction.customDesc)
				panel:SetEditable(false)
			end
		end

		panel:SetMultiline(true)
		panel:SetFont("xpgui_huge")
		panel:SetTextColor(color_white)
		panel:SetPlaceholderText("A man of around 30 years old, of average height...")
		panel:SetTall(panel:GetTall() * 4 + 12)
		panel.AllowInput = function(_, character)
			if (character == "\n" or character == "\r") then
				return true
			end
		end
	end,
	alias = "Desc"
})

