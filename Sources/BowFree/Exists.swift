import Foundation
import Bow

public final class Exists<F> {
    public init<A>(_ fa: Kind<F, A>) {
        self.fa = fa
    }
    let fa: Any

    // (∀X. F<X> -> R) -> R
    public func run<R>(_ f: CokleisliK<F, R>) -> R {
        switch fa {
        case let fi as Kind<F, Int>:
            return f.invoke(fi)
        case let fi as Kind<F, (Int) -> Int>:
            return f.invoke(fi)
        case let fi as Kind<F, (@escaping (Int) -> (Int)) -> Int>:
            return f.invoke(fi)
        case let fi as Kind<F, (Int, Int)>:
            return f.invoke(fi)
        case let fi as Kind<F, ((Int, Int), Int)>:
            return f.invoke(fi)
        case let fi as Kind<F, ((Int, Int, Int), Int)>:
            return f.invoke(fi)
        case let fi as Kind<F, ((Int, Int, Int, Int), Int)>:
            return f.invoke(fi)
        case let fi as Kind<F, ((Int, Int, Int, Int, Int), Int)>:
            return f.invoke(fi)
        case let fi as Kind<F, ((Int, Int, Int, Int, Int, Int), Int)>:
            return f.invoke(fi)
        case let fi as Kind<F, ((Int, Int, Int, Int, Int, Int, Int), Int)>:
            return f.invoke(fi)
        case let fi as Kind<F, ((Int, Int, Int, Int, Int, Int, Int, Int), Int)>:
            return f.invoke(fi)
        case let fi as Kind<F, Kind<CoyonedaPartial<ForId>, Int>>:
            return f.invoke(fi)
        case let fi as Kind<F, Double>:
            return f.invoke(fi)
        case let fi as Kind<F, String>:
            return f.invoke(fi)
        case let fi as Kind<F, Either<Int, Int>>:
            return f.invoke(fi)
        case let fi as Kind<F, ((Int) -> Int, (Int) -> Int)>:
            return f.invoke(fi)
        case let fi as Kind<F, Either<Int, (Int) -> Int>>:
            return f.invoke(fi)
        case let fi as Kind<F, (Int) -> (Int) -> Int>:
            return f.invoke(fi)
        case let fi as Kind<F, Either<(Int, Int), Int>>:
            return f.invoke(fi)
        case let fi as Kind<F, Id<Int>>:
            return f.invoke(fi)
        default:
            fatalError()
        }
    }
}
