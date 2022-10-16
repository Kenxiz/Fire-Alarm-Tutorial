-- Script in main model

-- System Configuration
VisualUntilReset = true
TwoStage = false
FirstStageTime = 15
-- End of Configuration

system = script.Parent
damaged = {}
dp = {}
fs = false

function AlarmCondition(device)
	while system.Reset.Value == true do
		wait()
	end
	if device.Alarm.Value == false then return end
	-- Check if point is disabled or already in alarm
	if system.ActiveAlarms:findFirstChild(device.Name)~=nil then return end
	local dis = system.DisabledPoints:GetChildren()
	for i = 1, #dis do
		if dis[i].Name == device.Name then return end
	end
	-- Insert into the alarm database
	local file = Instance.new("Model")
	local filex = Instance.new("StringValue")
	filex.Name = "DeviceName"
	filex.Value = device.DeviceName.Value
	filex.Parent = file
	file.Name = device.Name
	file.Parent = system.ActiveAlarms
	system.Silence.Value = false
	system.Coder.VisualRelay.Disabled = false
	if TwoStage and not fs then
		fs = true
		system.Coder.PreAlarm.Disabled = false
		local ftime = 0
		while not system.Reset.Value and not system.Silence.Value and fs and ftime < FirstStageTime do
			ftime = ftime + 0.1
			wait(0.1)
		end
		if not system.Reset.Value and not system.Silence.Value and ftime >= FirstStageTime then
		system.Coder.AudibleCircuit.Value = 0
		system.Coder.PreAlarm.Disabled = true
		system.Coder.AudibleRelay.Disabled = false
		end
	else
		system.Coder.PreAlarm.Disabled = true
		system.Coder.AudibleRelay.Disabled = false
	end
end

function TroubleCondition(device)
	while system.Reset.Value == true do
		wait()
	end	
	for i = 1, #damaged do
		if damaged[i]==device then return end
	end
	table.insert(damaged, device)
	local file = Instance.new("Model")
	local filex = Instance.new("StringValue")
	local filey = filex:clone()
	filex.Name = "ID"
	filex.Value = device.Name
	filex.Parent = file
	filey.Name = "Condition"
	filey.Value = "Damaged"
	filey.Parent = file
	file.Name = device.DeviceName.Value
	file.Parent = system.Troubles
end

function ResetSystem()
	if system.Reset.Value == false and system.ResetCommand.Value == true then
	system.ResetCommand.Value = false
	system.Reset.Value = true
	system.Silence.Value = false
	system.Coder.AudibleRelay.Disabled = true
	system.Coder.PreAlarm.Disabled = true
	system.Coder.AudibleCircuit.Value = 0
	system.Coder.VisualRelay.Disabled = true
	system.Coder.VisualCircuit.Value = 0
	local af = system.ActiveAlarms:GetChildren()
	for i = 1, #af do
		af[i]:Remove()
	end
	local tf = system.Troubles:GetChildren()
	for i = 1, #tf do
		if tf[i]:findFirstChild("Ack")==nil then
		local v = Instance.new("Model")
		v.Name = "Ack"
		v.Parent = tf[i]
		end
	end
	wait(10)
	fs = false
	tf = system.Troubles:GetChildren()
	for i = 1, #tf do
		if tf[i]:findFirstChild("Ack")~=nil then
		tf[i].Ack:Remove()
		end
	end
	system.Reset.Value = false	
	local idc = system.InitiatingDevices:GetChildren()
	for i = 1, #idc do
		if idc[i].Alarm.Value == true then
			AlarmCondition(idc[i])
		end
	end
	else
	system.ResetCommand.Value = false		
	end
end

system.ResetCommand.Changed:connect(ResetSystem)

function SilenceSignals()
	if system.SilenceCommand.Value == true and
	(system.Coder.AudibleRelay.Disabled == false or system.Coder.PreAlarm.Disabled == false) then
	system.SilenceCommand.Value = false
	system.Silence.Value = true
	system.Coder.AudibleRelay.Disabled = true
	system.Coder.PreAlarm.Disabled = true
	system.Coder.AudibleCircuit.Value = 0
	if VisualUntilReset then return end
	system.Coder.VisualRelay.Disabled = true
	system.Coder.VisualCircuit.Value = 0
	local af = system.ActiveAlarms:GetChildren()
	for i = 1, #af do
		af[i]:Remove()
	end
	local tf = system.Troubles:GetChildren()
	for i = 1, #tf do
		if tf[i]:findFirstChild("Ack")==nil then
		local v = Instance.new("Model")
		v.Name = "Ack"
		v.Parent = tf[i]
		end
	end
	wait(10)
	fs = false
	tf = system.Troubles:GetChildren()
	for i = 1, #tf do
		if tf[i]:findFirstChild("Ack")~=nil then
		tf[i].Ack:Remove()
		end
	end
	system.Reset.Value = false	
	local idc = system.InitiatingDevices:GetChildren()
	for i = 1, #idc do
		if idc[i].Alarm.Value == true then
			AlarmCondition(idc[i])
		end
	end
	else 
	system.SilenceCommand.Value = false
	end
end

system.SilenceCommand.Changed:connect(SilenceSignals)

function Drill()
	if system.DrillCommand.Value == true and #system.ActiveAlarms:GetChildren()==0 then
	system.DrillCommand.Value = false
	local file = Instance.new("Model")
	local filex = Instance.new("StringValue")
	filex.Name = "DeviceName"
	filex.Value = "DRILL"
	filex.Parent = file
	file.Name = "01"
	file.Parent = system.ActiveAlarms
	system.Silence.Value = false
	system.Coder.PreAlarm.Disabled = true
	system.Coder.AudibleRelay.Disabled = false
	system.Coder.VisualRelay.Disabled = false
	fs = true
	wait(120) --- Change this to how long you want the drill to be.
	system.Silence.Value = true
	system.Coder.AudibleRelay.Disabled = true
	system.Coder.PreAlarm.Disabled = true
	system.Coder.AudibleCircuit.Value = 0
	system.Coder.VisualRelay.Disabled = true
	system.Coder.VisualCircuit.Value = 0
	system.Reset.Value = true
	local af = system.ActiveAlarms:GetChildren()
	for i = 1, #af do
		af[i]:Remove()
	end
	local tf = system.Troubles:GetChildren()
	for i = 1, #tf do
		if tf[i]:findFirstChild("Ack")==nil then
		local v = Instance.new("Model")
		v.Name = "Ack"
		v.Parent = tf[i]
		end
	end
	wait(10)
	fs = false
	tf = system.Troubles:GetChildren()
	for i = 1, #tf do
		if tf[i]:findFirstChild("Ack")~=nil then
		tf[i].Ack:Remove()
		end
	end
	system.Reset.Value = false	
	local idc = system.InitiatingDevices:GetChildren()
	for i = 1, #idc do
		if idc[i].Alarm.Value == true then
			AlarmCondition(idc[i])
	system.Reset.Value = true
	wait(10)
	system.Reset.Valie = false
		end
	end
	else
	system.ResetCommand.Value = false		
	end
end

system.DrillCommand.Changed:connect(Drill)
system.SilenceCommand.Changed:connect(SilenceSignals)


system.DisabledPoints.ChildAdded:connect(function(child)
	local file = Instance.new("Model")
	local filex = Instance.new("StringValue")
	local filey = filex:clone()
	filex.Name = "ID"
	filex.Value = child.Name
	filex.Parent = file
	filey.Name = "Condition"
	filey.Value = "Disabled"
	filey.Parent = file
	file.Name = system.InitiatingDevices:findFirstChild(child.Name).DeviceName.Value
	file.Parent = system.Troubles
end)

system.DisabledPoints.ChildRemoved:connect(function(child)
	if system.InitiatingDevices:findFirstChild(child.Name).Alarm.Value == true then
		AlarmCondition(system.InitiatingDevices:findFirstChild(child.Name))
	end
	local tfile = system.Troubles:GetChildren()
	for i = 1, #tfile do
		if tfile[i].ID.Value == child.Name and tfile[i].Condition.Value == "Disabled" then
			tfile[i]:Remove()
		end
	end
end)

local c = system.InitiatingDevices:GetChildren()

for i = 1, #c do
	c[i].Alarm.Changed:connect(function() if c[i].Alarm.Value == true then AlarmCondition(c[i]) end end)
	c[i].DescendantRemoving:connect(function() TroubleCondition(c[i]) end)
	c[i].ChildRemoved:connect(function() TroubleCondition(c[i]) end)
end
