/// Decidable is a typeclass modeling contravariant decision. Decidable is the contravariant version of Alternative.
///
/// Decidable basically states: Given a Kind<F, A> and a Kind<F, B> and a way to turn Z into either A or B it gives you a Kind<F, Z>.
public protocol Decidable: Divisible {
    ///
    /// choose takes two data-types of type `Kind<F, A>` and `Kind<F, B>` and produces a type of `Kind<F, Z>` when given
    /// a function from `Z -> Either<A, B>`.
    static func choose<A, B, Z>(_ fa: Kind<Self, A>, _ fb: Kind<Self, B>, _ f: (Z) -> Either<A, B>) -> Kind<Self, Z>
}

// MARK: Related functions
public extension Decidable {
    ///
    /// choose takes three data-types of type `Kind<F, A>`, `Kind<F, B>` and  `Kind<F, C>` and produces a type of `Kind<F, Z>` when given
    /// a function from `Z -> Either<A, Either<B, C>>`.
    static func choose<A, B, C, Z>(_ fa: Kind<Self, A>, _ fb: Kind<Self, B>, _ fc: Kind<Self, C>, _ f: (Z) -> Either<A, Either<B, C>>) -> Kind<Self, Z> {
        choose(fa, choose(fb, fc, id), f)
    }
    
    ///
    /// choose takes four data-types of type `Kind<F, A>`, `Kind<F, B>`, `Kind<F, C>` and  `Kind<F, D>` and produces a type of `Kind<F, Z>` when given
    /// a function from `Z -> Either<A, Either<B, Either<C, D>>>`.
    static func choose<A, B, C, D, Z>(_ fa: Kind<Self, A>, _ fb: Kind<Self, B>, _ fc: Kind<Self, C>, _ fd: Kind<Self, D>, _ f: (Z) -> Either<A, Either<B, Either<C, D>>>) -> Kind<Self, Z> {
        choose(
            fa,
            fb,
            choose(fc, fd, id),
            f
        )
    }
    
    ///
    /// choose takes five data-types of type `Kind<F, A>`, `Kind<F, B>`, `Kind<F, C>`, `Kind<F, D>` and `Kind<F, E>` and produces a type of `Kind<F, Z>` when given
    /// a function from `Z -> Either<A, Either<B, Either<C, Either<D, E>>>>`.
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
    
    ///
    /// choose takes six data-types of type `Kind<F, A>`, `Kind<F, B>`, `Kind<F, C>`, `Kind<F, D>`, `Kind<F, E` and `Kind<F, FF>` and produces a type of `Kind<F, Z>` when given
    /// a function from `Z -> Either<A, Either<B, Either<C, Either<D, Either<E, FF>>>>>`.
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
    
    ///
    /// choose takes seven data-types of type `Kind<F, A>`, `Kind<F, B>`, `Kind<F, C>`, `Kind<F, D>`, `Kind<F, E`, `Kind<F, FF>` and `Kind<F, G>` and produces a type of `Kind<F, Z>` when given
    /// a function from `Z -> Either<A, Either<B, Either<C, Either<D, Either<E, Either<FF, G>>>>>>`.
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
    
    ///
    /// choose takes eight data-types of type `Kind<F, A>`, `Kind<F, B>`, `Kind<F, C>`, `Kind<F, D>`, `Kind<F, E`, `Kind<F, FF>`, `Kind<F, G>` and `Kind<F, H>` and produces a type of `Kind<F, Z>` when given
    /// a function from `Z -> Either<A, Either<B, Either<C, Either<D, Either<E, Either<FF, Either<G, H>>>>>>>`.
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
    
    ///
    /// choose takes nine data-types of type `Kind<F, A>`, `Kind<F, B>`, `Kind<F, C>`, `Kind<F, D>`, `Kind<F, E`, `Kind<F, FF>`, `Kind<F, G>`, `Kind<F, H>` and `Kind<F, I>` and produces a type of `Kind<F, Z>` when given
    /// a function from `Z -> Either<A, Either<B, Either<C, Either<D, Either<E, Either<FF, Either<G, Either<H, I>>>>>>>>`.
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
    
    ///
    /// choose takes ten data-types of type `Kind<F, A>`, `Kind<F, B>`, `Kind<F, C>`, `Kind<F, D>`, `Kind<F, E`, `Kind<F, FF>`, `Kind<F, G>`, `Kind<F, H>`, `Kind<F, I>` and `Kind<F, J>` and produces a type of `Kind<F, Z>` when given
    /// a function from `Z -> Either<A, Either<B, Either<C, Either<D, Either<E, Either<FF, Either<G, Either<H, Either<I, J>>>>>>>>>`.
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
    ///
    /// choose takes two data-types of type `Kind<F, Z>` and  `Kind<F, B>` and produces a type of `Kind<F, A>` when given
    /// a function from `A -> Either<Z, B>`.
    static func choose<B, Z>(_ fa: Kind<F, Z>, _ fb: Kind<F, B>, _ f: (A) -> Either<Z, B>) -> Kind<F, A> {
        F.choose(fa, fb, f)
    }
    
    ///
    /// choose takes three data-types of type `Kind<F, Z>`, `Kind<F, B>` and  `Kind<F, C>` and produces a type of `Kind<F, A>` when given
    /// a function from `A -> Either<Z, Either<B, C>>`.
    static func choose<B, C, Z>(_ fa: Kind<F, Z>, _ fb: Kind<F, B>, _ fc: Kind<F, C>, _ f: (A) -> Either<Z, Either<B, C>>) -> Kind<F, A> {
        F.choose(fa, fb, fc, f)
    }
    
    ///
    /// choose takes four data-types of type `Kind<F, Z>`, `Kind<F, B>`, `Kind<F, C>` and  `Kind<F, D>` and produces a type of `Kind<F, A>` when given
    /// a function from `A -> Either<Z, Either<B, Either<C, D>>>`.
    static func choose<B, C, D, Z>(_ fa: Kind<F, Z>, _ fb: Kind<F, B>, _ fc: Kind<F, C>, _ fd: Kind<F, D>, _ f: (A) -> Either<Z, Either<B, Either<C, D>>>) -> Kind<F, A> {
        F.choose(fa, fb, fc, fd, f)
    }
    
    ///
    /// choose takes five data-types of type `Kind<F, Z>`, `Kind<F, B>`, `Kind<F, C>`, `Kind<F, D>` and  `Kind<F, E>` and produces a type of `Kind<F, A>` when given
    /// a function from `A -> Either<Z, Either<B, Either<C, Either<D, E>>>>`.
    static func choose<B, C, D, E, Z>(
        _ fa: Kind<F, Z>,
        _ fb: Kind<F, B>,
        _ fc: Kind<F, C>,
        _ fd: Kind<F, D>,
        _ fe: Kind<F, E>,
        _ f: (A) -> Either<Z, Either<B, Either<C, Either<D, E>>>>
    ) -> Kind<F, A> {
        F.choose(fa, fb, fc, fd, fe, f)
    }
    
    ///
    /// choose takes six data-types of type `Kind<F, Z>`, `Kind<F, B>`, `Kind<F, C>`, `Kind<F, D>`, `Kind<F, E>` and  `Kind<F, FF>` and produces a type of `Kind<F, A>` when given
    /// a function from `A -> Either<Z, Either<B, Either<C, Either<D, Either<E, FF>>>>>`.
    static func choose<B, C, D, E, FF, Z>(
        _ fa: Kind<F, Z>,
        _ fb: Kind<F, B>,
        _ fc: Kind<F, C>,
        _ fd: Kind<F, D>,
        _ fe: Kind<F, E>,
        _ ff: Kind<F, FF>,
        _ f: (A) -> Either<Z, Either<B, Either<C, Either<D, Either<E, FF>>>>>
    ) -> Kind<F, A> {
        F.choose(fa, fb, fc, fd, fe, ff, f)
    }
    
    ///
    /// choose takes seven data-types of type `Kind<F, Z>`, `Kind<F, B>`, `Kind<F, C>`, `Kind<F, D>`, `Kind<F, E>`, `Kind<F, FF>` and  `Kind<F, G>` and produces a type of `Kind<F, A>` when given
    /// a function from `A -> Either<Z, Either<B, Either<C, Either<D, Either<E, Either<FF, G>>>>>>`.
    static func choose<B, C, D, E, FF, G, Z>(
        _ fa: Kind<F, Z>,
        _ fb: Kind<F, B>,
        _ fc: Kind<F, C>,
        _ fd: Kind<F, D>,
        _ fe: Kind<F, E>,
        _ ff: Kind<F, FF>,
        _ fg: Kind<F, G>,
        _ f: (A) -> Either<Z, Either<B, Either<C, Either<D, Either<E, Either<FF, G>>>>>>
    ) -> Kind<F, A> {
        F.choose(fa, fb, fc, fd, fe, ff, fg, f)
    }
    
    ///
    /// choose takes eight data-types of type `Kind<F, Z>`, `Kind<F, B>`, `Kind<F, C>`, `Kind<F, D>`, `Kind<F, E>`, `Kind<F, FF>`, `Kind<F, G>` and  `Kind<F, H>` and produces a type of `Kind<F, A>` when given
    /// a function from `A -> Either<Z, Either<B, Either<C, Either<D, Either<E, Either<FF, Either<G, H>>>>>>>`.
    static func choose<B, C, D, E, FF, G, H, Z>(
        _ fa: Kind<F, Z>,
        _ fb: Kind<F, B>,
        _ fc: Kind<F, C>,
        _ fd: Kind<F, D>,
        _ fe: Kind<F, E>,
        _ ff: Kind<F, FF>,
        _ fg: Kind<F, G>,
        _ fh: Kind<F, H>,
        _ f: (A) -> Either<Z, Either<B, Either<C, Either<D, Either<E, Either<FF, Either<G, H>>>>>>>
    ) -> Kind<F, A> {
        F.choose(fa, fb, fc, fd, fe, ff, fg, fh, f)
    }
    
    ///
    /// choose takes nine data-types of type `Kind<F, Z>`, `Kind<F, B>`, `Kind<F, C>`, `Kind<F, D>`, `Kind<F, E>`, `Kind<F, FF>`, `Kind<F, G>`, `Kind<F, H>` and  `Kind<F, I>` and produces a type of `Kind<F, A>` when given
    /// a function from `A -> Either<Z, Either<B, Either<C, Either<D, Either<E, Either<FF, Either<G, Either<H, I>>>>>>>>`.
    static func choose<B, C, D, E, FF, G, H, I, Z>(
        _ fa: Kind<F, Z>,
        _ fb: Kind<F, B>,
        _ fc: Kind<F, C>,
        _ fd: Kind<F, D>,
        _ fe: Kind<F, E>,
        _ ff: Kind<F, FF>,
        _ fg: Kind<F, G>,
        _ fh: Kind<F, H>,
        _ fi: Kind<F, I>,
        _ f: (A) -> Either<Z, Either<B, Either<C, Either<D, Either<E, Either<FF, Either<G, Either<H, I>>>>>>>>
    ) -> Kind<F, A> {
        F.choose(fa, fb, fc, fd, fe, ff, fg, fh, fi, f)
    }
    
    ///
    /// choose takes ten data-types of type `Kind<F, Z>`, `Kind<F, B>`, `Kind<F, C>`, `Kind<F, D>`, `Kind<F, E>`, `Kind<F, FF>`, `Kind<F, G>`, `Kind<F, H>`, `Kind<F, I>` and  `Kind<F, J>` and produces a type of `Kind<F, A>` when given
    /// a function from `A -> Either<Z, Either<B, Either<C, Either<D, Either<E, Either<FF, Either<G, Either<H, Either<I, J>>>>>>>>>`.
    static func choose<B, C, D, E, FF, G, H, I, J, Z>(
        _ fa: Kind<F, Z>,
        _ fb: Kind<F, B>,
        _ fc: Kind<F, C>,
        _ fd: Kind<F, D>,
        _ fe: Kind<F, E>,
        _ ff: Kind<F, FF>,
        _ fg: Kind<F, G>,
        _ fh: Kind<F, H>,
        _ fi: Kind<F, I>,
        _ fj: Kind<F, J>,
        _ f: (A) -> Either<Z, Either<B, Either<C, Either<D, Either<E, Either<FF, Either<G, Either<H, Either<I, J>>>>>>>>>
    ) -> Kind<F, A> {
        F.choose(fa, fb, fc, fd, fe, ff, fg, fh, fi, fj, f)
    }
}
