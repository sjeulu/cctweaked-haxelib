package cc.periphs;

import lua.Table;

extern class FluidStorage {
	public static function tanks():Table<Int, Table<String, Any>>;
	public static function pushFluid(toName:String, ?limit:Float, ?fluidName:String):Float;
	public static function pullFluid(fromName:String, ?limit:Float, ?fluidName:String):Float;
}
