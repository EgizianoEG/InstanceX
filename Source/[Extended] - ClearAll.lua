--!strict
---------
local Clear = {}
----------------

--[[ ClearAllChildrenWhichAre - Deletes all children of the given `Ancestor` Instance that are of the specified `ClassName`.
-| @param   Ancestor: The Instance whose children will be deleted.
-| @param   ClassName: The class name of the children that will be deleted.
-| @return  number - the number of destroyed instances.]]
function Clear.ClearAllChildrenWhichAre(Ancestor: Instance, ClassName: string)
	assert(typeof(Ancestor) == "Instance", "Invalid Argument [1]; Instance expected.")
	assert(typeof(ClassName) == "string", "Invalid Argument [2]; String expected.")
	-------------------------------------------------------------------------------

	local Destroyed = 0
	for _, Child in ipairs(Ancestor:GetChildren()) do
		if Child:IsA(ClassName) then
			Child:Destroy()
			Destroyed += 1
		end
	end
	return Destroyed
end

--[[ ClearAllDescendantsWhichAre - Clears all descendants of `Ancestor` that are instances of the specified `ClassName`.
-| @param   Ancestor: The ancestor instance whose descendants to clear.
-| @param   ClassName: The class name of the instances to clear.
-| @return  number - the number of destroyed instances.]]
function Clear.ClearAllDescendantsWhichAre(Ancestor: Instance, ClassName: string)
	assert(typeof(Ancestor) == "Instance", "Invalid Argument [1]; Instance expected.")
	assert(typeof(ClassName) == "table", "Invalid Argument [2]; String expected.")
	------------------------------------------------------------------------------

	local Destroyed = 0
	for _, Child in ipairs(Ancestor:GetDescendants()) do
		if Child:IsA(ClassName) then
			Child:Destroy()
			Destroyed += 1
		end
	end
	return Destroyed
end

--[[ ClearAllChildrenExcept - Removes all of the children of the given ancestor instance, except for the ones specified in the Excluded table.
-| @param	Ancestor: The ancestor instance whose children should be removed.
-| @param	Excluded: A table that specifies the children of Ancestor that should be excluded from being destroyed. This table can have three keys:
			    * `Instances`: An array of instance objects or strings representing the names of instances that should not be destroyed.
			    * `Properties`: A table of property-value pairs representing the properties and values that the instances to be preserved must have. If a child's property matches the given value, then that child will be excluded from being destroyed.
			    * `IsA`: A string representing the class name that the instances to be preserved must be an instance of.
-| @return  number - the number of destroyed instances.]]
function Clear.ClearAllChildrenExcept(Ancestor: Instance, Excluded: {[string]: any})
	assert(typeof(Ancestor) == "Instance", "Invalid Argument [1]; Instance expected.")
	assert(typeof(Excluded) == "table", "Invalid Argument [2]; Table expected.")
	----------------------------------------------------------------------------

	local Destroyed = 0
	for _, Child in ipairs(Ancestor:GetChildren()) do
		local ShouldDestroy = true

		if type(Excluded.Instances) == "table" then
			if table.find(Excluded.Instances, Child.Name) or table.find(Excluded.Instances, Child) then
				continue
			end
		end

		if type(Excluded.Properties) == "table" then
			for Property, Value in pairs(Excluded.Properties) do
				local Success, Response = pcall(function()
					return (Child::any)[Property] == Value
				end)
				if not Success or Response ~= true then
					ShouldDestroy = false
					break
				end
			end
		end

		if type(Excluded.IsA) == "string" then
			if Child:IsA(Excluded.IsA) then
				continue
			end
		end

		if ShouldDestroy then
			Child:Destroy()
			Destroyed += 1
		end
	end
	return Destroyed
end

--[[ ClearAllDescendantsExcept - Removes all descendants of an Instance except those specified.
-| @param   Ancestor: The Instance whose descendants will be removed.
-| @param   Excluded: A table that specifies the children of Ancestor that should be excluded from being destroyed. This table can have three keys:
			    * `Instances`: An array of instance objects or strings representing the names of instances that should not be destroyed.
			    * `Properties`: A table of property-value pairs that an instance must have to be excluded from the destruction process.
			    * `IsA`: A string representing the class name that the instances to be preserved must be an instance of.
-| @return  number - the number of destroyed instances.]]
function Clear.ClearAllDescendantsExcept(Ancestor: Instance, Excluded: {[string]: any})
	assert(typeof(Ancestor) == "Instance", "Invalid Argument [1]; Instance expected.")
	assert(typeof(Excepted) == "table", "Invalid Argument [2]; Table expected.")
	----------------------------------------------------------------------------

	local Destroyed = 0
	for _, Descendant in ipairs(Ancestor:GetDescendants()) do
		local ShouldDestroy = true

		if type(Excluded.Instances) == "table" then
			if table.find(Excluded.Instances, Descendant.Name) or table.find(Excluded.Instances, Descendant) then
				continue
			end
		end

		if type(Excluded.Properties) == "table" then
			for Property, Value in pairs(Excluded.Properties) do
				local Success, Response = pcall(function()
					return (Descendant)[Property] == Value
				end)
				if not Success or Response ~= true then
					ShouldDestroy = false
					break
				end
			end
		end

		if type(Excluded.IsA) == "string" then
			if Descendant:IsA(Excluded.IsA) then
				continue
			end
		end

		if ShouldDestroy then
			Descendant:Destroy()
			Destroyed += 1
		end
	end
	return Destroyed
end

------------
return Clear