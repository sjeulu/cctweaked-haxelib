package cc;

import cc.util.Unit;
import haxe.ds.Either;
import haxe.extern.EitherType;

/**
	Represents the result of various actions performed by the turtle, such
	as moving or crafting. It provides information on whether the action
	was successful and any error message, if applicable.
**/
@:multiReturn
extern class TurtleActionResult {
	/**
		Indicates whether the action was successful.
	**/
	public var successful:Bool;

	/**
		Contains an error message in case the action failed.
	**/
	public var error:Null<String>;
}

/**
	A simple conversion helper.
**/
inline function actionResultToEither(r:TurtleActionResult):Either<String, Unit> {
	return r.successful
		? Right(TT)
		: Left(r.error);
}

/**
	Provides information about the success of the inspection and either
	the block details or an error message.
**/
@:multiReturn
extern class TurtleInspectResult {
	/**
		Indicates whether the inspection was successful. The value of
		this field determines the type of <see cref=this.result>the
		result one</see>.
	**/
	public var successful:Bool;

	/**
		In case of a successful inspection, this field is a
		`DynamicAccess<Dynamic>` representing a Lua table
		contaning the data about the inspected block.

		Otherwise this field is a `String` explaining what went wrong
		with the inspection.
	**/
	public var result:EitherType<String, OrganizedTable>;
}

/**
	A simple conversion helper.
**/
inline function inspectionResultToEither(r:TurtleInspectResult):Either<String, OrganizedTable> {
	return r.successful
		? Right(r.result)
		: Left(r.result);
}

/**
	A value that the <see cref=cc.Turtle.getFuelLevel>getFuelLevel</see>
	and <see cref=cc.Turtle.getFuelLimit>getFuelLimit</see> functions
	return when CC: Tweaked is set up so that turtles don't consume fuel.
**/
enum abstract Unlimited(String) {
	/**
		A value that the <see cref=cc.Turtle.getFuelLevel>getFuelLevel</see>
		and <see cref=cc.Turtle.getFuelLimit>getFuelLimit</see> functions
		return when CC: Tweaked is set up so that turtles don't consume fuel.
	**/
	var Unlimited = "unlimited";
}

/**
	Native bindings for the `turtle` table. This class provides them as is,
	with minimal adaptation and safety checks.

	A safer interface is provided by
	<see cref=cc.safe.Turtle>cc.safe.Turtle</see>.
**/
@:native("turtle")
extern class Turtle {
	/**
		Craft a recipe based on the turtle's inventory.
		The turtle's inventory should be set up like a crafting grid.
		For instance, to craft sticks, slots 1 and 5 should contain
		planks. *All* other slots should be empty, including those
		outside the crafting "grid".

		@param limit The maximum number of crafting steps to run.
		@throws `haxe.Exception` When limit is less than 1 or greater
			than 64.
	**/
	public static function craft(?limit:Int):TurtleActionResult;

	/**
		Move the turtle forward one block.
	**/
	public static function forward():TurtleActionResult;

	/**
		Move the turtle backwards one block.
	**/
	public static function back():TurtleActionResult;

	/**
		Move the turtle up one block.
	**/
	public static function up():TurtleActionResult;

	/**
		Move the turtle down one block.
	**/
	public static function down():TurtleActionResult;

	/**
		Rotate the turtle 90 degrees to the left.
	**/
	public static function turnLeft():TurtleActionResult;

	/**
		Rotate the turtle 90 degrees to the right.
	**/
	public static function turnRight():TurtleActionResult;

	/**
		Change the currently selected slot.

		The selected slot is determines what slot actions like `drop`
		or `getItemCount` act on.

		@param slot The slot to select.
		@throws `haxe.Exception` If the slot is out of range.
		@see `getSelectedSlot`
	**/
	public static function select(slot:Int):Bool;

	/**
		Get the currently selected slot.

		@see `select`
	**/
	public static function getSelectedSlot():Int;

	/**
		Get the number of items in the given slot.

		The `slot` argument is the slot we wish to check. Defaults to
		the selected slot.

		@param slot The slot we wish to check. Defaults to the
			<see cref=select>selected slot</see>.
		@throws `haxe.Exception` If the slot is out of range.
	**/
	public static function getItemCount(?slot:Int):Int;

	/**
		Get the remaining number of items which may be stored in this
		stack.

		For instance, if a slot contains 13 blocks of dirt, it has
		room for another 51.

		@param slot The slot we wish to check. Defaults to the
			<see cref=select>selected slot</see>.
		@throws `haxe.Exception` If the slot is out of range.
	**/
	public static function getItemSpace(?slot:Int):Int;

	/**
		Get detailed information about the items in the given slot.

		The `slot` argument is the slot we wish to check. Defaults to
		the selected slot.

		@param slot The to get information about. Defaults to the
			<see cref=select>selected slot</see>.
		@param detailed
			Whether to include "detailed" information.
			When `true` the method will contain much more
			information about the item at the cost of taking
			longer to run.
		@throws `haxe.Exception` If the slot is out of range.

	**/
	public static function getItemDetail(?slot:Int, ?detailed:Bool):OrganizedTable;

	/**
		Equip (or unequip) an item on the left side of this turtle.

		This finds the item in the currently selected slot and attempts
		to equip it to the left side of the turtle. The previous
		upgrade is removed and placed into the turtle's inventory. If
		there is no item in the slot, the previous upgrade is removed,
		but no new one is equipped.

		@see equipRight
		@see getEquippedLeft
	**/
	public static function equipLeft():TurtleActionResult;

	/**
		Equip (or unequip) an item on the right side of this turtle.

		This finds the item in the currently selected slot and attempts
		to equip it to the right side of the turtle. The previous
		upgrade is removed and placed into the turtle's inventory. If
		there is no item in the slot, the previous upgrade is removed,
		but no new one is equipped.

		@see equipLeft
		@see getEquippedRight
	**/
	public static function equipRight():TurtleActionResult;

	/**
		Attack the entity in front of the turtle.

		@param side The specific tool to use.
			Can either be "left" or "right".
	**/
	public static function attack(?side:String):TurtleActionResult;

	/**
		Attack the entity above the turtle.

		@param side The specific tool to use.
			Can either be "left" or "right".
		@throws `haxe.Exception` When `side` is not one of "left" or
			"right".
	**/
	public static function attackUp(?side:String):TurtleActionResult;

	/**
		Attack the entity below the turtle.

		@param side The specific tool to use.
			Can either be "left" or "right".
		@throws `haxe.Exception` When `side` is not one of "left" or
			"right".
	**/
	public static function attackDown(?side:String):TurtleActionResult;

	/**
		Attempt to break the block in front of the turtle.

		This requires a turtle tool capable of breaking the block.
		Diamond pickaxes (mining turtles) can break any vanilla block,
		but other tools (such as axes) are more limited.

		@param side The specific tool to use.
			Can either be "left" or "right".
		@throws `haxe.Exception` When `side` is not one of "left" or
			"right".
	**/
	public static function dig(?side:String):TurtleActionResult;

	/**
		Attempt to break the block above the turtle.
		See <see cref=dig>dig</see> for full details.

		@param side The specific tool to use.
		@throws `haxe.Exception` When `side` is not one of "left" or
			"right".
	**/
	public static function digUp(?side:String):TurtleActionResult;

	/**
		Attempt to break the block below the turtle.
		See <see cref=dig>dig</see> for full details.

		@param side The specific tool to use.
			Can either be "left" or "right".
		@throws `haxe.Exception` When `side` is not one of "left" or
			"right".
	**/
	public static function digDown(?side:String):TurtleActionResult;

	/**
		Place a block or item into the world in front of the turtle.

		"Placing" an item allows it to interact with blocks and
		entities in front of the turtle. For instance, buckets can pick
		up and place down fluids, and wheat can be used to breed cows.
		However, you cannot use `place` to perform arbitrary block
		interactions, such as clicking buttons or flipping levers.

		@param signText When placing a sign, set its contents to this
			text.
	**/
	public static function place(?signText:String):TurtleActionResult;

	/**
		Place a block or item into the world above the turtle.

		@param signText When placing a sign, set its contents to this
			text.
		@see place For more information about placing items.
	**/
	public static function placeUp(?signText:String):TurtleActionResult;

	/**
		Place a block or item into the world below the turtle.

		@param signText When placing a sign, set its contents to this
			text.
		@see place For more information about placing items.
	**/
	public static function placeDown(?signText:String):TurtleActionResult;

	/**
		Check if there is a solid block in front of the turtle.
		In this case, solid refers to any non-air or liquid block.
	**/
	public static function detect():Bool;

	/**
		Check if there is a solid block above the turtle.
		In this case, solid refers to any non-air or liquid block.
	**/
	public static function detectUp():Bool;


	/**
		Check if there is a solid block below the turtle.
		In this case, solid refers to any non-air or liquid block.
	**/
	public static function detectDown():Bool;

	/**
		Get information about the block in front of the turtle.
	**/
	public static function inspect():TurtleInspectResult;

	/**
		Get information about the block above the turtle.
	**/
	public static function inspectUp():TurtleInspectResult;

	/**
		Get information about the block below the turtle.
	**/
	public static function inspectDown():TurtleInspectResult;

	/**
		Check if the block in front of the turtle is equal to the item
		in the currently selected slot.
	**/
	public static function compare():Bool;

	/**
		Check if the block above the turtle is equal to the item in the
		currently selected slot.
	**/
	public static function compareUp():Bool;

	/**
		Check if the block below the turtle is equal to the item in the
		currently selected slot.
	**/
	public static function compareDown():Bool;

	/**
		Compare the item in the currently selected slot to the item in
		another slot.

		@param slot The slot to compare to.
		@throws `haxe.Exception` If the slot is out of range.
	**/
	public static function compareTo(slot:Int):Bool;

	/**
		Drop the currently selected stack into the inventory in front of
		the turtle, or as an item into the world if there is no
		inventory.

		@param The number of items to drop. If not given, the entire
			stack will be dropped.
		@throws `haxe.Exception` If dropping an invalid number of items.
	**/
	public static function drop(?count:Int):TurtleActionResult;

	/**
		Drop the currently selected stack into the inventory above the
		turtle, or as an item into the world if there is no inventory.

		@param The number of items to drop. If not given, the entire
			stack will be dropped.
		@throws `haxe.Exception` If dropping an invalid number of items.
	**/
	public static function dropUp(?count:Int):TurtleActionResult;

	/**
		Drop the currently selected stack into the inventory below the
		turtle, or as an item into the world if there is no inventory.

		@param The number of items to drop. If not given, the entire
			stack will be dropped.
		@throws `haxe.Exception` If dropping an invalid number of items.
	**/
	public static function dropDown(?count:Int):TurtleActionResult;

	/**
		Suck an item from the inventory in front of the turtle, or from
		an item floating in the world.

		This will pull items into the first acceptable slot, starting
		at the <see cref=select>currently selected</see> one.

		@param amount The number of items to suck.
			If not given, up to a stack of items will be picked up.

		@throws `haxe.Exception` If given an invalid number of items.
		@see suckUp, suckDown
	**/
	public static function suck(?amount:Int):TurtleActionResult;

	/**
		Suck an item from the inventory above the turtle, or from an
		item floating in the world.

		@param amount The number of items to suck.
			If not given, up to a stack of items will be picked up.

		@throws `haxe.Exception` If given an invalid number of items.
		@see suck, suckDown
	**/
	public static function suckUp(?amount:Int):TurtleActionResult;

	/**
		Suck an item from the inventory below the turtle, or from an
		item floating in the world.

		@param amount The number of items to suck.
			If not given, up to a stack of items will be picked up.

		@throws `haxe.Exception` If given an invalid number of items.
		@see suck, suckUp
	**/
	public static function suckDown(?amount:Int):TurtleActionResult;

	/**
		Refuel this turtle.

		While most actions a turtle can perform (such as digging or
		placing blocks) are free, moving consumes fuel from the
		turtle's internal buffer. If a turtle has no fuel, it will
		not move.

		`refuel` refuels the turtle, consuming fuel items (such as
		coal or lava buckets) from the currently selected slot and
		converting them into energy. This finishes once the turtle
		is fully refuelled or all items have been consumed.

		@param count The maximum number of items to consume.
			One can pass `0` to check if an item is combustable
			or not.
		@throws `haxe.Exception` If the refuel count is out of range.
	**/
	public static function refuel(?count:Int):TurtleActionResult;

	/**
		Get the amount of fuel this turtle currently holds.

		@returns The current amount of fuel a turtle this turtle has as
			an `Int` or the string "unlimited" if turtles do not
			consume fuel when moving.
	**/
	public static function getFuelLevel():EitherType<Int, Unlimited>;

	/**
		Get the maximum amount of fuel this turtle can hold.

		By default, normal turtles have a limit of 20,000 and advanced
		turtles of 100,000.

		@returns The maximum amount of fuel a turtle this turtle can
			hold as	an `Int` or the string "unlimited" if turtles
			do not consume fuel when moving.
	**/
	public static function getFuelLimit():EitherType<Int, Unlimited>;

	/**
		Move an item from the selected slot to another one.

		@param slot The slot to move this item to.
		@param count The maximum number of items to move.
		@returns If some items were successfully moved.
		@throws `haxe.Exception` If the slot is out of range.
		@throws `haxe.Exception` If the number of items is out of range.
	**/
	public static function transferTo(slot:Int, ?count:Int):Bool;
}
