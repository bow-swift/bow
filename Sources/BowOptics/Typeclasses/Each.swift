import Foundation
import Bow

public protocol Each {
    associatedtype EachFoci

    static var each: Traversal<Self, EachFoci> { get }
}

public extension Each {
    static func each<B>(_ iso: Iso<B, Self>) -> Traversal<B, EachFoci> {
        return iso + each
    }
    
    static func each<B>(_ iso: Iso<EachFoci, B>) -> Traversal<Self, B> {
        return each + iso
    }
}
