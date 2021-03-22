package cc.periphs;

extern class Disk {
	public static function isDiskPresent():Bool; //	Returns whether a disk is currently inserted in the drive.
	public static function getDiskLabel():Null<String>; //	Returns the label of the disk in the drive if available.
	public static function setDiskLabel(?label:String):Void; //	Sets or clears the label for a disk.
	public static function hasData():Bool; //	Returns whether a disk with data is inserted.
	public static function getMountPath():Null<String>; //	Returns the mount path for the inserted disk.
	public static function hasAudio():Bool; //	Returns whether a disk with audio is inserted.
	public static function getAudioTitle():Null<String>; //	Returns the title of the inserted audio disk.
	public static function playAudio():Void; //	Plays the audio in the inserted disk, if available.
	public static function stopAudio():Void; //	Stops any audio that may be playing.
	public static function ejectDisk():Void; //	Ejects any disk that may be in the drive.
	public static function getDiskID():Int; //	Returns the ID of the disk inserted in the drive.
}
