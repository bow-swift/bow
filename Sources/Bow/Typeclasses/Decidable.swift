/// Decidable is a typeclass modeling contravariant decision. Decidable is the contravariant version of Alternative.
public protocol Decidable: Divisible {
    /// Takes 2 computations and produces a new one that decides which one will be run, based on a provided function.
    ///
    /// - Parameters:
    ///   - fa: 1st computation
    ///   - fb: 2nd computation
    ///   - f: Deciding function
    /// - Returns: A computation that decides which of the provided arguments should run.
    static func choose<A, B, Z>(
        _ fa: Kind<Self, A>,
        _ fb: Kind<Self, B>,
        _ f: (Z) -> Either<A, B>) -> Kind<Self, Z>
}

// MARK: Related functions
public extension Decidable {
    /// Takes 3 computations and produces a new one that decides which one will be run, based on a provided function.
    ///
    /// - Parameters:
    ///   - fa: 1st computation
    ///   - fb: 2nd computation
    ///   - fc: 3rd computation
    ///   - f: Deciding function
    /// - Returns: A computation that decides which of the provided arguments should run.
    static func choose<A, B, C, Z>(
        _ fa: Kind<Self, A>,
        _ fb: Kind<Self, B>,
        _ fc: Kind<Self, C>,
        _ f: (Z) -> Either<A, Either<B, C>>) -> Kind<Self, Z> {
        choose(fa, choose(fb, fc, id), f)
    }
    
    /// Takes 4 computations and produces a new one that decides which one will be run, based on a provided function.
    ///
    /// - Parameters:
    ///   - fa: 1st computation
    ///   - fb: 2nd computation
    ///   - fc: 3rd computation
    ///   - fd: 4th computation
    ///   - f: Deciding function
    /// - Returns: A computation that decides which of the provided arguments should run.
    static func choose<A, B, C, D, Z>(
        _ fa: Kind<Self, A>,
        _ fb: Kind<Self, B>,
        _ fc: Kind<Self, C>,
        _ fd: Kind<Self, D>,
        _ f: (Z) -> Either<A, Either<B, Either<C, D>>>) -> Kind<Self, Z> {
        choose(
            fa,
            fb,
            choose(fc, fd, id),
            f
        )
    }
    
    /// Takes 5 computations and produces a new one that decides which one will be run, based on a provided function.
    ///
    /// - Parameters:
    ///   - fa: 1st computation
    ///   - fb: 2nd computation
    ///   - fc: 3rd computation
    ///   - fd: 4th computation
    ///   - fe: 5th computation
    ///   - f: Deciding function
    /// - Returns: A computation that decides which of the provided arguments should run.
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
    
    /// Takes 6 computations and produces a new one that decides which one will be run, based on a provided function.
    ///
    /// - Parameters:
    ///   - fa: 1st computation
    ///   - fb: 2nd computation
    ///   - fc: 3rd computation
    ///   - fd: 4th computation
    ///   - fe: 5th computation
    ///   - ff: 6th computation
    ///   - f: Deciding function
    /// - Returns: A computation that decides which of the provided arguments should run.
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
    
    /// Takes 7 computations and produces a new one that decides which one will be run, based on a provided function.
    ///
    /// - Parameters:
    ///   - fa: 1st computation
    ///   - fb: 2nd computation
    ///   - fc: 3rd computation
    ///   - fd: 4th computation
    ///   - fe: 5th computation
    ///   - ff: 6th computation
    ///   - fg: 7th computation
    ///   - f: Deciding function
    /// - Returns: A computation that decides which of the provided arguments should run.
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
    
    /// Takes 8 computations and produces a new one that decides which one will be run, based on a provided function.
    ///
    /// - Parameters:
    ///   - fa: 1st computation
    ///   - fb: 2nd computation
    ///   - fc: 3rd computation
    ///   - fd: 4th computation
    ///   - fe: 5th computation
    ///   - ff: 6th computation
    ///   - fg: 7th computation
    ///   - fh: 8th computation
    ///   - f: Deciding function
    /// - Returns: A computation that decides which of the provided arguments should run.
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
    
    /// Takes 9 computations and produces a new one that decides which one will be run, based on a provided function.
    ///
    /// - Parameters:
    ///   - fa: 1st computation
    ///   - fb: 2nd computation
    ///   - fc: 3rd computation
    ///   - fd: 4th computation
    ///   - fe: 5th computation
    ///   - ff: 6th computation
    ///   - fg: 7th computation
    ///   - fh: 8th computation
    ///   - fi: 9th computation
    ///   - f: Deciding function
    /// - Returns: A computation that decides which of the provided arguments should run.
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
    
    /// Takes 10 computations and produces a new one that decides which one will be run, based on a provided function.
    ///
    /// - Parameters:
    ///   - fa: 1st computation
    ///   - fb: 2nd computation
    ///   - fc: 3rd computation
    ///   - fd: 4th computation
    ///   - fe: 5th computation
    ///   - ff: 6th computation
    ///   - fg: 7th computation
    ///   - fh: 8th computation
    ///   - fi: 9th computation
    ///   - fj: 10th computation
    ///   - f: Deciding function
    /// - Returns: A computation that decides which of the provided arguments should run.
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
    /// Takes 2 computations and produces a new one that decides which one will be run, based on a provided function.
    ///
    /// - Parameters:
    ///   - fa: 1st computation
    ///   - fb: 2nd computation
    ///   - f: Deciding function
    /// - Returns: A computation that decides which of the provided arguments should run.
    static func choose<B, Z>(
        _ fa: Kind<F, Z>,
        _ fb: Kind<F, B>,
        _ f: (A) -> Either<Z, B>) -> Kind<F, A> {
        F.choose(fa, fb, f)
    }
    
    /// Takes 3 computations and produces a new one that decides which one will be run, based on a provided function.
    ///
    /// - Parameters:
    ///   - fa: 1st computation
    ///   - fb: 2nd computation
    ///   - fc: 3rd computation
    ///   - f: Deciding function
    /// - Returns: A computation that decides which of the provided arguments should run.
    static func choose<B, C, Z>(
        _ fa: Kind<F, Z>,
        _ fb: Kind<F, B>,
        _ fc: Kind<F, C>,
        _ f: (A) -> Either<Z, Either<B, C>>) -> Kind<F, A> {
        F.choose(fa, fb, fc, f)
    }
    
    /// Takes 4 computations and produces a new one that decides which one will be run, based on a provided function.
    ///
    /// - Parameters:
    ///   - fa: 1st computation
    ///   - fb: 2nd computation
    ///   - fc: 3rd computation
    ///   - fd: 4th computation
    ///   - f: Deciding function
    /// - Returns: A computation that decides which of the provided arguments should run.
    static func choose<B, C, D, Z>(
        _ fa: Kind<F, Z>,
        _ fb: Kind<F, B>,
        _ fc: Kind<F, C>,
        _ fd: Kind<F, D>,
        _ f: (A) -> Either<Z, Either<B, Either<C, D>>>) -> Kind<F, A> {
        F.choose(fa, fb, fc, fd, f)
    }
    
    /// Takes 5 computations and produces a new one that decides which one will be run, based on a provided function.
    ///
    /// - Parameters:
    ///   - fa: 1st computation
    ///   - fb: 2nd computation
    ///   - fc: 3rd computation
    ///   - fd: 4th computation
    ///   - fe: 5th computation
    ///   - f: Deciding function
    /// - Returns: A computation that decides which of the provided arguments should run.
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
    
    /// Takes 6 computations and produces a new one that decides which one will be run, based on a provided function.
    ///
    /// - Parameters:
    ///   - fa: 1st computation
    ///   - fb: 2nd computation
    ///   - fc: 3rd computation
    ///   - fd: 4th computation
    ///   - fe: 5th computation
    ///   - ff: 6th computation
    ///   - f: Deciding function
    /// - Returns: A computation that decides which of the provided arguments should run.
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
    
    /// Takes 7 computations and produces a new one that decides which one will be run, based on a provided function.
    ///
    /// - Parameters:
    ///   - fa: 1st computation
    ///   - fb: 2nd computation
    ///   - fc: 3rd computation
    ///   - fd: 4th computation
    ///   - fe: 5th computation
    ///   - ff: 6th computation
    ///   - fg: 7th computation
    ///   - f: Deciding function
    /// - Returns: A computation that decides which of the provided arguments should run.
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
    
    /// Takes 8 computations and produces a new one that decides which one will be run, based on a provided function.
    ///
    /// - Parameters:
    ///   - fa: 1st computation
    ///   - fb: 2nd computation
    ///   - fc: 3rd computation
    ///   - fd: 4th computation
    ///   - fe: 5th computation
    ///   - ff: 6th computation
    ///   - fg: 7th computation
    ///   - fh: 8th computation
    ///   - f: Deciding function
    /// - Returns: A computation that decides which of the provided arguments should run.
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
    
    /// Takes 9 computations and produces a new one that decides which one will be run, based on a provided function.
    ///
    /// - Parameters:
    ///   - fa: 1st computation
    ///   - fb: 2nd computation
    ///   - fc: 3rd computation
    ///   - fd: 4th computation
    ///   - fe: 5th computation
    ///   - ff: 6th computation
    ///   - fg: 7th computation
    ///   - fh: 8th computation
    ///   - fi: 9th computation
    ///   - f: Deciding function
    /// - Returns: A computation that decides which of the provided arguments should run.
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
    
    /// Takes 10 computations and produces a new one that decides which one will be run, based on a provided function.
    ///
    /// - Parameters:
    ///   - fa: 1st computation
    ///   - fb: 2nd computation
    ///   - fc: 3rd computation
    ///   - fd: 4th computation
    ///   - fe: 5th computation
    ///   - ff: 6th computation
    ///   - fg: 7th computation
    ///   - fh: 8th computation
    ///   - fi: 9th computation
    ///   - fj: 10th computation
    ///   - f: Deciding function
    /// - Returns: A computation that decides which of the provided arguments should run.
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
