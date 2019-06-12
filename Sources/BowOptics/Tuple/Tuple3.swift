/// Utility optics over tuples of arity 3.
public enum Tuple3<A, B, C> {
    /// Obtains a Lens that focuses on the first component of a tuple
    public static var _0: Lens<(A, B, C), A> {
        return Lens(get: { x in x.0 }, set: { x, a in (a, x.1, x.2) })
    }
    
    /// Obtains a Lens that focuses on the second component of a tuple
    public static var _1: Lens<(A, B, C), B> {
        return Lens(get: { x in x.1 }, set: { x, b in (x.0, b, x.2) })
    }
    
    /// Obtains a Lens that focuses on the third component of a tuple
    public static var _2: Lens<(A, B, C), C> {
        return Lens(get: { x in x.2 }, set: { x, c in (x.0, x.1, c) })
    }
}
