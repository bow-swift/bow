public struct Tuple2<A, B> {
	public let a: A
	public let b: B
	
	public init(_ a: A, _ b: B) {
		self.a = a
		self.b = b
	}
}

extension Tuple2: Equatable where A: Equatable, B: Equatable {}
