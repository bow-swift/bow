import Foundation

public protocol Generic {
    associatedtype T
    associatedtype Repr
    
    func to(_ t: T) -> Repr
    func from(_ r: Repr) -> T
}
