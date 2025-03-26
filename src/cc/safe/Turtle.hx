package cc.safe;

import cc.Turtle.Unlimited;
import haxe.ds.Option;
import cc.Turtle.inspectionResultToEither;
import cc.safe.Details.fromOrganizedTable;
import haxe.DynamicAccess;
import haxe.ds.Either;
import cc.Turtle as NativeTurtle;
import cc.Turtle.actionResultToEither;
import cc.util.Unit;

using cc.util.EitherOp;

/**
	A direction the turtle can move in.
**/
enum MovementDirection {
	Forwards;
	Backwards;
	Leftwards;
	Rightwards;
	Upwards;
	Downwards;
}

/**
	One of the sides the turtle can equip an item on.
**/
enum abstract TurtleSide(String) to String {
	/**
		The left side of the turtle.
	**/
	var LeftSide = "left";

	/**
		The right side of the turtle.
	**/
	var RightSide = "right";
}

/**
	Contains information about a block such as its name, state or NBT data.
**/
class BlockDetails {
	/**
		The full internal name of the block, for example
		`minecraft:stone` or `computercraft:wired_modem`.
	**/
	public var name(default, null):String;

	/**
		Various details about the block's state such as its rotation
		or whether its waterlogged or not. These depend on the block
		type, check the minecraft wiki for more info.
	**/
	public var state(default, null):Map<String, Details>;

	/**
		Tags of the block.

		TODO: which ones?
	**/
	public var tags(default, null):Array<String>;

	/**
		Other top-level fields of the table that aren't as
		common and don't have designated accessors.
	**/
	public var otherDetails(default, null):Map<String, Details>;

	/**
		Parses an <see cref=cc.OrganizedTable.OrganizedTable>OrganizedTable</see>
		into a `BlockDetails`.
	**/
	public function new(table:OrganizedTable) {
		var rawTable:DynamicAccess<Dynamic> = table;
		for (fieldName => value in rawTable) {
			switch (fieldName) {
				// this code makes assumptions that these three fields exist for
				// all blocks. not sure how bold those are but i haven't found
				// any counterexamples yet
				case "name": name = value;
				case "state": state = {
					var stateRaw:DynamicAccess<Dynamic> = value;
					[for (stateFieldName => stateFieldValue in stateRaw)
						stateFieldName => fromOrganizedTable(stateFieldValue)
					];
				}
				case ("tags"): tags = {
					// the `tags` field of the `tags` subtable seems to only
					// contain fields the names of which correspond to minecraft
					// tags while the values are always `true`. again, i've never
					// seen those be of any other value. they either exist and
					// are `true` or don't.
					var tagsRaw:DynamicAccess<Bool> = rawTable.get("tags");
					[for (tag in tagsRaw.keys()) tag];
				}
				case _: otherDetails.set(fieldName, Details.fromOrganizedTable(value));
			}
		}
	}
}

/**
	Contains information about an item in the turtle's slot, such as its
	count or name.
**/
class ItemDetails {
	/**
		The internal name of the item, e.g. "computercraft:pocket_computer_advanced"
		for the Advanced Pocket Computer.
	**/
	var name(default, null):String;

	/**
		How many of this item the turtle has.
		This field is always at least `1`.
	**/
	var count(default, null):Int;

	/**
		Other top-level fields of the table that aren't as
		common and don't have designated accessors.
	**/
	var otherDetails(default, null):Map<String, Details>;

	/**
		Parses an <see cref=cc.OrganizedTable.OrganizedTable>OrganizedTable</see>
		into an `ItemDetails`.
	**/
	public function new(table:OrganizedTable) {
		var rawTable:DynamicAccess<Dynamic> = table;
		for (fieldName => value in rawTable) {
			switch (fieldName) {
				// see BlockDetails.new
				case "name": name = value;
				case "count": count = value;
				case _: otherDetails.set(fieldName, Details.fromOrganizedTable(value));
			}
		}
	}
}

/**
	Type safe bindings for the `turtle` table. These are expected to
	generally be slightly slower than the ones in <see cref=cc.Turtle>
	cc.Turtle</see> because the return values of the methods have to be
	wrapped in their safer equivalents.

	Use <see cref=cc.Turtle>cc.Turtle</see> if you need access to a more
	native-like interface with minimal preformance overhead.
**/
class Turtle {
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
	public static inline function craft(limit:Int = 64):Either<String, Unit> {
		return actionResultToEither(NativeTurtle.forward());
	}

	/**
		Move the turtle one step in the specified direction.
	**/
	public static inline function step(direction:MovementDirection):Either<String, Unit> {
		return switch (direction) {
			case Forwards: forward();
			case Backwards: back();
			case Downwards: down();
			case Upwards: up();
			case Leftwards: turnLeft().flatMap(_ -> forward());
			case Rightwards: turnRight().flatMap(_ -> forward());
		}
	}

	/**
		Move the turtle forward one block.
	**/
	public static inline function forward():Either<String, Unit> {
		return actionResultToEither(NativeTurtle.forward());
	}

	/**
		Move the turtle backwards one block.
	**/
	public static inline function back():Either<String, Unit> {
		return actionResultToEither(NativeTurtle.back());
	}

	/**
		Move the turtle up one block.
	**/
	public static inline function up():Either<String, Unit> {
		return actionResultToEither(NativeTurtle.up());
	}

	/**
		Move the turtle down one block.
	**/
	public static inline function down():Either<String, Unit> {
		return actionResultToEither(NativeTurtle.down());
	}

	/**
		Rotate the turtle 90 degrees to the left.
	**/
	public static inline function turnLeft():Either<String, Unit> {
		return actionResultToEither(NativeTurtle.turnLeft());
	}

	/**
		Rotate the turtle 90 degrees to the right.
	**/
	public static inline function turnRight():Either<String, Unit> {
		return actionResultToEither(NativeTurtle.turnRight());
	}

	/**
		Change the currently selected slot.

		The selected slot is determines what slot actions like `drop`
		or `getItemCount` act on.

		@param slot The slot to select.
		@throws `haxe.Exception` If the slot is out of range.
		@see `getSelectedSlot`
	**/
	public static inline function select(slot:Int):Bool {
		return NativeTurtle.select(slot);
	}

	/**
		Get the currently selected slot.

		@see `select`
	**/
	public static inline function getSelectedSlot():Int {
		return NativeTurtle.getSelectedSlot();
	}

	/**
		Get the number of items in the given slot.

		The `slot` argument is the slot we wish to check. Defaults to
		the selected slot.

		@param slot The slot we wish to check. Defaults to the
			<see cref=select>selected slot</see>.
		@throws `haxe.Exception` If the slot is out of range.
	**/
	public static inline function getItemCount(?slot:Int):Int {
		return NativeTurtle.getItemCount(slot);
	}

	/**
		Get the remaining number of items which may be stored in this
		stack.

		For instance, if a slot contains 13 blocks of dirt, it has
		room for another 51.

		@param slot The slot we wish to check. Defaults to the
			<see cref=select>selected slot</see>.
		@throws `haxe.Exception` If the slot is out of range.
	**/
	public static inline function getItemSpace(?slot:Int):Int {
		return NativeTurtle.getItemSpace();
	}

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
	public static inline function getItemDetail(?slot:Int, ?detailed:Bool):ItemDetails {
		return new ItemDetails(NativeTurtle.getItemDetail(slot, detailed));
	}

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
	public static inline function equipLeft():Either<String, Unit> {
		return actionResultToEither(NativeTurtle.equipLeft());
	}

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
	public static inline function equipRight():Either<String, Unit> {
		return actionResultToEither(NativeTurtle.equipRight());
	}

	/**
		Attack the entity in front of the turtle.

		@param side The specific tool to use.
			Can either be "left" or "right".
	**/
	public static inline function attack(?side:TurtleSide):Either<String, Unit> {
		return actionResultToEither(NativeTurtle.attack((side:String)));
	}

	/**
		Attack the entity above the turtle.

		@param side The specific tool to use.
			Can either be "left" or "right".
		@throws `haxe.Exception` When `side` is not one of "left" or
			"right".
	**/
	public static inline function attackUp(?side:TurtleSide):Either<String, Unit> {
		return actionResultToEither(NativeTurtle.attackUp((side:String)));
	}

	/**
		Attack the entity below the turtle.

		@param side The specific tool to use.
			Can either be "left" or "right".
		@throws `haxe.Exception` When `side` is not one of "left" or
			"right".
	**/
	public static inline function attackDown(?side:TurtleSide):Either<String, Unit> {
		return actionResultToEither(NativeTurtle.attackDown((side:String)));
	}

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
	public static inline function dig(?side:TurtleSide):Either<String, Unit> {
		return actionResultToEither(NativeTurtle.dig((side:String)));
	}

	/**
		Attempt to break the block above the turtle.
		See <see cref=dig>dig</see> for full details.

		@param side The specific tool to use.
		@throws `haxe.Exception` When `side` is not one of "left" or
			"right".
	**/
	public static inline function digUp(?side:TurtleSide):Either<String, Unit> {
		return actionResultToEither(NativeTurtle.digUp((side:String)));
	}

	/**
		Attempt to break the block below the turtle.
		See <see cref=dig>dig</see> for full details.

		@param side The specific tool to use.
			Can either be "left" or "right".
		@throws `haxe.Exception` When `side` is not one of "left" or
			"right".
	**/
	public static inline function digDown(?side:TurtleSide):Either<String, Unit> {
		return actionResultToEither(NativeTurtle.digDown((side:String)));
	}

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
	public static inline function place(?signText:String):Either<String, Unit> {
		return actionResultToEither(NativeTurtle.place(signText));
	}

	/**
		Place a block or item into the world above the turtle.

		@param signText When placing a sign, set its contents to this
			text.
		@see place For more information about placing items.
	**/
	public static inline function placeUp(?signText:String):Either<String, Unit> {
		return actionResultToEither(NativeTurtle.placeUp(signText));
	}

	/**
		Place a block or item into the world below the turtle.

		@param signText When placing a sign, set its contents to this
			text.
		@see place For more information about placing items.
	**/
	public static inline function placeDown(?signText:String):Either<String, Unit> {
		return actionResultToEither(NativeTurtle.placeDown(signText));
	}

	/**
		Check if there is a solid block in front of the turtle.
		In this case, solid refers to any non-air or liquid block.
	**/
	public static inline function detect():Bool {
		return NativeTurtle.detect();
	}

	/**
		Check if there is a solid block above the turtle.
		In this case, solid refers to any non-air or liquid block.
	**/
	public static inline function detectUp():Bool {
		return NativeTurtle.detectUp();
	}


	/**
		Check if there is a solid block below the turtle.
		In this case, solid refers to any non-air or liquid block.
	**/
	public static inline function detectDown():Bool {
		return NativeTurtle.detectDown();
	}

	/**
		Get information about the block in front of the turtle.
	**/
	public static inline function inspect():Either<String, BlockDetails> {
		return inspectionResultToEither(NativeTurtle.inspect())
			.map(BlockDetails.new);
	}

	/**
		Get information about the block above the turtle.
	**/
	public static inline function inspectUp():Either<String, BlockDetails> {
		return inspectionResultToEither(NativeTurtle.inspectUp())
			.map(BlockDetails.new);
	}

	/**
		Get information about the block below the turtle.
	**/
	public static inline function inspectDown():Either<String, BlockDetails> {
		return inspectionResultToEither(NativeTurtle.inspectDown())
			.map(BlockDetails.new);
	}

	/**
		Check if the block in front of the turtle is equal to the item
		in the currently selected slot.
	**/
	public static inline function compare():Bool {
		return NativeTurtle.compare();
	}

	/**
		Check if the block above the turtle is equal to the item in the
		currently selected slot.
	**/
	public static inline function compareUp():Bool {
		return NativeTurtle.compareUp();
	}

	/**
		Check if the block below the turtle is equal to the item in the
		currently selected slot.
	**/
	public static inline function compareDown():Bool {
		return NativeTurtle.compareDown();
	}

	/**
		Compare the item in the currently selected slot to the item in
		another slot.

		@param slot The slot to compare to.
		@throws `haxe.Exception` If the slot is out of range.
	**/
	public static inline function compareTo(slot:Int):Bool {
		return NativeTurtle.compareTo(slot);
	}

	/**
		Drop the currently selected stack into the inventory in front of
		the turtle, or as an item into the world if there is no
		inventory.

		@param The number of items to drop. If not given, the entire
			stack will be dropped.
		@throws `haxe.Exception` If dropping an invalid number of items.
	**/
	public static inline function drop(?count:Int):Either<String, Unit> {
		return actionResultToEither(NativeTurtle.drop(count));
	}

	/**
		Drop the currently selected stack into the inventory above the
		turtle, or as an item into the world if there is no inventory.

		@param The number of items to drop. If not given, the entire
			stack will be dropped.
		@throws `haxe.Exception` If dropping an invalid number of items.
	**/
	public static inline function dropUp(?count:Int):Either<String, Unit> {
		return actionResultToEither(NativeTurtle.dropUp(count));
	}

	/**
		Drop the currently selected stack into the inventory below the
		turtle, or as an item into the world if there is no inventory.

		@param The number of items to drop. If not given, the entire
			stack will be dropped.
		@throws `haxe.Exception` If dropping an invalid number of items.
	**/
	public static inline function dropDow(?count:Int):Either<String, Unit> {
		return actionResultToEither(NativeTurtle.dropDown(count));
	}

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
	public static inline function suck(?amount:Int):Either<String, Unit> {
		return actionResultToEither(NativeTurtle.suck(amount));
	}

	/**
		Suck an item from the inventory above the turtle, or from an
		item floating in the world.

		@param amount The number of items to suck.
			If not given, up to a stack of items will be picked up.

		@throws `haxe.Exception` If given an invalid number of items.
		@see suck, suckDown
	**/
	public static inline function suckUp(?amount:Int):Either<String, Unit> {
		return actionResultToEither(NativeTurtle.suckUp(amount));
	}

	/**
		Suck an item from the inventory below the turtle, or from an
		item floating in the world.

		@param amount The number of items to suck.
			If not given, up to a stack of items will be picked up.

		@throws `haxe.Exception` If given an invalid number of items.
		@see suck, suckUp
	**/
	public static inline function suckDown(?amount:Int):Either<String, Unit> {
		return actionResultToEither(NativeTurtle.suckDown(amount));
	}

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
	public static inline function refuel(?count:Int):Either<String, Unit> {
		return actionResultToEither(NativeTurtle.refuel(count));
	}

	/**
		Get the amount of fuel this turtle currently holds.

		@returns The current amount of fuel a turtle this turtle has.
			`None` means turtles don't consume fuel.
	**/
	public static inline function getFuelLevel():Option<Int> {
		return switch (NativeTurtle.getFuelLevel()) {
			case Unlimited: None;
			case n: Some(n);
		}
	}

	/**
		Get the maximum amount of fuel this turtle can hold.

		By default, normal turtles have a limit of 20,000 and advanced
		turtles of 100,000.

		@returns The maximum amount of fuel a turtle this turtle can
			hold. `None` means turtles don't consume fuel.
	**/
	public static inline function getFuelLimit():Option<Int> {
		return switch (NativeTurtle.getFuelLimit()) {
			case Unlimited: None;
			case n: Some(n);
		}
	}

	/**
		Move an item from the selected slot to another one.

		@param slot The slot to move this item to.
		@param count The maximum number of items to move.
		@returns If some items were successfully moved.
		@throws `haxe.Exception` If the slot is out of range.
		@throws `haxe.Exception` If the number of items is out of range.
	**/
	public static inline function transferTo(slot:Int, ?count:Int):Bool {
		return NativeTurtle.transferTo(slot, count);
	}
}
