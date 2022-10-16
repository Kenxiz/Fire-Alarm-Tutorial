-- Transponder1 Script

trans = script.Parent
system = trans.Parent

input = ""
capacity = 0
numpaden = false
numprefix = ""
home = true
locked = false

newalarm = ""
an = 1
ap = 0
tn = 1
tp = 0
trtr = false

econ = nil

-- Display Handling
function HomeDisplay()
	if econ~=nil then econ:disconnect() econ = nil end
	home = true
	ap = 0
	tp = 0
	an = 1
	tn = 1
	input = ""
	capacity = 0
	numpaden = false
	numprefix = ""
	if system.Reset.Value == true then
	home = false
	newalarm = ""
	trans.Display.Line1.Value = "-------------------------------"
	trans.Display.Line2.Value = "Reset in progress"	
	trans.Display.Line3.Value = "-------------------------------"
	wait (4)
	trans.Display.Line1.Value = "****************"
	trans.Display.Line2.Value = "Reset"
	trans.Display.Line3.Value = "****************"
	return end

	if newalarm~="" then
		trans.Display.Line1.Value = "---- FIRE ALARM ----"
		trans.Display.Line2.Value = newalarm
	elseif #system.ActiveAlarms:GetChildren() == 0 and #system.Troubles:GetChildren() == 0 then
		trans.Display.Line1.Value = "-- System is Ready --"
		trans.Display.Line2.Value = system.Title.Value
	else
		trans.Display.Line1.Value = "---- TROUBLE ----"
		trans.Display.Line2.Value = system.Title.Value		
	end
	trans.Display.Line3.Value = tostring("FA "..#system.ActiveAlarms:GetChildren().." / ".."TR " ..#system.Troubles:GetChildren())
end

-- Button Handling
function NumButtonPress(n)
	if locked then return end
	if not numpaden or string.len(input)>(capacity-1) then return end
	input = tostring(input..n)
	trans.Display.Line3.Value = tostring(numprefix..input)
end

local tclax = trans:GetChildren()
for i = 1, #tclax do
	if string.sub(tclax[i].Name,1,6)=="Button" then
		tclax[i].CD.MouseClick:connect(function() NumButtonPress(string.sub(tclax[i].Name,7)) end)
	end
end

trans.B_Clear.CD.MouseClick:connect(function()
	if locked then return end
	if not numpaden or string.len(input)==0 then return end
	input = string.sub(input,1,(string.len(input)-1))
	trans.Display.Line3.Value = tostring(numprefix..input)
end)

trans.SystemReset.CD.MouseClick:connect(function() if locked then return end system.ResetCommand.Value = true end)
trans.Silence.CD.MouseClick:connect(function() if locked then return end system.SilenceCommand.Value = true end)


function AlarmAck()
	if locked then return end
	if not home then return end
	if econ~=nil then econ:disconnect() econ = nil end
	local alarmfolder = system.ActiveAlarms:GetChildren()
	if #alarmfolder == 0 then an = 1 return end
	if alarmfolder[an]:findFirstChild("Ack")==nil and ap == 0 then
	ap = 1
	elseif ap == 1 then
	ap = 0
	local ackfile = Instance.new("Model")
	ackfile.Name = "Ack"
	ackfile.Parent = alarmfolder[an]
	else
	an = an + 1
	end
	if an>#alarmfolder then an = 1 end
	local al = alarmfolder[an]
	trans.Display.Line1.Value = tostring("FA "..an.."/"..#alarmfolder.." ID "..alarmfolder[an].Name)
	trans.Display.Line2.Value = tostring(alarmfolder[an].DeviceName.Value)
	if alarmfolder[an]:findFirstChild("Ack")==nil then
	trans.Display.Line3.Value = ""
	else
	trans.Display.Line3.Value = "-Acked-"	
	end
end

trans.AlarmAck.CD.MouseClick:connect(AlarmAck)

function TroubleAck()
	if locked then return end
	if not home then return end
	if econ~=nil then econ:disconnect() econ = nil end
	local trofolder = system.Troubles:GetChildren()
	if #trofolder == 0 then tn = 1 return end
	if trofolder[tn]:findFirstChild("Ack")==nil and tp == 0 then
	tp = 1
	elseif tp == 1 then
	tp = 0
	local ackfile = Instance.new("Model")
	ackfile.Name = "Ack"
	ackfile.Parent = trofolder[tn]
	else
	tn = tn + 1
	end
	if tn>#trofolder then tn = 1 end
	local tl = trofolder[tn]
	trans.Display.Line1.Value = tostring("TRBL "..tn.."/"..#trofolder.." ID "..trofolder[tn].ID.Value)
	trans.Display.Line2.Value = tostring(trofolder[tn].Name)
	if trofolder[tn]:findFirstChild("Ack")==nil then
	trans.Display.Line3.Value = trofolder[tn].Condition.Value
	else
	trans.Display.Line3.Value = tostring(trofolder[tn].Condition.Value.." -Acked-")
	end
end

trans.TroAck.CD.MouseClick:connect(TroubleAck)

function TogglePeripheral(id)
	local perp = system.Peripherals:findFirstChild(id)
	if perp == nil then return end
	if perp.Enabled.Value == true then
		perp.Enabled.Value = false
		trans.Display.Line3.Value = tostring("ID "..id.." -Disabled-")
	else
		perp.Enabled.Value = true
		trans.Display.Line3.Value = tostring("ID "..id)
	end
end

function TogglePoint(id)
	local point = system.InitiatingDevices:findFirstChild(id)
	if point == nil then return end
	if system.DisabledPoints:findFirstChild(id)~=nil then
		system.DisabledPoints:findFirstChild(id):Remove()
		trans.Display.Line3.Value = tostring("ID "..id)
	else
		local dism = Instance.new("Model")
		dism.Name = id
		dism.Parent = system.DisabledPoints
		trans.Display.Line3.Value = tostring("ID "..id.." -Disabled-")
	end
end

function FetchDevice()
	trans.Display.Line1.Value = "  -Device Info-"
	if econ~=nil then econ:disconnect() econ = nil end
	if string.sub(input,1,3)=="000" then -- Peripheral
		if system.Peripherals:findFirstChild(input)~=nil then
			trans.Display.Line2.Value = system.Peripherals:findFirstChild(input).DeviceName.Value
			if system.Peripherals:findFirstChild(input).Enabled.Value == true then
			trans.Display.Line3.Value = tostring("ID "..input)				
			else
			trans.Display.Line3.Value = tostring("ID "..input.." -Disabled-")	
			end
			econ = trans.B_EnableDisable.CD.MouseClick:connect(function() if locked then return end  TogglePeripheral(input) end)
		else
			trans.Display.Line2.Value = ""	
			trans.Display.Line3.Value = tostring("ID "..input.." invalid.")			
		end
	elseif string.sub(input,1,2)=="00" then -- Annunciator
		if system:findFirstChild("Annunciator"..string.sub(input,3))~=nil then
			trans.Display.Line2.Value = system:findFirstChild("Annunciator"..string.sub(input,3)).DeviceName.Value
			trans.Display.Line3.Value = tostring("ID "..input)				
		else
			trans.Display.Line2.Value = ""	
			trans.Display.Line3.Value = tostring("ID "..input.." invalid.")
		end			
	elseif string.sub(input,1,1)=="0" then -- Transponder
		if system:findFirstChild("Transponder"..string.sub(input,2))~=nil then
			trans.Display.Line2.Value = system:findFirstChild("Transponder"..string.sub(input,2)).DeviceName.Value
			trans.Display.Line3.Value = tostring("ID "..input)				
		else
			trans.Display.Line2.Value = ""	
			trans.Display.Line3.Value = tostring("ID "..input.." invalid.")			
		end
	else -- Initiating Device
		if system.InitiatingDevices:findFirstChild(input)~=nil then
			trans.Display.Line2.Value = system.InitiatingDevices:findFirstChild(input).DeviceName.Value
			if system.DisabledPoints:findFirstChild(input)~=nil then
				trans.Display.Line3.Value = tostring("ID "..input.."-Disabled-")				
			else
				trans.Display.Line3.Value = tostring("ID "..input)					
			end		
			if econ~=nil then econ:disconnect() econ = nil end
			econ = trans.B_EnableDisable.CD.MouseClick:connect(function()  if locked then return end TogglePoint(input) end)
		else
			trans.Display.Line2.Value = ""	
			trans.Display.Line3.Value = tostring("ID "..input.." invalid.")			
		end		
	end
end

function SelectDevice()
	if not home then return end
	if locked then return end 
	home = false
	numpaden = true
	capacity = 5
	input = ""
	trans.Display.Line1.Value = "-- Select Device --"
	trans.Display.Line2.Value = ""	
	trans.Display.Line3.Value = "Enter ID: "	
	numprefix = "Enter ID: "
	
	econ = trans.B_Enter.CD.MouseClick:connect(function() 
		if locked then return end 
		numpaden = false
		FetchDevice()
		end)
end

trans.B_SelectDevice.CD.MouseClick:connect(SelectDevice)

function FetchOption(n)
	input = ""
	if econ~=nil then econ:disconnect() econ = nil end
	if n == "1" then -- Coding
	trans.Display.Line1.Value = "-- Coding --"
	trans.Display.Line2.Value = "0: Cont  1: Code1  2: MT"	
	trans.Display.Line3.Value = "3: Pulse  4: SlowMT"
	numprefix = "3:Pulse 4:SlowMT  "
	numpaden = true
	capacity = 1
	econ = trans.B_Enter.CD.MouseClick:connect(function()
		if locked then return end 
		if tonumber(input) == nil or tonumber(input)<5 then
		system.Coder.Coding.Value = tonumber(input)
		end
		HomeDisplay()
		end)		
	elseif n == "2" then -- DRILL
	trans.Display.Line1.Value = "Processing"
	wait(3)
	
	system.DrillCommand.Value = true
	elseif n == "3" then -- Drill Timer
	trans.Display.Line1.Value = "~Drill Timer~"
	trans.Display.Line3.Value = "Timer in Progress"
	trans.Display.Line2.Value = "45 Seconds remaining"
	wait (1)
	trans.Display.Line2.Value = "44 Seconds remaining"
	wait (1)
	trans.Display.Line2.Value = "43 Seconds remaining"
	wait (1)
	trans.Display.Line2.Value = "42 Seconds remaining"
	wait (1)
	trans.Display.Line2.Value = "41 Second remaining"
	wait (1)
	trans.Display.Line2.Value = "40 Seconds remaining"
	wait (1)
	trans.Display.Line2.Value = "39 Seconds remaining"
	wait (1)
	trans.Display.Line2.Value = "38 Seconds remaining"
	wait (1)
	trans.Display.Line2.Value = "37 Seconds remaining"
	wait (1)
	trans.Display.Line2.Value = "36 Seconds remaining"
	wait (1)
	trans.Display.Line2.Value = "35 Seconds remaining"
	wait (1)
	trans.Display.Line2.Value = "34 Seconds remaining"
	wait (1)
	trans.Display.Line2.Value = "33 Seconds remaining"
	wait (1)
	trans.Display.Line2.Value = "32 Seconds remaining"
	wait (1)
	trans.Display.Line2.Value = "31 Second remaining"
	wait (1)
	trans.Display.Line2.Value = "30 Seconds remaining"
	wait (1)
	trans.Display.Line2.Value = "29 Seconds remaining"
	wait (1)
	trans.Display.Line2.Value = "28 Seconds remaining"
	wait (1)
	trans.Display.Line2.Value = "27 Seconds remaining"
	wait (1)
	trans.Display.Line2.Value = "26 Seconds remaining"
	wait (1)
	trans.Display.Line2.Value = "25 Seconds remaining"
	wait (1)
	trans.Display.Line2.Value = "24 Seconds remaining"
	wait (1)
	trans.Display.Line2.Value = "23 Seconds remaining"
	wait (1)
	trans.Display.Line2.Value = "22 Seconds remaining"
	wait (1)
	trans.Display.Line2.Value = "21 Second remaining"
	wait (1)
	trans.Display.Line2.Value = "20 Seconds remaining"
	wait (1)
	trans.Display.Line2.Value = "19 Seconds remaining"
	wait (1)
	trans.Display.Line2.Value = "18 Seconds remaining"
	wait (1)
	trans.Display.Line2.Value = "17 Seconds remaining"
	wait (1)
	trans.Display.Line2.Value = "16 Seconds remaining"
	wait (1)
	trans.Display.Line2.Value = "15 Seconds remaining"
	wait (1)
	trans.Display.Line2.Value = "14 Seconds remaining"
	wait (1)
	trans.Display.Line2.Value = "13 Seconds remaining"
	wait (1)
	trans.Display.Line2.Value = "12 Seconds remaining"
	wait (1)
	trans.Display.Line2.Value = "11 Second remaining"
	wait (1)
	trans.Display.Line2.Value = "10 Seconds remaining"
	wait (1)
	trans.Display.Line2.Value = "9 Seconds remaining"
	wait (1)
	trans.Display.Line2.Value = "8 Seconds remaining"
	wait (1)
	trans.Display.Line2.Value = "7 Seconds remaining"
	wait (1)
	trans.Display.Line2.Value = "6 Seconds remaining"
	wait (1)
	trans.Display.Line2.Value = "5 Seconds remaining"
	wait (1)
	trans.Display.Line2.Value = "4 Seconds remaining"
	wait (1)
	trans.Display.Line2.Value = "3 Seconds remaining"
	wait (1)
	trans.Display.Line2.Value = "2 Seconds remaining"
	wait (1)
	trans.Display.Line2.Value = "1 Second remaining"
	wait (1)
	
	system.DrillCommand.Value = true
	
	elseif n == "4" then -- V
	home = false
	numpaden = true
	capacity = 1
	input = ""
	numprefix = "                 "
	trans.Display.Line1.Value = "-- Programming --"
	trans.Display.Line2.Value = "5: LEDtst 6: Exit"	
	trans.Display.Line3.Value = ""
	econ = trans.B_Enter.CD.MouseClick:connect(function() 
		if locked then return end 
		if tonumber(input) == nil or tonumber(input)>6 then
			HomeDisplay()
		else
		numpaden = false
		FetchOption(input)
		end
	end)
	
	elseif n == "5" then -- LEDtst
	system.Reset.Value = true
	wait(4)
	system.Reset.Value = false
	
	else
		HomeDisplay()
	end
end

function OptionMenu()
	if not home then return end
	if locked then return end 
	trans.Display.Line1.Value = "Programming Menu"
	trans.Display.Line2.Value = ""
	trans.Display.Line2.Value = ""
	home = false
	wait (2)
	trans.Display.Line1.Value = "Loading"
	trans.Display.Line2.Value = "Please Wait"
	trans.Display.Line2.Value = ""
	wait(2)
	home = false
	numpaden = true
	capacity = 1
	input = ""
	numprefix = "                 "
	trans.Display.Line1.Value = "-- Programming --"
	trans.Display.Line2.Value = "1: Coding 2: Drill"	
	trans.Display.Line3.Value = "3: DrillTimer 4:V"
	econ = trans.B_Enter.CD.MouseClick:connect(function() 
		if locked then return end 
		if tonumber(input) == nil or tonumber(input)>4 then
			HomeDisplay()
		else
		numpaden = false
		FetchOption(input)
		end
	end)
end

trans.B_Options.CD.MouseClick:connect(OptionMenu)

-- Condition Handling

function NewAlarm(na)
	newalarm = na.DeviceName.Value
	HomeDisplay()
end

system.ActiveAlarms.ChildAdded:connect(NewAlarm)

function NewTrouble()
	if home then
	HomeDisplay()
	end
end

system.Troubles.ChildAdded:connect(NewTrouble)

function TroubleRemoved()
	if home then
	HomeDisplay()
	end
end

system.Troubles.ChildRemoved:connect(TroubleRemoved)

trans.B_Exit.CD.MouseClick:connect(HomeDisplay)

system.Reset.Changed:connect(HomeDisplay)

trans.ChildRemoved:connect(function()
	if trtr then return end
	while system.Reset.Value == true do
		wait()
	end	
	trtr = true
	local file = Instance.new("Model")
	local filex = Instance.new("StringValue")
	local filey = filex:clone()
	filex.Name = "ID"
	filex.Value = tostring("0"..string.sub(trans.Name,12))
	filex.Parent = file
	filey.Name = "Condition"
	filey.Value = "Damaged"
	filey.Parent = file
	file.Name = trans.DeviceName.Value
	file.Parent = system.Troubles
end)

enabled = true



function SendPage()
system.SoundFile.Page.SoundId = tostring("rbxassetid://"..input)
wait()
system.SoundCont.Value = "Page"
end

function VoiceButton(b)

if b.Name == "B_Page" then

	if not home then return end
	home = false
	numpaden = true
	capacity = 19
	input = ""
	trans.Display.Line1.Value = "-- Enter SoundId --"
	trans.Display.Line2.Value = ""	
	trans.Display.Line3.Value = ""	
	numprefix = ""
	
	econ = trans.B_Enter.CD.MouseClick:connect(function() 
		 
			SendPage()
		end)

return end
system.SoundCont.Value = string.sub(b.Name,3)
end

local vb = trans.VoiceEvac:GetChildren()

for i = 1, #vb do
	vb[i].CD.MouseClick:connect(function() VoiceButton(vb[i]) end)
end

HomeDisplay()

trans.PowerLED.BrickColor = BrickColor.new("Lime green")
