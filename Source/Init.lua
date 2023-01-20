--!strict
--[[ Information:
		○ Author: @EgizianoEG
		○ About:
			- InstanceX is a Roblox Lua library that extends the standard instance operations, 
			  providing a set of utility functions for working with instances in Roblox.
]]
--------------------------------------------------------------------------------------------------------|
local InstanceX = {}
local LowerCaseFunctionNames = false		--| "testfunction()".
local SolveIncorrectIndexing = false		--| e.g. lowering function names if it is not found.
local IncludeSubLibrariesFunctions = true	--| Integrate its functions? (Not as a table)
local Typechecking = require(script.TypeChecking)
------------------------------------------------|

--[[
local assert = function(Condition: any, ErrorMessage: string?)
	assert(Condition, ErrorMessage)
end
]]

local Assert_InstanceString = function(Obj: Instance, Str: string)
	assert(typeof(Obj) == "Instance", "Invalid Argument [1]; Instance expected.")
	assert(typeof(Str) == "string", "Invalid Argument [2]; String expected.")
end

local Append = function(t, v)
	t[#t+1] = v
end

--------------------------------------------------------------------------------------------------------|

--[[ GetInstanceFromPath - Returns an instance based on the given path.
-| @param	Ancestor:		The base instance to start the search from. Can be a string representing a service name. If not provided, it will default to the `game` service.
-| @param	Path:			Path The path to the instance, separated by the provided `PathSeparator` or backslashes (`\`).
-| @param	PathSeparator:	PathSeparator The separator character used in the `Path` parameter. Defaults to backslash (`\`).
-| @param	FunctionTimeout: The maximum time in seconds the function should take to execute. If exceeded, it will return `nil` and a message idicating that the function has timed out.
-| @param	WaitForCreation: If set to `true`, the function will wait for any instance in the provided path to be created if it doesn't exist yet.
-| @param	InstanceWaitTimeout: The maximum time in seconds the function should wait for the instance to be created. Only applicable if `WaitForCreation` is set to `true`.
-| @return  The instance object, or `nil` if it couldn't be found.
-| @return  An error message if the function failed, or `nil` if it succeeded.]]
function InstanceX.GetInstanceFromPath(Ancestor: (Instance | string)?, Path: string, PathSeparator: string?, FunctionTimeout: number?, WaitForCreation: boolean?, InstanceWaitTimeout: number?):(Instance?, string?)
	assert(typeof(Ancestor) == "Instance" or typeof(Ancestor) == "string" or Ancestor == nil, "Invalid Argument [1]; AncestorObject must be an instance.")
	assert(typeof(Path) == "string", "Invalid Argument [2]; String path must be provided.")
	assert(typeof(PathSeparator) == "string" or PathSeparator == nil, "Invalid Argument [3]; String expected.")
	assert(typeof(InstanceWaitTimeout) == "number" or InstanceWaitTimeout == nil, "Invalid Argument [4]; Number expected.")
	assert(typeof(FunctionTimeout) == "number" or FunctionTimeout == nil, "Invalid Argument [5]; Number expected.")
	--------------------------------------------------------------------------------------------------------------------------

	local PathSegments = string.split(Path, (PathSeparator or "\\"))
	local Thread = coroutine.running()
	local FoundInstance

	if typeof(Ancestor) == "Instance" then
		FoundInstance = Ancestor
	elseif typeof(Ancestor) == "string" then
		FoundInstance = game:GetService(Ancestor)
	elseif PathSegments[1]:lower() == "game" then
		FoundInstance = game:GetService(table.remove(PathSegments, 2))
		table.remove(PathSegments, 1)
	else
		FoundInstance = game:GetService(table.remove(PathSegments, 1))
	end

	coroutine.wrap(function()
		for _, Segment in ipairs(PathSegments) do
			if WaitForCreation and InstanceWaitTimeout then
				FoundInstance = FoundInstance:WaitForChild(Segment, InstanceWaitTimeout)
			elseif WaitForCreation then
				FoundInstance = FoundInstance:WaitForChild(Segment)
			else
				FoundInstance = FoundInstance:FindFirstChild(Segment)
			end
			if FoundInstance == nil then
				coroutine.resume(Thread, false, "Couldn't find the requested instance.")
				return
			end
		end
		coroutine.resume(Thread, true, FoundInstance)
	end)()

	if FunctionTimeout then
		task.delay(FunctionTimeout, function()
			coroutine.resume(Thread, false, "Timed out while waiting for the instance to be found.")
		end)
	end

	local Success, Response = coroutine.yield(Thread)
	if not Success then return nil, Response end
	return Response::any, nil
end

--[[ GetInstancePathString - Returns the path string of a given instance, with the optional separator.
-| @param	Object: The instance to get the path for.
-| @param	PathSeparator [Optional]: The separator to use in the path string. Defaults: backslash `\`.
-| @param	ReturnAsArray: Whether to return the path as an array of strings.
-| @return	A string that represents the path to the Object.]]
function InstanceX.GetInstancePathString(Object: Instance, PathSeparator: string?, ReturnArray: boolean?): (string | {string})
	Assert_InstanceString(Object, PathSeparator or "\\")
	----------------------------------------------------
	local PathTable = {}
	local Latest = Object

	repeat
		Append(PathTable, Latest.Name)
		Latest = Latest.Parent::Instance
	until not Latest

	--| instance hierarchy and order:
	table.remove(PathTable, #PathTable)
	for i = 1, math.floor(#PathTable * 0.5) do
		PathTable[i], PathTable[(#PathTable - i) + 1] = PathTable[(#PathTable - i) + 1], PathTable[i]
	end
	return (not ReturnArray and table.concat(PathTable, (PathSeparator or "\\"))) or PathTable
end

--| Returns an array containing the specific children of the Ancestor instance using the 'Instace:IsA' method.
function InstanceX.GetChildrenWhichAre(Ancestor: Instance, ClassName: string): {Instance}
	Assert_InstanceString(Ancestor, ClassName)
	----------------------------------------

	local FoundChildren = {}
	for _, Instance in ipairs(Ancestor:GetChildren()) do
		if Instance:IsA(ClassName) then
			Append(FoundChildren, Instance)
		end
	end
	return FoundChildren
end

--| Returns an array containing the specific children of the Ancestor instance using the 'ClassName' property.
function InstanceX.GetChildrenOfClass(Ancestor: Instance, ClassName: string): {Instance}
	Assert_InstanceString(Ancestor, ClassName)
	------------------------------------------

	local FoundChildren = {}
	for _, Instance in ipairs(Ancestor:GetChildren()) do
		if Instance.ClassName == ClassName then
			Append(FoundChildren, Instance)
		end
	end
	return FoundChildren
end

--| Returns an array containing the specific descendants of the Ancestor instance using the 'Instace:IsA' method.
function InstanceX.GetDescendantsWhichAre(Ancestor: Instance, ClassName: string): {any}
	Assert_InstanceString(Ancestor, ClassName)
	------------------------------------------

	local Descendants = {}
	for _, Instance in ipairs(Ancestor:GetDescendants()) do
		if Instance:IsA(ClassName) then
			Append(Descendants, Instance)
		end
	end
	return Descendants
end

--| Returns an array containing the specific descendants of the Ancestor instance using the 'Instace:IsA' method.
function InstanceX.GetDescendantsOfClass(Ancestor: Instance, ClassName: string): {any}
	Assert_InstanceString(Ancestor, ClassName)
	------------------------------------------

	local Descendants = {}
	for _, Instance in ipairs(Ancestor:GetDescendants()) do
		if Instance.ClassName == ClassName then
			Append(Descendants, Instance)
		end
	end
	return Descendants
end

--| Returns all the found Siblings of the given instance.
function InstanceX.GetSiblings(Object: Instance): {Instance}
	assert(typeof(Object) == "Instance", "Invalid Argument [1]; Instance expected.")
	--------------------------------------------------------------------------------
	local Siblings = (Object.Parent and Object.Parent:GetChildren()) or {}
	table.remove(Siblings, (table.find(Siblings, Object) or 0))
	return Siblings
end

--[[ GetSiblingsWhichAre - Returns the siblings of the given `Object` object that are of the specified `ClassName` using IsA condition.
-| @param	Object: The `Object` object to get the siblings of.
-| @param	ClassName: The class name of the siblings to return.
-| @return	An array of the siblings of the `Object` object that are of the specified `ClassName`.]]
function InstanceX.GetSiblingsWhichAre(Object: Instance, ClassName: string): {Instance}
	assert(typeof(Object) == "Instance", "Invalid Argument [1]; Instance expected.")
	--------------------------------------------------------------------------------
	local Sibilings = {}
	if not Object.Parent then return Sibilings end
	for _, Sibling in ipairs((Object.Parent::any):GetChildren()) do
		if Sibling == Object then continue end
		if Sibling:IsA(ClassName) then
			Append(Sibilings, Sibling)
		end
	end
	return Sibilings
end

--[[ GetSiblingsOfClass - Returns the siblings of the given `Object` object that have the specified `ClassName` property.
-| @param	Object: The `Object` object to get the siblings of.
-| @param	ClassName: The class name of the siblings to return.
-| @return	An array of the siblings of the `Object` object that have the specified `ClassName`.]]
function InstanceX.GetSiblingsOfClass(Object: Instance, ClassName: string): {Instance}
	assert(typeof(Object) == "Instance", "Invalid Argument [1]; Instance expected.")
	--------------------------------------------------------------------------------
	local Sibilings = {}
	if not Object.Parent then return Sibilings end
	for _, Sibling in ipairs((Object.Parent::any):GetChildren()) do
		if Sibling == Object then continue end
		if Sibling.ClassName == ClassName then
			Append(Sibilings, Sibling)
		end
	end
	return Sibilings
end

--| Parents all the children of an Ancestor to another Instance.
function InstanceX.ParentAllChildren(Ancestor: Instance, NewParent: Instance)
	assert(typeof(Ancestor) == "Instance", "Invalid Argument [1]; Instance expected.")
	assert(typeof(NewParent) == "Instance", "Invalid Argument [2]; Instance expected.")
	-----------------------------------------------------------------------------------

	for _, Child in ipairs(Ancestor:GetChildren()) do
		Child.Parent = NewParent
	end
end

--[[ GetChildrenMatchingFilter - Gets all children of the given ancestor instance that match the specified filter criteria.
-| @param	Ancestor: The instance to get children from.
-| @param	Filter: A table containing filter criteria. Possible criteria are:
	 * Properties: A table of property-value pairs to check against the children's properties.
	 * NameMatching: A string or table containing a pattern to match against the children's names. If a table is provided, it must contain the following fields:
	 	* Pattern: The string pattern to use for matching.
	 	* Init [Optional]: The starting position for the pattern matching.
	 * IsA: A string specifying a class name to check against the children's class names.
	 * IsAncestorOf: An instance to check if the children are ancestors of.
-| @return	An array of children that match the filter criteria.]]
function InstanceX.GetChildrenMatchingFilter(Ancestor: Instance, Filter: {[string]: any}): {Instance}
	assert(typeof(Ancestor) == "Instance", "Invalid Argument [1]; Instance expected.")
	assert(typeof(Filter) == "table", "Invalid Argument [2]; Table expected.")
	--------------------------------------------------------------------------

	local MatchingChildren = {}
	for _, Child in ipairs(Ancestor:GetChildren()) do
		local FilterMet = true

		if typeof(Filter.Properties) == "table" then
			for Property, Value in pairs(Filter.Properties) do
				local Success, Response = pcall(function()
					return (Child::any)[Property] == Value
				end)
				if not Success or Response ~= true then
					FilterMet = false
					break
				end
			end
		end

		if typeof(Filter.NameMatching) == "string" then
			if not string.match(Child.Name, Filter.NameMatching) then
				FilterMet = false
			end
		elseif typeof(Filter.NameMatching) == "table" then
			if typeof(Filter.NameMatching.Pattern) == "string" then
				if typeof(Filter.NameMatching.Init) == "number" then
					FilterMet = string.match(Child.Name, Filter.NameMatching.Pattern, Filter.NameMatching.Init) ~= nil
				else
					FilterMet = string.match(Child.Name, Filter.NameMatching.Pattern) ~= nil
				end
			end
		end

		if typeof(Filter.IsA) == "string" then
			if not Child:IsA(Filter.IsA) then
				FilterMet = false
			end
		end

		if typeof(Filter.IsAncestorOf) == "Instance" then
			if not Child:IsAncestorOf(Filter.IsAncestorOf) then
				FilterMet = false
			end
		end
		if FilterMet then Append(MatchingChildren, Child) end
	end
	return MatchingChildren
end

--[[ GetDescendantsMatchingFilter - Gets all descendants of the given ancestor instance that match the specified filter criteria.
-| @param	Ancestor: The instance to get descendants from.
-| @param	Filter A table containing filter criteria. Possible criteria are:
	 * Properties: A table of property-value pairs to check against the descendants' properties.
	 * NameMatching: A string or table containing a pattern to match against the descendants' names. If a table is provided, it must contain the following fields:
		 * Pattern: The string pattern to use for matching.
		 * Init [Optional]: The starting position for the pattern matching.
	 * IsA: A string specifying a class name to check against the descendants' class names.
	 * IsAncestorOf: An instance to check if the descendants are ancestors of.
	 * IsDescendantOf: An instance to check if the descendants are descendants of.
-| @return	An array of descendants that match the filter criteria.]]
function InstanceX.GetDescendantsMatchingFilter(Ancestor: Instance, Filter: {[string]: any}): {Instance}
	assert(typeof(Ancestor) == "Instance", "Invalid Argument [1]; Instance expected.")
	assert(typeof(Filter) == "table", "Invalid Argument [2]; Table expected.")
	--------------------------------------------------------------------------

	local MatchingDescendants = {}
	for _, Descendant in ipairs(Ancestor:GetDescendants()) do
		local FilterMet = true

		if typeof(Filter.Properties) == "table" then
			for Property, Value in pairs(Filter.Properties) do
				local Success, Response = pcall(function()
					return Descendant[Property] == Value
				end)
				if not Success or Response ~= true then
					FilterMet = false
					break
				end
			end
		end

		if typeof(Filter.NameMatching) == "string" then
			if not string.match(Descendant.Name, Filter.NameMatching) then
				FilterMet = false
			end
		elseif typeof(Filter.NameMatching) == "table" then
			if typeof(Filter.NameMatching.Pattern) == "string" then
				if typeof(Filter.NameMatching.Init) == "number" then
					FilterMet = string.match(Descendant.Name, Filter.NameMatching.Pattern, Filter.NameMatching.Init) ~= nil
				else
					FilterMet = string.match(Descendant.Name, Filter.NameMatching.Pattern) ~= nil
				end
			end
		end

		if typeof(Filter.IsA) == "string" then
			if not Descendant:IsA(Filter.IsA) then
				FilterMet = false
			end
		end

		if typeof(Filter.IsAncestorOf) == "Instance" then
			if not (Descendant::Instance):IsAncestorOf(Filter.IsAncestorOf) then
				FilterMet = false
			end
		end

		if typeof(Filter.IsDescendantOf) == "Instance" then
			if not (Descendant::Instance):IsDescendantOf(Filter.IsDescendantOf) then
				FilterMet = false
			end
		end
		if FilterMet then Append(MatchingDescendants, Descendant) end
	end
	return MatchingDescendants
end

--[[ GetDuplicateChildren - Gets all children of the given ancestor instance that have duplicate names and class names.
-| @param	Ancestor: The instance to get children from.
-| @return	An array of children with duplicate names and class names.]]
function InstanceX.GetDuplicateChildren(Ancestor: Instance): {Instance}
	assert(typeof(Ancestor) == "Instance", "Invalid Argument [1]; Instance expected.")
	----------------------------------------------------------------------------------

	local Children = Ancestor:GetChildren()
	local Duplicates = {}
	for _, MasterChild in ipairs(Children) do
		for _, Child in ipairs(Children) do
			if MasterChild == Child then continue end
			if MasterChild.Name == Child.Name and MasterChild.ClassName == Child.ClassName then
				if not table.find(Duplicates, Child) then
					Append(Duplicates, Child)
				end
			end
		end
	end
	return Duplicates
end

--[[ GetAncestors - Gets a list of all ancestors of the given object, in order from the object's parent up to the root instance.
-| @param	Object: The instance to get ancestors for.
-| @param	OrderReversed [Optional]: Whether to return the ancestors in reverse order, with the root instance first.
-| @return	An array of ancestors, starting with the object's parent and ending with the root instance.]]
function InstanceX.GetAncestors(Object: Instance, OrderReversed: boolean?): {Instance}
	assert(typeof(Object) == "Instance", "Invalid Argument [1]; Instance expected.")
	--------------------------------------------------------------------------------

	local Ancestors = {}
	local LastAncestor = Object.Parent
	while LastAncestor do
		Append(Ancestors, LastAncestor)
		LastAncestor = LastAncestor.Parent
	end
	if OrderReversed then
		local Total = #Ancestors
		for i = 1, math.floor(Total * 0.5) do
			local b = Total - (i - 1)
			Ancestors[i], Ancestors[b] = Ancestors[b], Ancestors[i]
		end
	end
	return Ancestors
end

--[[ Get a list of ancestors of the given object that match the specified filter, in order from the object's parent up to the root instance.
-| @param	Object: The instance to get ancestors for.
-| @param	Filter: A table containing filters to apply to the ancestors. The table can contain the following keys:
	 * "Properties" (optional): A table of key-value pairs to match against the ancestors' properties.
	 * "NameMatching" (optional): A string or table to use to match against the ancestors' names. If a string is provided, it is treated as a pattern to match against the name. If a table is provided, it must contain a "Pattern" key with the pattern to match, and may optionally contain an "Init" key with a starting index for the match.
	 * "IsA" (optional): A string specifying the class name to match against the ancestors.
	 * "IsAncestorOf" (optional): An instance to check if the ancestor is an ancestor of.
	 * "IsDescendantOf" (optional): An instance to check if the ancestor is a descendant of.
-| @param OrderReversed (Optional) Whether to return the ancestors in reverse order, with the root instance first.
-| @return An array of ancestors that match the specified filter, starting with the object's parent and ending with the root instance]]
function InstanceX.GetAncestorsMatchingFilter(Object: Instance, Filter: {[string]: any}, OrderReversed: boolean?): {Instance}
	assert(typeof(Object) == "Instance", "Invalid Argument [1]; Instance expected.")
	assert(typeof(Filter) == "table", "Invalid Argument [2]; No filtering table has been provided.")
	------------------------------------------------------------------------------------------------

	local FilteredAncestors = {}
	local LastAncestor = Object.Parent

	while LastAncestor do
		local FilterMet = true
		if typeof(Filter.Properties) == "table" then
			for Property, Value in pairs(Filter.Properties) do
				local Success, Response = pcall(function()
					return (LastAncestor::any)[Property] == Value
				end)
				if not Success or Response ~= true then
					FilterMet = false
					break
				end
			end
		end

		if typeof(Filter.NameMatching) == "string" then
			if not string.match(LastAncestor.Name, Filter.NameMatching) then
				FilterMet = false
			end
		elseif typeof(Filter.NameMatching) == "table" then
			if typeof(Filter.NameMatching.Pattern) == "string" then
				if typeof(Filter.NameMatching.Init) == "number" then
					FilterMet = string.match(LastAncestor.Name, Filter.NameMatching.Pattern, Filter.NameMatching.Init) ~= nil
				else
					FilterMet = string.match(LastAncestor.Name, Filter.NameMatching.Pattern) ~= nil
				end
			end
		end

		if typeof(Filter.IsA) == "string" then
			if not LastAncestor:IsA(Filter.IsA) then
				FilterMet = false
			end
		end

		if typeof(Filter.IsAncestorOf) == "Instance" then
			if not (LastAncestor::Instance):IsAncestorOf(Filter.IsAncestorOf) then
				FilterMet = false
			end
		end

		if typeof(Filter.IsDescendantOf) == "Instance" then
			if not (LastAncestor::Instance):IsDescendantOf(Filter.IsDescendantOf) then
				FilterMet = false
			end
		end

		if FilterMet then Append(FilteredAncestors, LastAncestor) end
		LastAncestor = LastAncestor.Parent
	end

	if OrderReversed then
		local Total = #FilteredAncestors
		for i = 1, math.floor(Total * 0.5) do
			local b = Total - (i - 1)
			FilteredAncestors[i], FilteredAncestors[b] = FilteredAncestors[b], FilteredAncestors[i]
		end
	end
	return FilteredAncestors
end

--[[ InstanceHasProperty - Checks if the given object has the specified property.
-| @param	Object: The instance to check for the property.
-| @param	Property: The name of the property to check for.
-| @return	A boolean indicating whether the object has the property.]]
function InstanceX.InstanceHasProperty(Object: Instance, Property: string): boolean
	Assert_InstanceString(Object, Property)
	---------------------------------------
	local HasIt, Response = pcall(function()
		return (Object::any)[Property]
	end)
	return (HasIt and typeof(Response) ~= "RBXScriptSignal" and typeof(Response) ~= "function")
end

------------------------------------------------------------------------------------------------------------------------------------|

--| Experimental - Custom Instance Methods (Won't work properly because of the Instance assertions that are in most of the functions)
--[[
local WrapperCache = setmetatable({}, {__mode = "k"})

---| new - Creates a new instance and wraps it in a metatable that allows access to the library functions as they were instance methods while also keeping the instance's original properties and methods.
-- @param	ClassName: The class name of the instance to create.
-- @param	Parent: The parent of the instance.
-- @param	Properties: A table of properties to set on the instance.
-- @return	Userdata/The wrapped instance.
function InstanceX.new(ClassName: string, Parent: Instance?, Properties: {[string]: any}?)
	local Object = Instance.new(ClassName)

	if Properties then
		for Property, Value in pairs(Properties) do
			pcall(function()
				Object[Property] = Value
			end)
		end
	end

    Object.Parent = Parent
	return InstanceX.Wrap(Object)
end

---| Wrap - Wraps an object in a proxy object. (You can use this function to wrap an existing instance, too)
-- @param	Object The object to wrap.
-- @return	The wrapped object?.
function InstanceX.Wrap(Object: any)
	for Wrapped, RealObject in next, WrapperCache do
		if RealObject == Object then
			return Wrapped
		end
	end

	if type(Object) == "userdata" then
        local Fake = newproxy(true)
        local Meta = getmetatable(Fake)

        Meta.__index = function(_, key)
            if InstanceX[key] then
                return InstanceX[key]
            end
            return InstanceX.Wrap(Object[key])
        end

        Meta.__newindex = function(_, key, value)
            Object[key] = value
        end

        Meta.__tostring = function()
            return tostring(Object)
        end

        WrapperCache[Fake] = Object
        return Fake

    elseif type(Object) == "function" then
        local Fake = function(...)
			local Args = InstanceX.UnWrap({...}::any)
            local Results = InstanceX.Wrap({Object(table.unpack(Args))})
            return unpack(Results)
        end
		WrapperCache[Fake::any] = Object
        return Fake::any

    elseif type(Object) == "table" then
        local Fake = {}
        for key, value in next,Object do
            Fake[key] = InstanceX.Wrap(value)
        end
		return Fake::any
    else
         return Object
    end
end

---| UnWrap - Unwraps an object that was wrapped by InstanceX.Wrap.
-- @param	Wrapped The wrapped object to be unwrapped.
-- @treturn	The unwrapped object.
function InstanceX.UnWrap(Wrapped)
    if type(Wrapped) == "table" then
		local RObject = {}
		for key, value in pairs(Wrapped) do
			RObject[key] = InstanceX.UnWrap(value)
		end
		return RObject
	else
        local Object = WrapperCache[Wrapped]
        if not Object then
            return Wrapped
        end
        return Object
    end
end
--]]

-----------------------------------------------------------------------------|
--| Extended:
-------------
--| Extended libraries integrating (Name Format: "[Extended] - <any>").
for _, Library in ipairs(script:GetChildren()) do
	local Match = string.match(Library.Name, "%[Extended%]%s%-%s(.+)")
	if Library:IsA("ModuleScript") and Match then
		local Lib = require(Library)::any
		if IncludeSubLibrariesFunctions then
			for name, func in pairs(Lib) do
				InstanceX[name] = func
			end
		else
			InstanceX[Match] = Lib
		end
	end
end

--| Renames function names to lowercase naming style if desired.
if LowerCaseFunctionNames then
	local Temp = {}::{[any]: (any)}
	local IndexingSolver = function(t, k)
		return rawget(t, k:lower()) or nil
	end

	for Name, ft in pairs(InstanceX) do
		Temp[Name:lower()] = ft
		InstanceX[Name] = nil
		if type(ft) == "table" then
			local TT = {}
			for nn, ff in pairs(ft) do
				TT[nn:lower()] = ff
				ft[nn] = nil
			end
			Temp[Name:lower()] = TT
		end
	end
	InstanceX = (SolveIncorrectIndexing and setmetatable(Temp, {__index = IndexingSolver})::any) or Temp
end

------------------------------------------------
return InstanceX :: Typechecking.InstanceXPascal