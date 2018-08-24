if SERVER then
	local Assault = {};
---------------------------------------------------------------------------------
	Assault.ToStart = 900;
	Assault.Charges = {
		{ 
			name = "WAR",
			time = 850
		},

		{
			name = "NEUTRAL",
			time = 850
		},
	};
	Assault.FallbackTime = 60;
	Assault.Admins = {"superadmin", "servermanager", "founder"};
	Assault.Whistle = "";
	Assault.Jingle = "";

---------------------------------------------------------------------------------

	Assault.Timer = CurTime() + Assault.ToStart;
	Assault.Text = "PEACE";
	Assault.Stage = 0;
	hook.Add("Think", "asl_timer", function()
		if Assault.Timer <= CurTime() + 1 then
			if Assault.Stage == 0 then
				Assault.Timer = CurTime() + Assault.ToStart;
				Assault.Text = "PEACE";
				Assault.Stage = 1;
				if Assault.ChangedTimer then
					Assault.Timer = CurTime() + Assault.ChangedTimer
					Assault.ChangedTimer = nil;
				end
			elseif Assault.Stage == 1 then
				local charge = table.Random(Assault.Charges);
				local name = charge.name;
				local time = charge.time;

				Assault.Text = name.."";
				Assault.Timer = time + CurTime();
				Assault.Stage = 3;

			elseif Assault.Stage == 2 then
				local charge = Assault.Ordered
				Assault.Text = ""..charge.name.."";
				Assault.Timer = charge.time + CurTime();
				Assault.Stage = 3;
				
			elseif Assault.Stage == 3 then
				Assault.Text = "RTB";
				Assault.Timer = Assault.FallbackTime + CurTime();
				Assault.Stage = 0;
			end;

			for _, ply in pairs(player.GetAll()) do
				ply:SendLua("LocalPlayer().Assault = {}");
				ply:SendLua("LocalPlayer().Assault.Text = '"..Assault.Text.."'");
				if isnumber(Assault.Timer) then
					ply:SendLua("LocalPlayer().Assault.Timer = "..Assault.Timer.."");
				else
					ply:SendLua("LocalPlayer().Assault.Timer = '"..Assault.Timer.."'");
				end;
			end;
		end;
	end);

	hook.Add("PlayerInitialSpawn", "asl_connect", function(ply)
		timer.Simple(3, function()
			ply:SendLua("LocalPlayer().Assault = {}");
			ply:SendLua("LocalPlayer().Assault.Text = '"..Assault.Text.."'");

			if isnumber(Assault.Timer) then
				ply:SendLua("LocalPlayer().Assault.Timer = "..Assault.Timer.."");
			else
				ply:SendLua("LocalPlayer().Assault.Timer = '"..Assault.Timer.."'");
			end;
		end);
	end);

	local function asl_order(ply, cmd, args)
		if !table.HasValue(Assault.Admins,ply:GetUserGroup()) then
			return ply:SendLua('chat.AddText(Color(255,0,0), "War System:", Color(255,255,255), " You do not have permissions.")')
		end;

		if Assault.Stage == 3 then
			return ply:SendLua('chat.AddText(Color(255,0,0), "War System:", Color(255,255,255), " War is in progress.")')
		end;

		local name = args[1];
		local time = 1;
		for k, v in pairs(Assault.Charges) do
			if string.lower(v.name) == string.lower(name) then
				time = v.time;
			end;
		end;
		Assault.Timer = 0;
		Assault.Stage = 2;
		Assault.Ordered = {
			name = name,
			time = time
		}
	end;

	local function asl_stop(ply, cmd, args)
		if !table.HasValue(Assault.Admins,ply:GetUserGroup()) then
			return ply:SendLua('chat.AddText(Color(255,0,0), "War System:", Color(255,255,255), " You do not have permissions.")')
		end;

		if Assault.Stage == 0 then
			return ply:SendLua('chat.AddText(Color(255,0,0), "War System:", Color(255,255,255), " There is no War.")')
		end;

		Assault.Timer = 0; 
		Assault.Stage = 3;
	end;
	
	local function asl_peace(ply, cmd, args)
		if !table.HasValue(Assault.Admins,ply:GetUserGroup()) then
			return ply:SendLua('chat.AddText(Color(255,0,0), "War System:", Color(255,255,255), " You do not have permissions.")')
		end;


		Assault.Timer = 0; 
		Assault.Stage = 0;
	end;

	local function asl_changetimer(ply, cmd, args)
		if !table.HasValue(Assault.Admins,ply:GetUserGroup()) then
			return ply:SendLua('chat.AddText(Color(255,0,0), "War System:", Color(255,255,255), " You do not have permissions.")')
		end;

		if Assault.Stage != 1 then
			return ply:SendLua('chat.AddText(Color(255,0,0), "War System:", Color(255,255,255), " This time is not for prepairing.")')
		end;

		Assault.Timer = 0; 
		Assault.Stage = 0;
		Assault.ChangedTimer = args[1]*60;
	end;

	concommand.Add("asl_order", asl_order)	
	concommand.Add("asl_stop", asl_stop)
	concommand.Add("asl_changetimer", asl_changetimer)
	concommand.Add("asl_peace", asl_peace)
end;

if CLIENT then
	local font = surface.CreateFont("typewriterww1font", {
		font = "Segoe UI",
		size = 84,
		weight = 0
	})

	function AssaultPlaySound(value, volume)
		if !LocalPlayer().Assault.sound then
			LocalPlayer().Assault.sound = CreateSound(LocalPlayer(), value)
			LocalPlayer().Assault.sound:Play()
			LocalPlayer().Assault.sound:ChangeVolume(volume)
		else
			LocalPlayer().Assault.sound:Play()
			LocalPlayer().Assault.sound:ChangeVolume(volume)
		end;
	end;
	function AssaultStopSound()
		if LocalPlayer().Assault.sound and LocalPlayer().Assault.sound:IsPlaying() then
			LocalPlayer().Assault.sound:Stop()
		end;
	end;
	hook.Add("HUDPaint", "asl_paint", function() 
		if LocalPlayer().Assault then
			local color = {0.5, 0.5, 0.28, 0.95};
			local text = LocalPlayer().Assault.Text;
			local time = LocalPlayer().Assault.Timer;

			local find = string.lower(text);
			if string.find(find, "british") then
				color = {0.11, 0.48, 0.293, 0.95}
			elseif string.find(find, "german") then
				color = {0.22, 0.39, 0.431, 0.95}
			elseif string.find(find, "both") then
				color = {0.4, 0.226, 0.4, 0.95}
			end;

			if string.find(text,"/") then
				local explode = string.Explode("/", text)
				text = explode[1];
				time = explode[2];
			end;

			if isnumber(time) then
				time = string.ToMinutesSeconds(LocalPlayer().Assault.Timer - CurTime());
			end;

			local w1, h1 = surface.GetTextSize(text);
			local w2, h2 = surface.GetTextSize(time);
			local x, y = (ScrW()*0.5)-150, 5;
			local sx, sy = 300, 50;
			local textcolor = Color(255,255,255,255);

			if string.find(text, "WAR") then
				textcolor = Color(255,0,0,255);
			end;

			if string.find(text, "NEUTRAL") then
				textcolor = Color(255,255,0,255);
			end;
			
			if string.find(text, "PEACE") then
				textcolor = Color(127,255,0,255);
			end;
			
			if string.find(text, "RTB") then
				textcolor = Color(29,0,255,255);
			end;




			draw.SimpleTextOutlined( text, "typewriterww1font", (ScrW()*0.91), y+1, textcolor, 1, 0, 0.5, Color(0,0,0) )
		end;
	end);

	local function asl_menu(ply, cmd, args)
		local admins = {"superadmin", "admin", "servermanager", "deputyservermanager"};

		local text = string.Implode(" ", args);
		local ply = LocalPlayer();

		if !table.HasValue(admins,ply:GetUserGroup()) then
			return chat.AddText(Color(255,0,0), "War System:", Color(255,255,255), " You do not have permissions.")
		end;

		ply.asl_request = vgui.Create( "DFrame" );
		ply.asl_request:SetSize( 300, 250 );
		ply.asl_request:SetTitle( "War System" );
		ply.asl_request:SetVisible( true );
		ply.asl_request:SetDraggable( true );
		ply.asl_request:ShowCloseButton( true );
		ply.asl_request:MakePopup();
		ply.asl_request:Center();
		ply.asl_request.Paint = function(self, w, h)
			draw.RoundedBox( 0, 0, 0, w, h, Color( 72, 72, 72, 250 ) )
			draw.RoundedBox( 0, 0, 0, w, 25, Color( 109, 109, 109, 250 ) )
		end

			ply.asl_request.british = vgui.Create( "DButton", ply.asl_request )
			ply.asl_request.british:SetText( "Order War" )
			ply.asl_request.british:SetTextColor( Color( 255, 255, 255 ) )
			ply.asl_request.british:SetPos( 25, 35 )
			ply.asl_request.british:SetSize( 250, 30 )
			ply.asl_request.british.Paint = function( self, w, h )
				draw.RoundedBox( 0, 0, 0, w, h, Color( 41, 128, 185, 250 ) )
			end
			ply.asl_request.british.DoClick = function()
				RunConsoleCommand("asl_order", "WAR")
			end

			ply.asl_request.german = vgui.Create( "DButton", ply.asl_request )
			ply.asl_request.german:SetText( "Order Neutrality" )
			ply.asl_request.german:SetTextColor( Color( 255, 255, 255 ) )
			ply.asl_request.german:SetPos( 25, 75 )
			ply.asl_request.german:SetSize( 250, 30 )
			ply.asl_request.german.Paint = function( self, w, h )
				draw.RoundedBox( 0, 0, 0, w, h, Color( 41, 128, 185, 250 ) )
			end
			ply.asl_request.german.DoClick = function()
				RunConsoleCommand("asl_order", "NEUTRAL")
			end

		
			ply.asl_request.stop = vgui.Create( "DButton", ply.asl_request )
			ply.asl_request.stop:SetText( "Stop Event." )
			ply.asl_request.stop:SetTextColor( Color( 255, 255, 255 ) )
			ply.asl_request.stop:SetPos( 25, 125 )
			ply.asl_request.stop:SetSize( 250, 30 )
			ply.asl_request.stop.Paint = function( self, w, h )
				draw.RoundedBox( 0, 0, 0, w, h, Color( 255, 0, 0, 250 ) )
			end
			ply.asl_request.stop.DoClick = function()
				RunConsoleCommand("asl_stop")
			end
			
			
		
			ply.asl_request.stop = vgui.Create( "DButton", ply.asl_request )
			ply.asl_request.stop:SetText( "Order Peace." )
			ply.asl_request.stop:SetTextColor( Color( 255, 255, 255 ) )
			ply.asl_request.stop:SetPos( 25, 165 )
			ply.asl_request.stop:SetSize( 250, 30 )
			ply.asl_request.stop.Paint = function( self, w, h )
				draw.RoundedBox( 0, 0, 0, w, h, Color( 255, 0, 0, 250 ) )
			end
			ply.asl_request.stop.DoClick = function()
				RunConsoleCommand("asl_peace")
			end

			
	end;

	concommand.Add("war_menu", asl_menu)
end;