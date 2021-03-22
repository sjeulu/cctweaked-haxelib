package cc.periphs;

extern class Computer {
	public static function turnOn():Void; //	Turn the other computer on.
	public static function shutdown():Void; //	Shutdown the other computer.
	public static function reboot():Void; //	Reboot or turn on the other computer.
	public static function getID():Int; //	Get the other computer's ID.
	public static function isOn():Bool; //	Determine if the other computer is on.
	public static function getLabel():Null<String>; //	Get the other computer's label.
}
