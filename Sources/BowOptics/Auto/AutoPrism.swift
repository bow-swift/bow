import Bow

/// Protocol for automatic derivation of Prism optics.
public protocol AutoPrism: AutoOptics {}

public extension AutoPrism {
    /// Generates a prism for an enum case with no associated values.
    ///
    /// - Parameter case: Case where the Prism must focus.
    /// - Returns: A Prism focusing on the provided case.
    static func prism(for case: Self) -> Prism<Self, ()> {
        return Prism<Self, ()>(getOrModify: { whole in (String(describing: whole) == String(describing: `case`)) ? Either.right(()) : Either.left(whole) },
                               reverseGet: { _ in `case` })
    }
    
    /// Generates a prism for an enum case with associated values.
    ///
    /// - Parameter constructor: Constructor for the case with associated values.
    /// - Returns: A Prism focusing on the provided case.
    static func prism<A>(for constructor: @escaping (A) -> Self) -> Prism<Self, A> {
        func isSameCase(_ lhs: Self, _ rhs: Self) -> Bool {
            guard let lhsChild = Mirror(reflecting: lhs).children.first,
                  let rhsChild = Mirror(reflecting: rhs).children.first else { return false }
            
            let lhsLabeledChild = Mirror(reflecting: lhsChild.value).children.first
            let rhsLabeledChild = Mirror(reflecting: rhsChild.value).children.first
            
            return lhsChild.label == rhsChild.label &&
                   lhsLabeledChild?.label == rhsLabeledChild?.label
        }
        
        func extractValues(autoPrism: Self) -> A? {
            let mirror = Mirror(reflecting: autoPrism)
            guard let child = mirror.children.first else { return nil }
            
            if let value = child.value as? A {
                return value
            } else {
                let labeledValueMirror = Mirror(reflecting: child.value)
                return labeledValueMirror.children.first?.value as? A
            }
        }
        
        func autoDerivation(autoPrism: Self) -> Either<Self, A> {
            guard let values = extractValues(autoPrism: autoPrism) else { return .left(autoPrism) }
            guard isSameCase(constructor(values), autoPrism) else { return .left(autoPrism) }
            return .right(values)
        }
        
        return Prism<Self, A>(getOrModify: autoDerivation, reverseGet: constructor)
    }
}
