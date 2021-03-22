package cc.periphs;

extern class Speaker {
	public static function playSound(name:String, ?volume:Float, ?pitch:Float):Bool; //	Plays a sound through the speaker.
	public static function playNote(name:String, ?volume:Float, ?pitch:Float):Bool; //	Plays a note block note through the speaker.
}
