import Bow

public extension StateT where F: Functor {
    /// Generalizes this StateT to a parent state, given a lens to focus from the parent to the child state.
    ///
    /// - Parameters:
    ///   - lens: A Lens to focus from the parent state into the child state.
    /// - Returns: An `StateT` that produces the same computation but updates the state in a parent state.
    func focus<SS>(_ lens: Lens<SS, S>) -> StateT<F, SS, A> {
        self.focus(lens.get, lens.set)
    }
}
