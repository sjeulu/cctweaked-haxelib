package cc.periphs;

import lua.Table;

extern class Modem {
	public static function open(channel:Int):Void; //	Open a channel on a modem.
	public static function isOpen(channel:Int):Bool; //	Check if a channel is open.
	public static function close(channel:Int):Void; //	Close an open channel, meaning it will no longer receive messages.
	public static function closeAll():Void; // Close all open channels.
	public static function transmit(channel:Int, replyChannel:Int, payload:Any):Void; // 	Sends a modem message on a certain channel.
	public static function isWireless():Bool; // Determine if this is a wired or wireless modem.
	public static function getNamesRemote():Table<Int, String>; // List all remote peripherals on the wired network.
	public static function isPresentRemote(name:String):Bool; //	Determine if a peripheral is available on this wired network.
	public static function getTypeRemote(name:String):String; //	Get the type of a peripheral is available on this wired network.
	public static function getMethodsRemote(name:String):Table<Int, String>; //	Get all available methods for the remote peripheral with the given name.
	public static function getNameLocal():String; // Returns the network name of the current computer, if the modem is on.
}
