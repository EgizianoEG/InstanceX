--!strict
---------
local Tags = {}
local Append = function(t, v) t[#t+1] = v end
local CollectionService = game:GetService("CollectionService")

local Assert_InstanceTag = function(Instance, Tag)
	assert(typeof(Instance) == "Instance", "Invalid Argument [1]; Instance expected.")
	assert(typeof(Tag) == "string" or typeof(Tag) == "table", "Invalid Argument [2]; String/Array expected.")
end
------------------------------------------------------------------------------------------------------------|

--[[ FindFirstChildTagged -  Returns the first found child of an `Ancestor` instance that is tagged with `Tag`.
-| @param   Ancestor: The instance to search for children in.
-| @param   Tag: The tag to search for. Can be a string or an array of strings (if the child has any of the strings, it will be returned).
-| @return  The first found child instance that is tagged with `Tag`, or `nil` if no child was found.]]
function Tags.FindFirstChildTagged(Ancestor: Instance, Tag: (string | {string})): Instance?
	Assert_InstanceTag(Ancestor, Tag)
	---------------------------------

	for _, Child in ipairs(Ancestor:GetChildren()) do
		if type(Tag) == "string" then
			if CollectionService:HasTag(Child, Tag) then
				return Child
			end
		elseif type(Tag) == "table" then
			for _, TagString in ipairs(Tag) do
				if CollectionService:HasTag(Child, TagString) then
					return Child
				end
			end
		end
	end
	return nil
end

--[[ FindFirstDescendantTagged - Returns the first found descendant of an `Ancestor` instance that is tagged with `Tag`.
-| @param   Ancestor: The instance to search for descendants.
-| @param   Tag: The tag to search for. Can be a string or an array of strings (if the descendant has any of the strings, it will be returned).
-| @return  Returns the first found descendant with the specified tag, or `nil` if no such descendant is found.]]
function Tags.FindFirstDescendantTagged(Ancestor: Instance, Tag: (string | {string})): Instance?
	Assert_InstanceTag(Ancestor, Tag)
	---------------------------------

	for _, Descendant in ipairs(Ancestor:GetDescendants()) do
		if type(Tag) == "string" then
			if CollectionService:HasTag(Descendant, Tag) then
				return Descendant
			end
		elseif type(Tag) == "table" then
			for _, TagString in ipairs(Tag) do
				if CollectionService:HasTag(Descendant, TagString) then
					return Descendant
				end
			end
		end
	end
	return nil
end

--[[ GetAncestorTagged - Finds the ancestor of the given object with the given tag.
-| @param   Object: The object to check the ancestors of.
-| @param   Tag: The tag to search for.
-| @treturn The ancestor object with the given tag, or nil if it isn't found.]]
function Tags.FindFirstAncestorTagged(Object: Instance, Tag: string): Instance?
	assert(typeof(Object) == "Instance", "Invalid Argument [1]; Instance expected.")
	assert(typeof(Tag) == "string", "Invalid Argument [2]; String expected.")
	-------------------------------------------------------------------------

	local LastAncestor = Object.Parent
	while LastAncestor do
		if CollectionService:HasTag(LastAncestor, Tag) then
			return LastAncestor
		end
		LastAncestor = LastAncestor.Parent
	end
	return nil
end

--[[ GetChildrenTagged - Finds all children of an ancestor object with a specific tag or tags.
-| @param   Ancestor: The ancestor object to search for children.
-| @param   Tag: The tag or tags to search for. Can be a string or an array of strings.
-| @return  An array containing all the children with the specified tag or tags.]]
function Tags.GetChildrenTagged(Ancestor: Instance, Tag: (string | {string}))
	Assert_InstanceTag(Ancestor, Tag)
	---------------------------------

	local Tagged = {}
	for _, Child in ipairs(Ancestor:GetChildren()) do
		if type(Tag) == "string" then
			if CollectionService:HasTag(Child, Tag) then
				Append(Tagged, Child)
			end
		elseif type(Tag) == "table" then
			for _, TagString in ipairs(Tag) do
				if CollectionService:HasTag(Child, TagString) then
					Append(Tagged, Child)
				end
			end
		end
	end
	return Tagged
end

--[[ GetChildrenTagged - Finds all children of an ancestor object with a specific tag or tags.
-| @param   Ancestor: The ancestor object to search for descendants.
-| @param   Tag: The tag or tags to search for. Can be a string or an array of strings.
-| @return  An array containing all the descendants with the specified tag or tags.]]
function Tags.GetDescendantsTagged(Ancestor: Instance, Tag: (string | {string}))
	Assert_InstanceTag(Ancestor, Tag)
	---------------------------------

	local Tagged = {}
	for _, Descendant in ipairs(Ancestor:GetDescendants()) do
		if type(Tag) == "string" then
			if CollectionService:HasTag(Descendant, Tag) then
				Append(Tagged, Descendant)
			end
		elseif type(Tag) == "table" then
			for _, TagString in ipairs(Tag) do
				if CollectionService:HasTag(Descendant, TagString) then
					Append(Tagged, Descendant)
				end
			end
		end
	end
	return Tagged
end

-----------
return Tags