util.AddNetworkString( "tipSend" )

local tipQueue = {}
local curTime = CurTime
local nextTip = curTime()

function sendTip( text, dur, col, pip, pos )

	net.Start( "tipSend" )
	net.WriteString( text )
	net.WriteUInt( dur, 8 )
	net.WriteColor( col )
	net.WriteUInt( pip, 6 )
	net.WriteUInt( pos, 4 )
	net.Broadcast()

end

function createTip( text, delay, dur, col, pip, pos )

	timer.Create( tostring( math.Rand( 1, 1000 ) ), delay, 0, function()
	
		queueTip( text, dur, col, pip, pos )
		checkQueue()
		
	end )

end

function queueTip( text, dur, col, pip, pos )

	table.insert( tipQueue, { text = text, dur = dur, col = col, pip = pip, pos = pos } )

end

function checkQueue()

	if tipQueue[1] and nextTip < curTime() then
		
		nextTip = curTime() + tipQueue[1].dur
		
		sendTip( tipQueue[1].text, tipQueue[1].dur, tipQueue[1].col, tipQueue[1].pip, tipQueue[1].pos )
		
		timer.Simple( tipQueue[1].dur + 0.5, function() checkQueue() end )
		
		table.remove( tipQueue, 1 )
		
	end

end
