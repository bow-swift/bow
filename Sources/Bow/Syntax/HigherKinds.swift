import Foundation

/// Simulates a Higher-Kinded Type in Swift with 1 type argument.
///
/// This class simulates Higher-Kinded Type support in Swift. `Kind<F, A>` is an alias for `F<A>`, which is not syntactically valid in Swift.
/// Classes that want to have HKT support must extend this class. Type parameter `F` is reserved for a witness to prevent circular references in the inheritance relationship. By convention, witnesses are named like the class they represent, with the prefix `For`. As an example:
///
///     class ForOption {}
///     class Option<A>: Kind<ForOption, A> {}
open class Kind<F, A> {
    public init() {}
}

/// Simulates a Higher-Kinded Type in Swift with 2 type arguments.
///
/// This class simulates Higher-Kinded Type support in Swift. `Kind2<F, A, B>` is an alias for `F<A, B>`, which is not syntactically valid in Swift.
/// Classes that want to have HKT support must extend this class. Type parameter `F` is reserved for a witness to prevent circular references in the inheritance relationship. By convention, witnesses are named like the class they represent, with the prefix `For`.
public typealias Kind2<F, A, B> = Kind<Kind<F, A>, B>

/// Simulates a Higher-Kinded Type in Swift with 3 type arguments.
///
/// This class simulates Higher-Kinded Type support in Swift. `Kind3<F, A, B, C>` is an alias for `F<A, B, C>`, which is not syntactically valid in Swift.
/// Classes that want to have HKT support must extend this class. Type parameter `F` is reserved for a witness to prevent circular references in the inheritance relationship. By convention, witnesses are named like the class they represent, with the prefix `For`.
public typealias Kind3<F, A, B, C> = Kind<Kind2<F, A, B>, C>

/// Simulates a Higher-Kinded Type in Swift with 4 type arguments.
///
/// This class simulates Higher-Kinded Type support in Swift. `Kind4<F, A, B, C, D>` is an alias for `F<A, B, C, D>`, which is not syntactically valid in Swift.
/// Classes that want to have HKT support must extend this class. Type parameter `F` is reserved for a witness to prevent circular references in the inheritance relationship. By convention, witnesses are named like the class they represent, with the prefix `For`.
public typealias Kind4<F, A, B, C, D> = Kind<Kind3<F, A, B, C>, D>

/// Simulates a Higher-Kinded Type in Swift with 5 type arguments.
///
/// This class simulates Higher-Kinded Type support in Swift. `Kind5<F, A, B, C, D, E>` is an alias for `F<A, B, C, D, E>`, which is not syntactically valid in Swift.
/// Classes that want to have HKT support must extend this class. Type parameter `F` is reserved for a witness to prevent circular references in the inheritance relationship. By convention, witnesses are named like the class they represent, with the prefix `For`.
public typealias Kind5<F, A, B, C, D, E> = Kind<Kind4<F, A, B, C, D>, E>
