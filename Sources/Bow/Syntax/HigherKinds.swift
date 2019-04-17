import Foundation

/// Simulates a Higher-Kinded Type in Swift with 1 type argument.
///
/// This class simulates Higher-Kinded Type support in Swift. `Kind<F, A>` is an alias for `F<A>`, which is not syntactically valid in Swift.
/// Classes that want to have HKT support must extend this class. Type parameter `F` is reserved for a witness to prevent circular references in the inheritance relationship. By convention, witnesses are named like the class they represent, with the prefix `For`. As an example:
///
///     class ForOption {}
///     class Option<A>: Kind<ForOption, A> {}
open class Kind<F, A> {
    /// Default initializer
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

/// Simulates a Higher-Kinded Type in Swift with 6 type arguments.
///
/// This class simulates Higher-Kinded Type support in Swift. `Kind6<F, A, B, C, D, E, G>` is an alias for `F<A, B, C, D, E, G>`, which is not syntactically valid in Swift.
/// Classes that want to have HKT support must extend this class. Type parameter `F` is reserved for a witness to prevent circular references in the inheritance relationship. By convention, witnesses are named like the class they represent, with the prefix `For`.
public typealias Kind6<F, A, B, C, D, E, G> = Kind<Kind5<F, A, B, C, D, E>, G>

/// Simulates a Higher-Kinded Type in Swift with 7 type arguments.
///
/// This class simulates Higher-Kinded Type support in Swift. `Kind7<F, A, B, C, D, E, G, H>` is an alias for `F<A, B, C, D, E, G, H>`, which is not syntactically valid in Swift.
/// Classes that want to have HKT support must extend this class. Type parameter `F` is reserved for a witness to prevent circular references in the inheritance relationship. By convention, witnesses are named like the class they represent, with the prefix `For`.
public typealias Kind7<F, A, B, C, D, E, G, H> = Kind<Kind6<F, A, B, C, D, E, G>, H>

/// Simulates a Higher-Kinded Type in Swift with 8 type arguments.
///
/// This class simulates Higher-Kinded Type support in Swift. `Kind8<F, A, B, C, D, E, G, H, I>` is an alias for `F<A, B, C, D, E, G, H, I>`, which is not syntactically valid in Swift.
/// Classes that want to have HKT support must extend this class. Type parameter `F` is reserved for a witness to prevent circular references in the inheritance relationship. By convention, witnesses are named like the class they represent, with the prefix `For`.
public typealias Kind8<F, A, B, C, D, E, G, H, I> = Kind<Kind7<F, A, B, C, D, E, G, H>, I>

/// Simulates a Higher-Kinded Type in Swift with 9 type arguments.
///
/// This class simulates Higher-Kinded Type support in Swift. `Kind9<F, A, B, C, D, E, G, H, I, J>` is an alias for `F<A, B, C, D, E, G, H, I, J>`, which is not syntactically valid in Swift.
/// Classes that want to have HKT support must extend this class. Type parameter `F` is reserved for a witness to prevent circular references in the inheritance relationship. By convention, witnesses are named like the class they represent, with the prefix `For`.
public typealias Kind9<F, A, B, C, D, E, G, H, I, J> = Kind<Kind8<F, A, B, C, D, E, G, H, I>, J>

/// Simulates a Higher-Kinded Type in Swift with 10 type arguments.
///
/// This class simulates Higher-Kinded Type support in Swift. `Kind10<F, A, B, C, D, E, G, H, I, J, K>` is an alias for `F<A, B, C, D, E, G, H, I, J, K>`, which is not syntactically valid in Swift.
/// Classes that want to have HKT support must extend this class. Type parameter `F` is reserved for a witness to prevent circular references in the inheritance relationship. By convention, witnesses are named like the class they represent, with the prefix `For`.
public typealias Kind10<F, A, B, C, D, E, G, H, I, J, K> = Kind<Kind9<F, A, B, C, D, E, G, H, I, J>, K>

postfix operator ^
