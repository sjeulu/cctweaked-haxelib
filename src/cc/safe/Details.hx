package cc.safe;

import haxe.DynamicAccess;

/**
	Represents a subset of Lua values that various inspection functions
	from the mod can return.
**/
enum Details {
	Number(value:Int);
	String(value:String);
	Bool(value:Bool);
	Array(value:Array<Details>);
	Table(value:Map<String, Details>);
	Nil;
}

/**
	Converts an <see cref=cc.OrganizedTable.OrganizedTable>OrganizedTable</see>
	into a type safe ADT wrapper.
**/
function fromOrganizedTable(data:OrganizedTable):Details {
	function fromDynamic(data:Dynamic):Details {
		var luaType:String = untyped __lua__("type(data)");
		return switch (luaType) {
			case ("number"): Number(data);
			case ("string"): String(data);
			case ("boolean"): Bool(data);
			case ("table"): {
				var table:DynamicAccess<Dynamic> = data;
				return if (table.exists("1")) {
					Array([
						for (fieldIndex in 0...table.keys().length)
						table.get(Std.string(fieldIndex) + 1) // +1 cuz lua
					]);
				} else {
					Table([
						for (field => value in table)
						field => fromDynamic(value)
					]);
				}
			}
			case _: Nil;
		}
	}
	return Table([
		for (fieldName => value in (data:DynamicAccess<Dynamic>))
		fieldName => fromDynamic(value)
	]);
}
