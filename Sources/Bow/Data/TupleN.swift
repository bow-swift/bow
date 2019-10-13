public struct Tuple2<A, B> {
	let a: A
	let b: B
}

extension Tuple2: Equatable where A: Equatable, B: Equatable {}
