--!strict
---------
local TypeChecking = {}
-------------------------------

type AncestorsFilter = {
	Properties: {[string]: any};
	NameMatching: (string | {
		Pattern: string,
		Init: number
	});
	IsA: string?;
	IsAncestorOf: Instance;
	IsDescendantOf: Instance;
}

type ChildrenFilter = {
	Properties: {[string]: any};
	NameMatching: (string | {
		Pattern: string,
		Init: number
	});
	IsA: string?;
	IsAncestorOf: Instance;
}

type DescendantsFilter = {
	Properties: {[string]: any};
	NameMatching: (string | {
		Pattern: string,
		Init: number
	});
	IsA: string?;
	IsAncestorOf: Instance;
	IsDescendantOf: Instance;
}

type ClearAllFilter = {
	Instances: {Instance | string};
	Properties: {[string]: any}?;
	IsA: string?;
}

export type InstanceXPascal = {
	--| MainModule:
	GetInstanceFromPath: (Ancestor: (Instance | string)?, Path: string, PathSeparator: string?, FunctionTimeout: number?, WaitForCreation: boolean?, InstanceWaitTimeout: number?) -> (Instance?, string?),
	GetInstancePathString: (Object: Instance, PathSeparator: string?, ReturnArray: boolean?) -> (string | {string}),
	GetChildrenWhichAre: (Target: Instance, ClassName: string) -> {Instance},
	GetChildrenOfClass: (Ancestor: Instance, ClassName: string) -> {Instance},
	GetDescendantsWhichAre: (Ancestor: Instance, ClassName: string) -> {any},
	GetDescendantsOfClass: (Ancestor: Instance, ClassName: string) -> {any},
	GetSiblings: (Object: Instance) -> {Instance},
	GetSiblingsWhichAre: (Object: Instance, ClassName: string) -> {Instance},
	GetSiblingsOfClass: (Object: Instance, ClassName: string) -> {Instance},
	ParentAllChildren: (Ancestor: Instance, NewParent: Instance) -> (),
	GetChildrenMatchingFilter: (Ancestor: Instance, Filter: ChildrenFilter) -> {Instance},
	GetDescendantsMatchingFilter: (Ancestor: Instance, Filter: DescendantsFilter) -> {Instance},
	GetDuplicateChildren: (Ancestor: Instance) -> {Instance},
	GetAncestors: (Object: Instance, OrderReversed: boolean?) -> {Instance},
	GetAncestorsMatchingFilter: (Object: Instance, Filter: AncestorsFilter, OrderReversed: boolean?) -> {Instance},
	InstanceHasProperty:(Object: Instance, Property: string) -> boolean,

	--| WaitFor:
	WaitForChildWhichIsA: (Ancestor: Instance, ClassName: string, TimeOut: number?) -> Instance,
	WaitForChildOfClass: (Ancestor: Instance, ClassName: string, TimeOut: number?) -> Instance,
	WaitForChildren: (Ancestor: Instance, ChildrenNames: {string}, TimeOut: number?, SingleInstanceTimout: number?) -> ({Instance}, boolean),
	WaitForHierarchy: (Ancestor: Instance, HierarchyTable: ({} | {any}), TimeOut: number?, SingleInstanceTimout: number?) -> ({any}, boolean),

	--| Clone:
	CloneAndParent: (Object: Instance, Parent: Instance?, Clones: number?) -> (Instance | {Instance}),
	CloneWithoutChildren: (Object: Instance, Parent: Instance?) -> Instance,
	CloneWithProperties: (Object: Instance, Properties: {[string]: any}, Clones: number?) -> (Instance | {Instance}),
	CloneToMultiple: (Object: Instance, To: {Instance}, ClonesForEachInstance: number?) -> {Instance},

	--| ClearAll:
	ClearAllChildrenWhichAre: (Ancestore: Instance, ClassName: string) -> number,
	ClearAllDescendantsWhichAre: (Ancestore: Instance, ClassName: string) -> number,
	ClearAllChildrenExcept: (Ancestor: Instance, Excluded: ClearAllFilter) -> number,
	ClearAllDescendantsExcept: (Ancestor: Instance, Excluded: ClearAllFilter) -> number,

	--| Attributes:
	SetAttributes: (Object: Instance, Attributes: {[string]: any}) -> (),
	UpdateAttribute: (Object: Instance, Attribute: string, Callback: (any) -> any) -> (),
	IncrementAttribute: (Object: Instance, Attribute: string, Increment: (number | string)) -> number?,
	FindFirstChildWithAttribute: (Ancestor: Instance, Attribute: (string | {string}), ValueCondition: ((any) -> boolean)?) -> (Instance?, any?),
	FindFirstDescendantWithAttribute: (Ancestor: Instance, Attribute: (string | {string}), ValueCondition: ((any) -> boolean)?) -> (Instance?, any?),
	FindFirstAncestorWithAttribute: (Object: Instance, Attribute: string, ValueCondition: ((any) -> boolean)?) -> (Instance?, any?),
	SetMultipleAttributes: (Objects: {Instance}, Attributes: {[string]: any}) -> (),
	GetChildrenWithAttributes: (Ancestor: Instance, Attributes: {string}, ShouldMatchAll: boolean?) -> {Instance},
	GetDescendantsWithAttributes: (Ancestor: Instance, Attributes: {string}, ShouldMatchAll: boolean?) -> {Instance},
	WaitForChildWhithAttribute: (Ancestor: Instance, Attribute: string, TimeOut: number?) -> Instance?,
	ClearAllAttributes: (Object: Instance, Excluded: {string}?) -> (),
	AttributeTween: (Object: Instance, Attribute: string, GoalValue: any, TweenInformation: TweenInfo?) -> Tween,

	--| Tags:
	FindFirstChildTagged: (Ancestor: Instance, Tag: (string | {string})) -> Instance?,
	FindFirstDescendantTagged: (Ancestor: Instance, Tag: (string | {string})) -> Instance?,
	GetAncestorTagged: (Object: Instance, Tag: string) -> Instance?,
	GetChildrenTagged: (Ancestor: Instance, Tag: (string | {string})) -> {Instance},
	GetDescendantsTagged: (Ancestor: Instance, Tag: (string | {string})) -> {any},
}

export type InstanceXLowered = {
	--| MainModule:
	getinstancefrompath: (Ancestor: (Instance | string)?, Path: string, PathSeparator: string?, FunctionTimeout: number?, WaitForCreation: boolean?, InstanceWaitTimeout: number?) -> (Instance?, string?),
	getinstancepathstring: (Object: Instance, PathSeparator: string?, ReturnArray: boolean?) -> (string | {string}),
	getchildrenwhichare: (Target: Instance, ClassName: string) -> {Instance},
	getchildrenofclass: (Ancestor: Instance, ClassName: string) -> {Instance},
	getdescendantswhichare: (Ancestor: Instance, ClassName: string) -> {any},
	getdescendantsofclass: (Ancestor: Instance, ClassName: string) -> {any},
	getsiblings: (Object: Instance) -> {Instance},
	getsiblingswhichare: (Object: Instance, ClassName: string) -> {Instance},
	getsiblingsofclass: (Object: Instance, ClassName: string) -> {Instance},
	parentallchildren: (Ancestor: Instance, NewParent: Instance) -> (),
	getchildrenmatchingfilter: (Ancestor: Instance, Filter: ChildrenFilter) -> {Instance},
	getdescendantsmatchingfilter: (Ancestor: Instance, Filter: DescendantsFilter) -> {Instance},
	getduplicatechildren: (Ancestor: Instance) -> {Instance},
	getancestors: (Object: Instance, OrderReversed: boolean?) -> {Instance},
	getancestorsmatchingfilter: (Object: Instance, Filter: AncestorsFilter, OrderReversed: boolean?) -> {Instance},
	instancehasproperty:(Object: Instance, Property: string) -> boolean,

	--| WaitFor:
	waitforchildwhichisa: (Ancestor: Instance, ClassName: string, TimeOut: number?) -> Instance,
	waitforchildofclass: (Ancestor: Instance, ClassName: string, TimeOut: number?) -> Instance,
	waitforchildren: (Ancestor: Instance, ChildrenNames: {string}, TimeOut: number?, SingleInstanceTimout: number?) -> ({Instance}, boolean),
	waitforhierarchy: (Ancestor: Instance, HierarchyTable: ({} | {any}), TimeOut: number?, SingleInstanceTimout: number?) -> ({any}, boolean),

	--| Clone:
	cloneandparent: (Object: Instance, Parent: Instance?, Clones: number?) -> (Instance | {Instance}),
	clonewithoutchildren: (Object: Instance, Parent: Instance?) -> Instance,
	clonewithproperties: (Object: Instance, Properties: {[string]: any}, Clones: number?) -> (Instance | {Instance}),
	clonetomultiple: (Object: Instance, To: {Instance}, ClonesForEachInstance: number?) -> {Instance},

	--| ClearAll:
	clearallchildrenwhichare: (Ancestore: Instance, ClassName: string) -> number,
	clearalldescendantswhichare: (Ancestore: Instance, ClassName: string) -> number,
	clearallchildrenexcept: (Ancestor: Instance, Excluded: ClearAllFilter) -> number,
	clearalldescendantsexcept: (Ancestor: Instance, Excluded: ClearAllFilter) -> number,

	--| Attributes:
	setattributes: (Object: Instance, Attributes: {[string]: any}) -> (),
	updateattribute: (Object: Instance, Attribute: string, Callback: (any) -> any) -> (),
	incrementattribute: (Object: Instance, Attribute: string, Increment: (number | string)) -> number?,
	findfirstchildwithattribute: (Ancestor: Instance, Attribute: (string | {string}), ValueCondition: ((any) -> boolean)?) -> (Instance?, any?),
	findfirstdescendantwithattribute: (Ancestor: Instance, Attribute: (string | {string}), ValueCondition: ((any) -> boolean)?) -> (Instance?, any?),
	findfirstancestorwithattribute: (Object: Instance, Attribute: string, ValueCondition: ((any) -> boolean)?) -> (Instance?, any?),
	setmultipleattributes: (Objects: {Instance}, Attributes: {[string]: any}) -> (),
	getchildrenwithattributes: (Ancestor: Instance, Attributes: {string}, ShouldMatchAll: boolean?) -> {Instance},
	getdescendantswithattributes: (Ancestor: Instance, Attributes: {string}, ShouldMatchAll: boolean?) -> {Instance},
	waitforchildwhithattribute: (Ancestor: Instance, Attribute: string, TimeOut: number?) -> Instance?,
	clearallattributes: (Object: Instance, Excluded: {string}?) -> (),
	attributetween: (Object: Instance, Attribute: string, GoalValue: any, TweenInformation: TweenInfo?) -> Tween,

	--| Tags:
	findfirstchildtagged: (Ancestor: Instance, Tag: (string | {string})) -> Instance?,
	findfirstdescendanttagged: (Ancestor: Instance, Tag: (string | {string})) -> Instance?,
	getancestortagged: (Object: Instance, Tag: string) -> Instance?,
	getchildrentagged: (Ancestor: Instance, Tag: (string | {string})) -> {Instance},
	getdescendantstagged: (Ancestor: Instance, Tag: (string | {string})) -> {any},
}

-------------------
return TypeChecking