import Foundation
import Bow

//public extension Lens {
//    func at<AtType, I, T>(_ at: AtType, _ i: I) -> Lens<S, T> where AtType: At, AtType.S == A, AtType.I == I, AtType.A == T {
//        return (self as! Lens<S, A>) + at.at(i)
//    }
//}
//
//public extension Iso {
//    func at<AtType, I, T>(_ at: AtType, _ i: I) -> Lens<S, T> where AtType: At, AtType.S == A, AtType.I == I, AtType.A == T {
//        return (self as! Iso<S, A>) + at.at(i)
//    }
//}
//
//public extension Prism {
//    func at<AtType, I, T>(_ at: AtType, _ i: I) -> Optional<S, T> where AtType: At, AtType.S == A, AtType.I == I, AtType.A == T {
//        return (self as! Prism<S, A>) + at.at(i)
//    }
//}
//
//public extension Optional {
//    func at<AtType, I, T>(_ at: AtType, _ i: I) -> Optional<S, T> where AtType: At, AtType.S == A, AtType.I == I, AtType.A == T {
//        return (self as! Optional<S, A>) + at.at(i)
//    }
//}
//
//public extension Getter {
//    func at<AtType, I, T>(_ at: AtType, _ i: I) -> Getter<S, T> where AtType: At, AtType.S == A, AtType.I == I, AtType.A == T {
//        return self + at.at(i)
//    }
//}
//
//public extension Setter {
//    func at<AtType, I, T>(_ at: AtType, _ i: I) -> Setter<S, T> where AtType: At, AtType.S == A, AtType.I == I, AtType.A == T {
//        return (self as! Setter<S, A>) + at.at(i)
//    }
//}
//
//public extension Traversal {
//    func at<AtType, I, T>(_ at: AtType, _ i: I) -> Traversal<S, T> where AtType: At, AtType.S == A, AtType.I == I, AtType.A == T {
//        return (self as! Traversal<S, A>) + at.at(i)
//    }
//}
//
//public extension Fold {
//    func at<AtType, I, T>(_ at: AtType, _ i: I) -> Fold<S, T> where AtType: At, AtType.S == A, AtType.I == I, AtType.A == T {
//        return self + at.at(i)
//    }
//}
