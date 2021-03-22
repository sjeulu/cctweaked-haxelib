package cc.periphs;

@:multiReturn
extern class CommandResult {
	var success:Bool;
	var failMessage:Null<String>;
}

extern class Command {
	public static function getCommand():String;

	public static function setCommand(command:String):Void;

	public static function runCommand():CommandResult;
}
