import SwiftCheck
import Bow

public class SemigroupalLaws<A: Semigroupal & EquatableK> {
	public static func check(
		using bijection: @escaping (Kind<A, Tuple2<Tuple2<Int, Int>, Int>>) -> Kind<A, Tuple2<Int, Tuple2<Int, Int>>>,
		and transform: @escaping (Int) -> Kind<A, Int>
	) {
		associativity(under: bijection, and: transform)
	}
	
	private static func associativity(
		under bijection: @escaping (Kind<A, Tuple2<Tuple2<Int, Int>, Int>>) -> Kind<A, Tuple2<Int, Tuple2<Int, Int>>>,
		and transform: @escaping (Int) -> Kind<A, Int>
	) {
		property("Associativity") <~ forAll { (a: Int, b: Int, c: Int) in
			let fa = transform(a)
			let fb = transform(b)
			let fc = transform(c)
			
			let productOfAB = A.product(fa, fb)
			let productOfBC = A.product(fb, fc)
						
			return A.product(fa, productOfBC) == bijection(A.product(productOfAB, fc))
		}
	}
}
