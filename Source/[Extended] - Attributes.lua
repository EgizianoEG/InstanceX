--!strict
---------
--[[ Information:
		○ Author: @EgizianoEG
		○ About:
			- Attributes. A sub-library made for InstanceX.
			- Made based on Attribute Util by: @RuizuKun_Dev & Devforum Engine Feature Requests.
]]
----------------------------------------------------------------------------------------------------|
local Attributes = {}
---------------------

local warn = function(...) 
	warn("Attributes -", ...) 
end

local SupportedTypes = {
	"nil", "boolean", "number", "string", "Vector2", "Vector3", 
	"UDim", "UDim2", "Rect", "NumberSequence", "Color3", "BrickColor",
	"NumberRange", "ColorSequence", "CFrame", "Font"
}

local IsValidName = function(Name: string)
	return #Name <= 100 and not Name:match("^RBX") and Name:match("^[%w_]+$")
end

local IsValidType = function(Value: string)
	return table.find(SupportedTypes, typeof(Value)) ~= nil
end

local Append = function(t, v)
	t[#t+1] = v
end

--------------------------------------------------------------------------------------------------------------------|
--| Utility Functions:
----------------------
--[[ SetAttributes - Sets the attributes of the given object with the provided attribute-value pairs.
--| @param	Object: The object to set the attributes on.
--| @param	Attributes: A table of attribute-value pairs to set on the object. The keys of the table represent the attribute names, and the values represent the attribute values.
--| @return	None.]]
function Attributes.SetAttributes(Object: Instance, Attributes: {[string]: any})
	assert(typeof(Object) == "Instance", "Invalid Argument [1]; Instance expected for the object argument.")
	assert(typeof(Attributes) == "table", "Invalid Argument [2]; Table expected for the Attributes argument.")
	----------------------------------------------------------------------------------------------------------

	for Attribute, Value in pairs(Attributes) do
		if IsValidName(Attribute) then
			if IsValidType(Value) then
				Object:SetAttribute(Attribute, Value)
			else
				warn(string.format("[SetAttributes] The given attribute value type \"%s\" is not supported.", typeof(Value)))
			end
		else
			warn(string.format("[SetAttributes] The given attribute name \"%s\" contains illegal character(s).", Attribute))
		end
	end
end

--[[ UpdateAttribute - Updates the value of the given attribute on the given object with the result of the provided callback function.
--| @param	Object: The object to update the attribute on.
--| @param	Attribute: The name of the attribute to update.
--| @param	Callback: A function that takes in the current attribute value and returns the updated attribute value.
--| @return	None.]]
function Attributes.UpdateAttribute(Object: Instance, Attribute: string, Callback: (any) -> any)
	assert(typeof(Object) == "Instance", "Invalid Argument [1]; Instance expected for the object argument.")
	assert(typeof(Attribute) == "string", "Invalid Argument [2]; String expected for the Attribute argument.")
	assert(typeof(Callback) == "function", "Invalid Argument [3]; Function expected for the callback argument.")
	------------------------------------------------------------------------------------------------------------

	local Value = Object:GetAttribute(Attribute)
	if Value then
		local Updated = Callback(Value)
		Object:SetAttribute(Attribute, (Updated or Value))
	else
		warn("[UpdateAttribute] Couldn't find the given attribute.")
	end
end

--[[ IncrementAttribute - Increments the value of the given attribute on the given object by the provided amount.
--| @param	Object The object to increment the attribute on.
--| @param	Attribute The name of the attribute to increment.
--| @param	Increment The amount to increment the attribute by. Can be a number or a string that can be converted to a number using the `tonumber` function.
--| @return	The updated value of the attribute.]]
function Attributes.IncrementAttribute(Object: Instance, Attribute: string, Increment: (number | string))
	assert(typeof(Object) == "Instance", "Invalid Argument [1]; Instance expected for the object argument.")
	assert(typeof(Attribute) == "string", "Invalid Argument [2]; String expected for the Attribute argument.")
	assert(typeof(Increment) == "number" or tonumber(Increment), "Invalid Argument [3]; Number expected for the Increment argument.")
	----------------------------------------------------------------------------------------------------------

	local Value = Object:GetAttribute(Attribute)
	if Value then
		if tonumber(Value) then
			Object:SetAttribute(Attribute, Value + Increment)
			return Value + Increment
		else
			warn("[IncrementAttribute] The given attribute can't be incremented.")
		end
	else
		warn("[IncrementAttribute] Couldn't find the given attribute.")
	end
	return nil
end

--[[ Finds the nearest ancestor of the given object that has the specified attribute.
--| @param	Object: The object to start searching from.
--| @param	Attribute: The name of the attribute to search for.
--| @param	ValueCondition: An optional function that takes in a value and returns a boolean indicating whether the value meets the desired condition.
--| @return	The ancestor with the attribute, or nil if no ancestor was found.
--| @return	The ancestor's attribute value.]]
function Attributes.FindFirstAncestorWithAttribute(Object: Instance, Attribute: string, ValueCondition: ((any) -> boolean)?): (Instance?, any?)
	assert(typeof(Object) == "Instance", "Invalid Argument [1]; Instance expected for the object argument.")
	assert(typeof(Attribute) == "string", "Invalid Argument [2]; String expected for the Attribute argument.")
	assert(typeof(ValueCondition) == "function" or ValueCondition == nil, "Invalid Argument [3]; Function expected for the ValueCondition argument.")
	------------------------------------------------------------------------------------------------------------------------------------------------|

	local LastAncestor = Object.Parent
	while LastAncestor do
		local AttributeValue = LastAncestor:GetAttribute(Attribute)
		if AttributeValue then
			if ValueCondition then
				if ValueCondition(AttributeValue) then
					return LastAncestor, AttributeValue
				end
			else
				return LastAncestor, AttributeValue
			end
		else
			LastAncestor = LastAncestor.Parent
		end
	end
	return nil, nil
end

--[[ FindFirstChildWithAttribute - Finds the first child of the given ancestor with the specified attribute and value.
--| @param	Ancestor: The ancestor object to search in.
--| @param	Attribute: The attribute to search for. Can be a string or an array of strings.
--| @param	ValueCondition: An optional function that takes in a value and returns a boolean indicating whether the value meets the desired condition.
--| @return	The first child with one of the attributes, or nil if no child was found.
--| @return	The value of the attribute for the found child, or nil if no such child was found.]]
function Attributes.FindFirstChildWithAttribute(Ancestor: Instance, Attribute: (string | {string}), ValueCondition: ((any) -> boolean)?): (Instance?, any?)
	assert(typeof(Ancestor) == "Instance", "Invalid Argument [1]; Instance expected for the Ancestor argument.")
	assert(typeof(Attribute) == "string" or typeof(Attribute) == "table", "Invalid Argument [2]; String/Array expected for the Attribute argument.")
	assert(typeof(ValueCondition) == "function" or ValueCondition == nil, "Invalid Argument [3]; Function expected for the ValueCondition argument.")
	------------------------------------------------------------------------------------------------------------------------------------------------|

	for _, Child:any in ipairs(Ancestor:GetChildren()) do
		if type(Attribute) == "string" then
			local AttributeValue = Child:GetAttribute(Attribute)
			if AttributeValue then
				if ValueCondition then
					if ValueCondition(AttributeValue) then
						return Child, AttributeValue
					end
				else
					return Child, AttributeValue
				end
			end
		elseif type(Attribute) == "table" then
			for _, Attr in ipairs(Attribute) do
				local AttributeValue = Child:GetAttribute(Attr)
				if AttributeValue then
					if ValueCondition then
						if ValueCondition(AttributeValue) then
							return Child, AttributeValue
						end
					else
						return Child, AttributeValue
					end
				end
			end
		end
	end
	return nil, nil
end

--[[ FindFirstDescendantWithAttribute - Finds the first descendant of the given ancestor object that has the specified attribute.
--| @param	Ancestor: The ancestor object to search in.
--| @param	Attribute: The name of the attribute to search for, or an array of attribute names to search for any of them.
--| @param	ValueCondition: An optional function that takes in a value and returns a boolean indicating whether the value meets the desired condition.
--| @return	The first found descendant with the attribute, or nil if no descendant was found.
--| @return	The value of the found descendant's attribute, or nil if no descendant was found.]]
function Attributes.FindFirstDescendantWithAttribute(Ancestor: Instance, Attribute: (string | {string}), ValueCondition: ((any) -> boolean)?): (Instance?, any?)
	assert(typeof(Ancestor) == "Instance", "Invalid Argument [1]; Instance expected for the Ancestor argument.")
	assert(typeof(Attribute) == "string", "Invalid Argument [2]; String expected for the Attribute argument.")
	assert(typeof(ValueCondition) == "function" or ValueCondition == nil, "Invalid Argument [3]; Function expected for the ValueCondition argument.")
	------------------------------------------------------------------------------------------------------------------------------------------------|

	for _, Descendant:any in ipairs(Ancestor:GetDescendants()) do
		if type(Attribute) == "string" then
			local AttributeValue = Descendant:GetAttribute(Attribute)
			if AttributeValue then
				if ValueCondition then
					if ValueCondition(AttributeValue) then
						return Descendant, AttributeValue
					end
				else
					return Descendant, AttributeValue
				end
			end
		elseif type(Attribute) == "table" then
			for _, Attr in ipairs(Attribute) do
				local AttributeValue = Descendant:GetAttribute(Attr)
				if AttributeValue then
					if ValueCondition then
						if ValueCondition(AttributeValue) then
							return Descendant, AttributeValue
						end
					else
						return Descendant, AttributeValue
					end
				end
			end
		end
	end
	return nil, nil
end

--[[ SetMultipleAttributes - Sets the specified attributes for multiple objects.
--| @param	Objects: An array of objects to set the attributes for.
--| @param	Attributes: A table of attributes to set, where the keys are the attribute names and the values are the attribute values.
--| @return	None.]]
function Attributes.SetMultipleAttributes(Objects: {Instance}, Attributes: {[string]: any})
	assert(typeof(Objects) == "table", "Invalid Argument [1]; Array expected for the Objects argument.")
	assert(typeof(Attributes) == "table", "Invalid Argument [2]; Table expected for the Attributes argument.")
	----------------------------------------------------------------------------------------------------------

	for Attribute, Value in pairs(Attributes) do
		if not IsValidName(Attribute) or not IsValidType(Value) then
			Attributes[Attribute] = nil
			warn(string.format("[MultiSetAttributes] The given attribute \"%s\" 's name/value' is not valid. It has been ignored.", Attribute))
		end
	end

	for _, Object in ipairs(Objects) do
		if typeof(Object) == "Instance" then
			for Attribute, Value in pairs(Attributes) do
				Object:SetAttribute(Attribute, Value)
			end
		else
			warn(string.format("[MultiSetAttributes] Provided an invalid type \"%s\" instead of an Instance.", typeof(Object)))
		end
	end
end

--[[ GetChildrenWithAttributes - Returns an array of children of the specified ancestor that have at least one of the specified attributes.
--| @param	Ancestor: The ancestor object to search for children.
--| @param	Attributes: An array of attribute names to search for.
--| @param	ShouldMatchAll: A boolean determining if the child should match ALL of the given attributes or if it should match any of them for once.
--| @return	An array of children that have at least one of the specified attributes.]]
function Attributes.GetChildrenWithAttributes(Ancestor: Instance, Attributes: {string}, ShouldMatchAll: boolean?): {Instance}
	assert(typeof(Ancestor) == "Instance", "Invalid Argument [1]; Instance expected for the Ancestor argument.")
	assert(typeof(Attributes) == "table", "Invalid Argument [2]; Table expected for the Attributes argument.")
	----------------------------------------------------------------------------------------------------------

	local Children = {}
	local Matching = {}::{[Instance]: number}
	local TotalAttr = #Attributes
	for _, Object in ipairs(Ancestor:GetChildren()) do
		for _, Attribute in ipairs(Attributes) do
			local AttrValue = Object:GetAttribute(Attribute)
			if AttrValue then
				if not ShouldMatchAll then
					Append(Children, Object)
					break
				else
					if Matching[Object] == TotalAttr then
						Append(Children, Object)
						break
					else
						Matching[Object] += 1
					end
				end
			else
				if ShouldMatchAll then
					break
				end
			end
		end
	end
	return Children
end

--[[ GetDescendantsWithAttributes - Returns an array of descendants of the specified ancestor that have at least one of the specified attributes.
--| @param	Ancestor: The ancestor object to search for descendants.
--| @param	Attributes: An array of attribute names to search for.
--| @param	ShouldMatchAll: A boolean determining if the descendant should match ALL of the given attributes or if it should match any of them for once.
--| @return	An array of descendants that have at least one of the specified attributes.]]
function Attributes.GetDescendantsWithAttributes(Ancestor: Instance, Attributes: {string}, ShouldMatchAll: boolean?): {Instance}
	assert(typeof(Ancestor) == "Instance", "Invalid Argument [1]; Instance expected for the Ancestor argument.")
	assert(typeof(Attributes) == "table", "Invalid Argument [2]; Table expected for the Attributes argument.")
	----------------------------------------------------------------------------------------------------------

	local Descendants = {}
	local Matching = {}::{[Instance]: number}
	local TotalAttr = #Attributes
	for _, Object in ipairs(Ancestor:GetDescendants()) do
		for _, Attribute in ipairs(Attributes) do
			local AttrValue = Object:GetAttribute(Attribute)
			if AttrValue then
				if not ShouldMatchAll then
					Append(Descendants, Object)
					break
				else
					if Matching[Object] == TotalAttr then
						Append(Descendants, Object)
						break
					else
						Matching[Object] += 1
					end
				end
			else
				if ShouldMatchAll then
					break
				end
			end
		end
	end
	return Descendants
end

--[[ WaitForChildWhithAttribute - Waits for a child with a specific attribute and returns it when it's found.
--| @param	Ancestor: The ancestor object to wait for the child.
--| @param	TimeOut (Optional): The maximum amount of time, in seconds, to wait for a child with the specified attribute to be found.
--| @return	The child Instance with the specified attribute, or nil if no such child was found within the specified time limit.]]
function Attributes.WaitForChildWhithAttribute(Ancestor: Instance, Attribute: string, TimeOut: number?): Instance
	assert(typeof(Ancestor) == "Instance", "Invalid Argument [1]; Instance expected for the Ancestor argument.")
	assert(typeof(Attribute) == "string", "Invalid Argument [2]; String expected for the Attribute argument.")
	assert(IsValidName(Attribute), "Invalid attribute name has been given.")
	----------------------------------------------------------------------------------------------------------

	local Instance = Attributes.FindFirstChildWithAttribute(Ancestor, Attribute)
	if Instance then return Instance end
	local InitTime = tick()
	local WarningTask: thread

	if not TimeOut then
		WarningTask = task.delay(10, function()
			warn(string.format("Infinite yield possible on '%s:WaitForChildWhithAttribute(\"%s\")'", Ancestor:GetFullName(), Attribute))
		end)
		while task.wait() do
			Instance = Attributes.FindFirstChildWithAttribute(Ancestor, Attribute)
			if Instance then break end
		end
	else
		local Task = task.spawn(function()
			while task.wait() do
				Instance = Attributes.FindFirstChildWithAttribute(Ancestor, Attribute)
				if Instance then break end
			end
		end)
		repeat task.wait()
		until Instance ~= nil or (tick() - InitTime) >= TimeOut
		task.cancel(Task)
	end

	if WarningTask then task.cancel(WarningTask) end
	return Instance::Instance
end

--[[ ClearAllAttributes - Clears all attributes of the given Object, excluding the ones in the optional Excluded array.
--| @param	Object: The ancestor object to wait for the child.
--| @param	Excluded (Optional): An optional array of attribute names to exclude from clearing.
--| @return	None.]]
function Attributes.ClearAllAttributes(Object: Instance, Excluded: {string}?)
	assert(typeof(Object) == "Instance", "Invalid Argument [1]; Instance expected for the Object argument.")
	assert(typeof(Excluded) == "table" or Excluded == nil, "Invalid Argument [2]; String array expected for the Excepted argument.")
	----------------------------------------------------------------------------------------------------------

	for Attribute, Value in pairs(Object:GetAttributes()) do
		if Excluded then
			if not table.find(Excluded, Attribute) then
				Object:SetAttribute(Attribute, nil)
			end
		else
			Object:SetAttribute(Attribute, nil)
		end
	end
end

-----------------
return Attributes