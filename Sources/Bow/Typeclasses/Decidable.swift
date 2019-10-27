/// Decidable is a typeclass modeling contravariant decision. Decidable is the contravariant version of Alternative.
///
/// Decidable basically states: Given a Kind<F, A> and a Kind<F, B> and a way to turn Z into either A or B it gives you a Kind<F, Z>.
public protocol Decidable: Divisible {
    ///
    /// choose takes two data-types of type `Kind<F, A>` and `Kind<F, B>` and produces a type of `Kind<F, Z>` when given
    /// a function from `Z -> Either<A, B>`.
    static func choose<A, B, Z>(_ fa: Kind<Self, A>, _ fb: Kind<Self, B>, _ f: (Z) -> Either<A, B>) -> Kind<Self, Z>
}

// MARK: - Decidable syntax
public extension Decidable {
    static func choose<A, B, C, Z>(_ fa: Kind<Self, A>, _ fb: Kind<Self, B>, _ fc: Kind<Self, C>, _ f: (Z) -> Either<A, Either<B, C>>) -> Kind<Self, Z> {
        choose(fa, choose(fb, fc, id), f)
    }
    
    static func choose<A, B, C, D, Z>(_ fa: Kind<Self, A>, _ fb: Kind<Self, B>, _ fc: Kind<Self, C>, _ fd: Kind<Self, D>, _ f: (Z) -> Either<A, Either<B, Either<C, D>>>) -> Kind<Self, Z> {
        choose(
            fa,
            fb,
            choose(fc, fd, id),
            f
        )
    }
    
    static func choose<A, B, C, D, E, Z>(
        _ fa: Kind<Self, A>,
        _ fb: Kind<Self, B>,
        _ fc: Kind<Self, C>,
        _ fd: Kind<Self, D>,
        _ fe: Kind<Self, E>,
        _ f: (Z) -> Either<A, Either<B, Either<C, Either<D, E>>>>
    ) -> Kind<Self, Z> {
        choose(
            fa,
            fb,
            fc,
            choose(fd, fe, id),
            f
        )
    }
    
    static func choose<A, B, C, D, E, FF, Z>(
        _ fa: Kind<Self, A>,
        _ fb: Kind<Self, B>,
        _ fc: Kind<Self, C>,
        _ fd: Kind<Self, D>,
        _ fe: Kind<Self, E>,
        _ ff: Kind<Self, FF>,
        _ f: (Z) -> Either<A, Either<B, Either<C, Either<D, Either<E, FF>>>>>
    ) -> Kind<Self, Z> {
        choose(
            fa,
            fb,
            fc,
            fd,
            choose(fe, ff, id),
            f
        )
    }
    
    static func choose<A, B, C, D, E, FF, G, Z>(
        _ fa: Kind<Self, A>,
        _ fb: Kind<Self, B>,
        _ fc: Kind<Self, C>,
        _ fd: Kind<Self, D>,
        _ fe: Kind<Self, E>,
        _ ff: Kind<Self, FF>,
        _ fg: Kind<Self, G>,
        _ f: (Z) -> Either<A, Either<B, Either<C, Either<D, Either<E, Either<FF, G>>>>>>
    ) -> Kind<Self, Z> {
        choose(
            fa,
            fb,
            fc,
            fd,
            fe,
            choose(ff, fg, id),
            f
        )
    }
    
    static func choose<A, B, C, D, E, FF, G, H, Z>(
        _ fa: Kind<Self, A>,
        _ fb: Kind<Self, B>,
        _ fc: Kind<Self, C>,
        _ fd: Kind<Self, D>,
        _ fe: Kind<Self, E>,
        _ ff: Kind<Self, FF>,
        _ fg: Kind<Self, G>,
        _ fh: Kind<Self, H>,
        _ f: (Z) -> Either<A, Either<B, Either<C, Either<D, Either<E, Either<FF, Either<G, H>>>>>>>
    ) -> Kind<Self, Z> {
        choose(
            fa,
            fb,
            fc,
            fd,
            fe,
            ff,
            choose(fg, fh, id),
            f
        )
    }
    
    static func choose<A, B, C, D, E, FF, G, H, I, Z>(
        _ fa: Kind<Self, A>,
        _ fb: Kind<Self, B>,
        _ fc: Kind<Self, C>,
        _ fd: Kind<Self, D>,
        _ fe: Kind<Self, E>,
        _ ff: Kind<Self, FF>,
        _ fg: Kind<Self, G>,
        _ fh: Kind<Self, H>,
        _ fi: Kind<Self, I>,
        _ f: (Z) -> Either<A, Either<B, Either<C, Either<D, Either<E, Either<FF, Either<G, Either<H, I>>>>>>>>
    ) -> Kind<Self, Z> {
        choose(
            fa,
            fb,
            fc,
            fd,
            fe,
            ff,
            fg,
            choose(fh, fi, id),
            f
        )
    }
    
    static func choose<A, B, C, D, E, FF, G, H, I, J, Z>(
        _ fa: Kind<Self, A>,
        _ fb: Kind<Self, B>,
        _ fc: Kind<Self, C>,
        _ fd: Kind<Self, D>,
        _ fe: Kind<Self, E>,
        _ ff: Kind<Self, FF>,
        _ fg: Kind<Self, G>,
        _ fh: Kind<Self, H>,
        _ fi: Kind<Self, I>,
        _ fj: Kind<Self, J>,
        _ f: (Z) -> Either<A, Either<B, Either<C, Either<D, Either<E, Either<FF, Either<G, Either<H, Either<I, J>>>>>>>>>
    ) -> Kind<Self, Z> {
        choose(
            fa,
            fb,
            fc,
            fd,
            fe,
            ff,
            fg,
            fh,
            choose(fi, fj, id),
            f
        )
    }
}

// MARK: - Syntax for Decidable
public extension Kind where F: Decidable {
    func choose<B, Z>(_ fb: Kind<F, B>, _ f: (Z) -> Either<A, B>) -> Kind<F, Z> {
        F.choose(self, fb, f)
    }
    
    func choose<B, C, Z>(_ fb: Kind<F, B>, _ fc: Kind<F, C>, _ f: (Z) -> Either<A, Either<B, C>>) -> Kind<F, Z> {
        F.choose(self, fb, fc, f)
    }
    
    func choose<B, C, D, Z>(_ fb: Kind<F, B>, _ fc: Kind<F, C>, _ fd: Kind<F, D>, _ f: (Z) -> Either<A, Either<B, Either<C, D>>>) -> Kind<F, Z> {
        F.choose(self, fb, fc, fd, f)
    }
    
    func choose<B, C, D, E, Z>(
        _ fb: Kind<F, B>,
        _ fc: Kind<F, C>,
        _ fd: Kind<F, D>,
        _ fe: Kind<F, E>,
        _ f: (Z) -> Either<A, Either<B, Either<C, Either<D, E>>>>
    ) -> Kind<F, Z> {
        F.choose(self, fb, fc, fd, fe, f)
    }
    
    func choose<B, C, D, E, FF, Z>(
        _ fb: Kind<F, B>,
        _ fc: Kind<F, C>,
        _ fd: Kind<F, D>,
        _ fe: Kind<F, E>,
        _ ff: Kind<F, FF>,
        _ f: (Z) -> Either<A, Either<B, Either<C, Either<D, Either<E, FF>>>>>
    ) -> Kind<F, Z> {
        F.choose(self, fb, fc, fd, fe, ff, f)
    }
    
    func choose<B, C, D, E, FF, G, Z>(
        _ fb: Kind<F, B>,
        _ fc: Kind<F, C>,
        _ fd: Kind<F, D>,
        _ fe: Kind<F, E>,
        _ ff: Kind<F, FF>,
        _ fg: Kind<F, G>,
        _ f: (Z) -> Either<A, Either<B, Either<C, Either<D, Either<E, Either<FF, G>>>>>>
    ) -> Kind<F, Z> {
        F.choose(self, fb, fc, fd, fe, ff, fg, f)
    }
    
    func choose<B, C, D, E, FF, G, H, Z>(
        _ fb: Kind<F, B>,
        _ fc: Kind<F, C>,
        _ fd: Kind<F, D>,
        _ fe: Kind<F, E>,
        _ ff: Kind<F, FF>,
        _ fg: Kind<F, G>,
        _ fh: Kind<F, H>,
        _ f: (Z) -> Either<A, Either<B, Either<C, Either<D, Either<E, Either<FF, Either<G, H>>>>>>>
    ) -> Kind<F, Z> {
        F.choose(self, fb, fc, fd, fe, ff, fg, fh, f)
    }
    
    func choose<B, C, D, E, FF, G, H, I, Z>(
        _ fb: Kind<F, B>,
        _ fc: Kind<F, C>,
        _ fd: Kind<F, D>,
        _ fe: Kind<F, E>,
        _ ff: Kind<F, FF>,
        _ fg: Kind<F, G>,
        _ fh: Kind<F, H>,
        _ fi: Kind<F, I>,
        _ f: (Z) -> Either<A, Either<B, Either<C, Either<D, Either<E, Either<FF, Either<G, Either<H, I>>>>>>>>
    ) -> Kind<F, Z> {
        F.choose(self, fb, fc, fd, fe, ff, fg, fh, fi, f)
    }
    
    func choose<B, C, D, E, FF, G, H, I, J, Z>(
        _ fb: Kind<F, B>,
        _ fc: Kind<F, C>,
        _ fd: Kind<F, D>,
        _ fe: Kind<F, E>,
        _ ff: Kind<F, FF>,
        _ fg: Kind<F, G>,
        _ fh: Kind<F, H>,
        _ fi: Kind<F, I>,
        _ fj: Kind<F, J>,
        _ f: (Z) -> Either<A, Either<B, Either<C, Either<D, Either<E, Either<FF, Either<G, Either<H, Either<I, J>>>>>>>>>
    ) -> Kind<F, Z> {
        F.choose(self, fb, fc, fd, fe, ff, fg, fh, fi, fj, f)
    }
}
