/// Utility optics over tuples of arity 7.
public enum Tuple7<A, B, C, D, E, F, G> {
    /// Obtains a Lens that focuses on the first component of a tuple
    public static var _0: Lens<(A, B, C, D, E, F, G), A> {
        return Lens(get: { x in x.0 }, set: { x, a in (a, x.1, x.2, x.3, x.4, x.5, x.6) })
    }
    
    /// Obtains a Lens that focuses on the second component of a tuple
    public static var _1: Lens<(A, B, C, D, E, F, G), B> {
        return Lens(get: { x in x.1 }, set: { x, b in (x.0, b, x.2, x.3, x.4, x.5, x.6) })
    }
    
    /// Obtains a Lens that focuses on the third component of a tuple
    public static var _2: Lens<(A, B, C, D, E, F, G), C> {
        return Lens(get: { x in x.2 }, set: { x, c in (x.0, x.1, c, x.3, x.4, x.5, x.6) })
    }
    
    /// Obtains a Lens that focuses on the forth component of a tuple
    public static var _3: Lens<(A, B, C, D, E, F, G), D> {
        return Lens(get: { x in x.3 }, set: { x, d in (x.0, x.1, x.2, d, x.4, x.5, x.6) })
    }
    
    /// Obtains a Lens that focuses on the fifth component of a tuple
    public static var _4: Lens<(A, B, C, D, E, F, G), E> {
        return Lens(get: { x in x.4 }, set: { x, e in (x.0, x.1, x.2, x.3, e, x.5, x.6) })
    }
    
    /// Obtains a Lens that focuses on the sixth component of a tuple
    public static var _5: Lens<(A, B, C, D, E, F, G), F> {
        return Lens(get: { x in x.5 }, set: { x, f in (x.0, x.1, x.2, x.3, x.4, f, x.6) })
    }
    
    /// Obtains a Lens that focuses on the seventh component of a tuple
    public static var _6: Lens<(A, B, C, D, E, F, G), G> {
        return Lens(get: { x in x.6 }, set: { x, g in (x.0, x.1, x.2, x.3, x.4, x.5, g) })
    }
}
