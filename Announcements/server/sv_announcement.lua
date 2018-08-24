

local PRINT_IN_CHAT = true

local BACKGROUND_ENABLED = 0

local ANNOUNCEMENT_COMMAND = "!announce"


resource.AddFile( "resource/fonts/ColabReg.ttf" )

print( "Player Login Message has started." )
util.AddNetworkString( "announcetest" )

hook.Add( "PlayerAmmouncement", "announcetest", function( ply, text )
    if ply:GetUserGroup() == "superadmin" then
        local command = string.Explode( " ", text )
        if string.lower(command[1]) == ANNOUNCEMENT_COMMAND then
            local playerNick = ply:Nick()
            local playerSteamID = ply:SteamID()
            local timeInSeconds = tonumber(command[2])
            local announcementMessage = string.gsub( text, ANNOUNCEMENT_COMMAND .. " " .. command[2] .. " ","")
            print( announcementMessage )
            print( playerNick .. " : " .. announcementMessage )
            net.Start( "announcetest" )
                net.WriteString( playerNick )
                net.WriteString( announcementMessage )
                net.WriteInt( BACKGROUND_ENABLED, 8 )
                net.WriteInt( timeInSeconds, 8 )
            net.Broadcast()
            if PRINT_IN_CHAT == true then
                for k, v in pairs( player.GetAll() ) do
                    v:ChatPrint( playerNick .. " : " .. announcementMessage )
                end
            end
		end
	end
end )
