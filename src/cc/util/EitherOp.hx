package cc.util;

import haxe.ds.Either;

/**
	Implementations of various FP stuff from Scala's `cats` library.
**/
class EitherOp {
	public static inline function flatMap<T, A, B>(x:Either<T, A>, f:A -> Either<T, B>):Either<T, B> {
		return switch (x) {
			case Left(v): Left(v);
			case Right(v): f(v);
		}
	}

	public static inline function map<T, A, B>(x:Either<T, A>, f:A -> B):Either<T, B> {
		return switch (x) {
			case Right(v): Right(f(v));
			case Left(v): Left(v);
		}
	}
}
