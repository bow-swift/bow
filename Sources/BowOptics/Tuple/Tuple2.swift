/// Utility optics over tuples of arity 2.
public enum Tuple2<A, B> {
    /// Obtains a Lens that focuses on the first component of a tuple
    public static var _0: Lens<(A, B), A> {
        return Lens(get: { x in x.0 }, set: { x, a in (a, x.1) })
    }
    
    /// Obtains a Lens that focuses on the second component of a tuple
    public static var _1: Lens<(A, B), B> {
        return Lens(get: { x in x.1 }, set: { x, b in (x.0, b) })
    }
}
