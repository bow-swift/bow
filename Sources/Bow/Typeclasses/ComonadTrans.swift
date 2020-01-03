public protocol ComonadTrans {
    static func lower<W: Comonad, A>(_ twa: Kind<Self, Kind<W, A>>) -> Kind<W, A>
}

// MARK: Syntax for ComonadTrans

public extension Kind where F: ComonadTrans {
    func lower<W: Comonad, B>() -> Kind<W, B> where A == Kind<W, B> {
        F.lower(self)
    }
}
