--!strict
---------
--[[ Information:
		○ Author: @EgizianoEG
		○ About:
			- An extended library made for Instance Utility.
]]
------------------------------------------------------------------------------------|
local Wait = {}
local Append = function(t, v) t[#t+1] = v end
----------------------------------------------

--[[ WaitForChildWhichIsA - Waits for a child of the given ancestor instance to be added and its "IsA" returns true using specified class name.
-| @param	Ancestor: The instance to check for children.
-| @param	ClassName: The class name to check for.
-| @param	TimeOut (Optional): time in seconds to wait before returning nil. If not provided, the function will yield indefinitely until a matching child is found.
-| @return	The first child instance with the specified class name, or nil if a timeout occurs or no matching child is found.]]
function Wait.WaitForChildWhichIsA(Ancestor: Instance, ClassName: string, TimeOut: number?)
	assert(typeof(Ancestor) == "Instance", "Invalid Argument [1]; Instance expected.")
	assert(type(ClassName) == "string", "Invalid Argument [2]; String expected.")
	assert(type(TimeOut) == "number" or TimeOut == nil, "Invalid Argument [3]; Number expected.")
	---------------------------------------------------------------------------------------------|

	local Instance = Ancestor:FindFirstChildWhichIsA(ClassName)
	if Instance then return Instance end
	local InitiationTime = tick()
	local WarningTask: thread

	if not TimeOut then
		WarningTask = task.delay(10, function()
			warn(string.format("Infinite yield possible on '%s:WaitForChildWhichIsA(\"%s\")'", Ancestor:GetFullName(), ClassName))
		end)
		repeat
			Instance = Ancestor.ChildAdded:Wait()
		until Instance ~= nil and Instance:IsA(ClassName)
	else
		local Task = task.spawn(function()
			repeat
				local Child = Ancestor.ChildAdded:Wait()
				if Child:IsA(ClassName) then Instance = Child end
			until Instance ~= nil
		end)
		repeat task.wait()
		until Instance ~= nil or (tick() - InitiationTime) >= TimeOut
		task.cancel(Task)
	end

	if WarningTask then task.cancel(WarningTask) end
	return Instance
end

--[[ WaitForChildOfClass - Waits for a child of the given ancestor instance to be added and its "ClassName" property is the same as the specified class name.
-| @param	Ancestor: The instance to check for children.
-| @param	ClassName: The class name to check for.
-| @param	TimeOut (Optional): time in seconds to wait before returning nil. If not provided, the function will yield indefinitely until a matching child is found.
-| @return	The first child instance with the specified class name, or nil if a timeout occurs or no matching child is found.]]
function Wait.WaitForChildOfClass(Ancestor: Instance, ClassName: string, TimeOut: number?)
	assert(typeof(Ancestor) == "Instance", "Invalid Argument [1]; Instance expected.")
	assert(type(ClassName) == "string", "Invalid Argument [2]; String expected.")
	assert(type(TimeOut) == "number" or TimeOut == nil, "Invalid Argument [3]; Number expected.")
	--------------------------------------------------------------------------------------------|

	local Instance = Ancestor:FindFirstChildOfClass(ClassName)
	if Instance then return Instance end
	local InitiationTime = tick()
	local WarningTask: thread

	if not TimeOut then
		WarningTask = task.delay(10, function()
			warn(string.format("Infinite yield possible on '%s:WaitForChildWhichOfClass(\"%s\")'", Ancestor:GetFullName(), ClassName))
		end)
		repeat
			Instance = Ancestor.ChildAdded:Wait()
		until Instance ~= nil and Instance.ClassName == ClassName
	else
		local Task = task.spawn(function()
			repeat
				local Child = Ancestor.ChildAdded:Wait()
				if Child.ClassName == ClassName then Instance = Child end
			until Instance ~= nil
		end)
		repeat task.wait()
		until Instance ~= nil or (tick() - InitiationTime) >= TimeOut
		task.cancel(Task)
	end

	if WarningTask then task.cancel(WarningTask) end
	return Instance
end

--[[ WaitForChildren - Waits for the children of a given ancestor instance with the specified names to exist.
-| @param   Ancestor: The ancestor instance to check the children of.
-| @param   ChildrenNames: An array of strings representing the names of the children to wait for.
-| @param   TimeOut (Optional): The maximum time in seconds to wait for the children to exist. Defaults to 9e9.
-| @param   SingleInstanceTimout (Optional): The maximum time in seconds to wait for a single instance. Defaults to infinity.
-| @return  An array of the children instances that were found.
-| @return  A boolean indicating if the function has timed out or not.]]
function Wait.WaitForChildren(Ancestor: Instance, ChildrenNames: {string}, TimeOut: number?, SingleInstanceTimout: number?)
	assert(typeof(Ancestor) == "Instance", "Invalid Argument [1]; Ancestor argument must be an instance.")
	assert(type(ChildrenNames) == "table", "Invalid Argument [2]; ChildrenNames argument must be an array.")
	assert(type(TimeOut) == "number" or TimeOut == nil, "Invalid Argument [3]; Number expected.")
	assert(type(SingleInstanceTimout) == "number" or SingleInstanceTimout == nil, "Invalid Argument [4]; Number expected.")
	----------------------------------------------------------------------------------------------------------------------|

	TimeOut = (TimeOut or 9e9)
	local Children = {}
	local WaitingTask
	local TimeoutTask
	local TimedOut = false
	local Completed = false

	TimeoutTask = task.delay(TimeOut, function()
		if WaitingTask then
			TimedOut = true
			Completed = true
			task.cancel(WaitingTask)
		end
	end)

	WaitingTask = task.spawn(function()
		for _, ChildName in ipairs(ChildrenNames) do
			local Child = Ancestor:WaitForChild(ChildName, SingleInstanceTimout)
			if Child then
				Append(Children, Child)
			end
		end
		if TimeoutTask then
			task.cancel(TimeoutTask)
		end
		Completed = true
	end)

	repeat
		task.wait()
	until Completed

	return Children, TimedOut
end

--[[ WaitForHierarchy - Finds and returns the instances specified in the `HierarchyTable` parameter in the given `Ancestor` instance. If the `TimeOut` parameter is given, the function will stop searching after the specified time.
-| @param   Ancestor: The instance to search in.
-| @param   HierarchyTable: A table representing the hierarchy to find, with string keys representing instance names and table values representing nested hierarchies. Number keys and string values represent leaf nodes.
-| @param   TimeOut (Optional): The time, in seconds, to search for the instances before stopping and returning. If not given, the search will continue indefinitely.
-| @param   SingleInstanceTimout (Optional): The time, in seconds, to wait for a single instance before giving up and moving on to the next. If not given, the default value is infinity.
-| @return  The found instances organized in a hierarchy matching the structure of the `HierarchyTable` parameter.
-| @return  boolean Whether the search timed out before completing.]]
function Wait.WaitForHierarchy(Ancestor: Instance, HierarchyTable: {[string|number]: string | {any}}, TimeOut: number?, SingleInstanceTimout: number?): ({Instance} | {}, boolean)
	assert(typeof(Ancestor) == "Instance", "Invalid Argument [1]; Ancestor argument must be an instance.")
	assert(type(HierarchyTable) == "table", "Invalid Argument [2]; TreeTable argument must be a valid table.")
	assert(type(TimeOut) == "number" or TimeOut == nil, "Invalid Argument [3]; Number expected.")
	assert(type(SingleInstanceTimout) == "number" or SingleInstanceTimout == nil, "Invalid Argument [4]; Number expected.")
	----------------------------------------------------------------------------------------------------------------------|

	local TimeOut = (TimeOut or 9e9)
	local InitiationTime = tick()
	local InstanceTree = {} :: {[number|Instance]: (Instance|{any})}
	local WaitingTask
	local TimeoutTask
	local Completed = false
	local TimedOut = false

	TimeoutTask = task.delay(TimeOut, function()
		if WaitingTask then
			task.cancel(WaitingTask)
			TimedOut = true
			Completed = true
		end
	end)

	WaitingTask = task.spawn(function()
		for Key, Value in pairs(HierarchyTable) do
			local KeyType, ValType = type(Key), type(Value)
			if KeyType == "number" and ValType == "string" then
				local Object = Ancestor:WaitForChild(Value::string, SingleInstanceTimout)
				if Object then
					Append(InstanceTree::any, Object)
				end
			elseif KeyType == "string" and ValType == "table" then
				local SubAncestor = Ancestor:WaitForChild(Key::string, SingleInstanceTimout)
				if SubAncestor then
					local Children = Wait.WaitForHierarchy(SubAncestor, Value::any, TimeOut - (tick() - InitiationTime), SingleInstanceTimout)
					if Children then
						InstanceTree[SubAncestor] = Children
					else
						Append(InstanceTree::any, SubAncestor)
					end
				end
			end
		end
		if TimeoutTask then
			task.cancel(TimeoutTask)
		end
		Completed = true
	end)

	repeat
		task.wait()
	until Completed

	return InstanceTree, TimedOut
end

-----------
return Wait