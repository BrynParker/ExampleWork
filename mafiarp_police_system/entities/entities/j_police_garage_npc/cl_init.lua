include("shared.lua")


function ENT:Initialize()
end

function ENT:Draw()

	self:DrawModel()
	
end


ENT.PopulateEntityInfo = true

function ENT:OnPopulateEntityInfo(tooltip)

	local panel = tooltip:AddRow("name")
	panel:SetText("PD Garage")
	panel:SetImportant()
	 	panel:SizeToContents()
	 	

 	local desc = tooltip:AddRowAfter("name", "desc")
	desc:SetText("You can get a police car here.")
 	desc:SizeToContents()

 	tooltip:SizeToContents()

end