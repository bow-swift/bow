/// Utility optics over tuples of arity 4.
public enum Tuple4<A, B, C, D> {
    /// Obtains a Lens that focuses on the first component of a tuple
    public static var _0: Lens<(A, B, C, D), A> {
        return Lens(get: { x in x.0 }, set: { x, a in (a, x.1, x.2, x.3) })
    }
    
    /// Obtains a Lens that focuses on the second component of a tuple
    public static var _1: Lens<(A, B, C, D), B> {
        return Lens(get: { x in x.1 }, set: { x, b in (x.0, b, x.2, x.3) })
    }
    
    /// Obtains a Lens that focuses on the third component of a tuple
    public static var _2: Lens<(A, B, C, D), C> {
        return Lens(get: { x in x.2 }, set: { x, c in (x.0, x.1, c, x.3) })
    }
    
    /// Obtains a Lens that focuses on the forth component of a tuple
    public static var _3: Lens<(A, B, C, D), D> {
        return Lens(get: { x in x.3 }, set: { x, d in (x.0, x.1, x.2, d) })
    }
}
