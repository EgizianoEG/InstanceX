local Clone = {}
----------------
local Append = function(t, v)
	t[#t+1] = v
end
-----------------------------------------------------------------------------------|

--[[ CloneAndParent - Clones and parents the given `Object` to the given `Parent` object.
-| @param   Object: The object to be cloned and parented.
-| @param   Parent (Optional): The parent object to which the cloned object will be parented to.
-| @param   Clones (Optional): The number of clones to be created. Defaults to 1.
-| @return  The cloned object or an array of cloned objects (depends on the `Clones` parameter).]]
function Clone.CloneAndParent(Object: Instance, Parent: Instance?, Clones: number?)
	assert(typeof(Object) == "Instance", "Invalid Argument [1]; Instance expected.")
	assert(typeof(Parent) == "Instance", "Invalid Argument [2]; Instance expected.")
	--------------------------------------------------------------------------------

	Clones = (Clones and math.round(Clones)) or 1
	local ClonedInstances = {}
	for _ = 1, Clones do
		local ClonedInstance = Object:Clone()
		Append(ClonedInstances, ClonedInstance)
		ClonedInstance.Parent = Parent or Object.Parent
	end
	return (Clones > 1 and ClonedInstances) or table.unpack(ClonedInstances)
end

--[[ CloneWithoutChildren - Clones Object and removes all of its children.
-| @param   Object: The object to be cloned and have its children removed.
-| @param   Parent (Optional): The parent of the cloned object. If nil, the cloned object will have the same parent as the original instance.
-| @return  The cloned object with no children.]]
function Clone.CloneWithoutChildren(Object: Instance, Parent: Instance?)
	assert(typeof(Object) == "Instance", "Invalid Argument [1]; Instance expected.")
	assert(typeof(Parent) == "Instance" or Parent == nil, "Invalid Argument [1]; Instance expected.")
	-------------------------------------------------------------------------------------------------

	local ClonedInstance = Object:Clone()
	ClonedInstance:ClearAllChildren()
	ClonedInstance.Parent = Parent or Object.Parent
	return ClonedInstance
end

--[[ CloneWithProperties - Clones `Object` and sets the specified `Properties` to the cloned instances.
-| @param   Object: The object to be cloned.
-| @param   Properties: A table of properties to be set to the cloned instances. The `Parent` property will be ignored and set later for performance purposes.
-| @param   Clones (Optional): The number of clones to create. Default is `1`.
-| @return  If `Clones` is `1`, returns the cloned instance. If `Clones` is greater than `1`, returns an array of the cloned instances.]]
function Clone.CloneWithProperties(Object: Instance, Properties: {[string]: any}, Clones: number?)
	assert(typeof(Object) == "Instance", "Invalid Argument [1]; Instance expected.")
	assert(typeof(Properties) == "table", "Invalid Argument [2]; Table expected.")
	------------------------------------------------------------------------------

	Clones = (Clones and math.round(Clones)) or 1
	local ClonedInstances: {any} = {}
	local Parent = Properties.Parent
	for _ = 1, Clones do
		local ClonedInstance = Object:Clone()
		Append(ClonedInstances, ClonedInstance)
	end

	Properties.Parent = nil
	for Property, Value in pairs(Properties) do
		for _, Instance in ipairs(ClonedInstances) do
			pcall(function()
				Instance[Property] = Value
			end)
		end
	end

	if Parent then
		for _, Instance in ipairs(ClonedInstances) do
			pcall(function()
				Instance.Parent = Parent
			end)
		end
	end
	return (Clones > 1 and ClonedInstances) or table.unpack(ClonedInstances)
end

--[[ CloneToMultiple - Clones an object and parents each clone to a specific set of instances.
-| @param   Object: The object to be cloned.
-| @param   To: An array of instances to parent the clones to.
-| @param   ClonesForEachInstance (Optional): The number of clones to create for each instance in the `To` array. Defaults to 1.
-| @return  An array of the cloned objects.]]
function Clone.CloneToMultiple(Object: Instance, To: {Instance}, ClonesForEachInstance: number?)
	assert(typeof(Object) == "Instance", "Invalid Argument [1]; Instance expected.")
	assert(typeof(To) == "table", "Invalid Argument [2]; Instance array expected.")
	-------------------------------------------------------------------------------

	ClonesForEachInstance = (ClonesForEachInstance and math.round(ClonesForEachInstance)) or 1
	local Clones = {}
	for _, Instance in ipairs(To) do
		for _ = 1, ClonesForEachInstance do
			local Cloned = Object:Clone()
			Append(Clones, Clone)
			Cloned.Parent = Instance
		end
	end
	return Clones
end

------------
return Clone