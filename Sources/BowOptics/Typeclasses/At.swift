import Foundation
import Bow

public protocol At {
    associatedtype AtIndex
    associatedtype AtFoci

    static func at(_ i: AtIndex) -> Lens<Self, AtFoci>
}

public extension At {
    func remove<A>(_ i: AtIndex) -> Self where AtFoci == Option<A> {
        return Self.at(i).set(self, .none())
    }
    
    func remove<A>(_ i: AtIndex) -> Self where AtFoci == A? {
        return Self.at(i).set(self, nil)
    }
    
    static func at<B>(_ i: AtIndex, iso: Iso<AtFoci, B>) -> Lens<Self, B> {
        return Self.at(i) + iso
    }
    
    static func at<B>(_ i: AtIndex, iso: Iso<B, Self>) -> Lens<B, AtFoci> {
        return iso + Self.at(i)
    }
}
