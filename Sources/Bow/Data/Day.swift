import Foundation

public class ForDay {}
public typealias DayOf<F, G, A> = Kind3<ForDay, F, G, A>

public class Day<F, G, A> : DayOf<F, G, A> {
    public static func fix(_ value : DayOf<F, G, A>) -> Day<F, G, A> {
        return value as! Day<F, G, A>
    }
    
    public static func pure<ApplF, ApplG>(_ applicativeF : ApplF, _ applicativeG : ApplG, _ a : A) -> Day<F, G, A> where ApplF : Applicative, ApplF.F == F, ApplG : Applicative, ApplG.F == G {
        return DefaultDay(left: applicativeF.pure(unit),
                          right: applicativeG.pure(unit),
                          f: constant(a))
    }
    
    public static func from<X, Y>(left : Kind<F, X>, right : Kind<G, Y>, f : @escaping (X, Y) -> A) -> Day<F, G, A> {
        return DefaultDay(left: left, right: right, f: f)
    }
    
    public func runDay<ComonF, ComonG>(_ comonadF : ComonF, _ comonadG : ComonG) -> A where ComonF : Comonad, ComonF.F == F, ComonG : Comonad, ComonG.F == G {
        return extract(comonadF, comonadG)
    }
    
    public func extract<ComonF, ComonG>(_ comonadF : ComonF, _ comonadG : ComonG) -> A where ComonF : Comonad, ComonF.F == F, ComonG : Comonad, ComonG.F == G {
        fatalError("extract must be implemented in subclasses")
    }
    
    public func map<B>(_ f : @escaping (A) -> B) -> Day<F, G, B> {
        fatalError("map must be implemented in subclasses")
    }
    
    public func ap<B, ApplF, ApplG>(_ applicativeF : ApplF, _ applicativeG : ApplG, _ f : DayOf<F, G, (A) -> B>) -> Day<F, G, B> where ApplF : Applicative, ApplF.F == F, ApplG : Applicative, ApplG.F == G {
        fatalError("ap must be implemented in subclasses")
    }
    
    public func coflatMap<B, ComonF, ComonG>(_ comonadF : ComonF, _ comonadG : ComonG, _ f : @escaping (DayOf<F, G, A>) -> B) -> Day<F, G, B> where ComonF : Comonad, ComonF.F == F, ComonG : Comonad, ComonG.F == G {
        fatalError("coflatMap must be implemented in subclasses")
    }
}

fileprivate class DefaultDay<F, G, X, Y, A> : Day<F, G, A> {
    private let left : Kind<F, X>
    private let right : Kind<G, Y>
    private let f : (X, Y) -> A
    
    init(left : Kind<F, X>, right : Kind<G, Y>, f : @escaping (X, Y) -> A) {
        self.left = left
        self.right = right
        self.f = f
    }
    
    func stepDay<R>(_ ff: @escaping (Kind<F, X>, Kind<G, Y>, @escaping (X, Y) -> A) -> R) -> R {
        return ff(left, right, { a, b in self.f(a, b) })
    }
    
    override public func extract<ComonF, ComonG>(_ comonadF : ComonF, _ comonadG : ComonG) -> A where ComonF : Comonad, ComonF.F == F, ComonG : Comonad, ComonG.F == G {
        return self.stepDay { left, right, get in
            get(comonadF.extract(left), comonadG.extract(right))
        }
    }
    
    override public func map<B>(_ f : @escaping (A) -> B) -> Day<F, G, B> {
        return self.stepDay { left, right, get in
            DefaultDay<F, G, X, Y, B>(left: left, right: right) { x, y in
                f(get(x, y))
            }
        }
    }
    
    override public func ap<B, ApplF, ApplG>(_ applicativeF : ApplF, _ applicativeG : ApplG, _ f : DayOf<F, G, (A) -> B>) -> Day<F, G, B> where ApplF : Applicative, ApplF.F == F, ApplG : Applicative, ApplG.F == G {
        return self.stepDay { left, right, get in
            (Day<F, G, (A) -> B>.fix(f) as! DefaultDay<F, G, X, Y, (A) -> B>).stepDay { lf, rf, getf in
                let l = applicativeF.tupled(left, lf)
                let r = applicativeG.tupled(right, rf)
                return DefaultDay<F, G, (X, X), (Y, Y), B>(left: l, right: r) { x, y in
                    getf(x.1, y.1)(get(x.0, y.0))
                }
            }
        }
    }
    
    override public func coflatMap<B, ComonF, ComonG>(_ comonadF : ComonF, _ comonadG : ComonG, _ f : @escaping (DayOf<F, G, A>) -> B) -> Day<F, G, B> where ComonF : Comonad, ComonF.F == F, ComonG : Comonad, ComonG.F == G {
        return self.stepDay { left, right, get in
            let l = comonadF.duplicate(left)
            let r = comonadG.duplicate(right)
            return DefaultDay<F, G, Kind<F, X>, Kind<G, Y>, B>(left: l, right: r) { x, y in
                f(DefaultDay(left: x, right: y, f: get))
            }
        }
    }
}
