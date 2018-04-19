import Foundation

public class Tuple<A, B> {
    public static func eq<EqA, EqB>(_ eqa : EqA, _ eqb : EqB) -> TupleEq<A, B, EqA, EqB> {
        return TupleEq<A, B, EqA, EqB>(eqa, eqb)
    }
}

public class TupleEq<M, N, EqM, EqN> : Eq where EqM : Eq, EqM.A == M, EqN : Eq, EqN.A == N {
    public typealias A = (M, N)
    
    private let eqm : EqM
    private let eqn : EqN
    
    public init(_ eqm : EqM, _ eqn : EqN) {
        self.eqm = eqm
        self.eqn = eqn
    }
    
    public func eqv(_ a: (M, N), _ b: (M, N)) -> Bool {
        return eqm.eqv(a.0, b.0) && eqn.eqv(a.1, b.1)
    }
}
