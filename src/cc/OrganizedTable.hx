package cc;

import haxe.DynamicAccess;

/**
	A Lua table created by some part of the mod's API.

	Due to such tables usually representing an NBT data or a
	Java Object, the amount of edge cases one has to consider
	while processing them is significantly smaller than with arbitrary
	tables. For example, the fields of an `OrganizedTable` can either
	be all integers or all strings, which makes it straightforward to
	determine whether the table can be used as an array or not.
	
	These are also not expected to contain functions or anything
	other than strings and numbers as keys.
**/
abstract OrganizedTable(DynamicAccess<Dynamic>) to DynamicAccess<Dynamic> {}

