import Bow
import Foundation

public func continueOn<F: Async>(_ queue: DispatchQueue) -> BindingExpression<F> {
    return BoundVar<F, ()>.make() <- queue.shift()
}

public func parallel<F: Concurrent, A, B>(_ fa: Kind<F, A>,
                                          _ fb: Kind<F, B>) -> Kind<F, (A, B)> {
    return F.parZip(fa, fb)
}

public func parallel<F: Concurrent, A, B, C>(_ fa: Kind<F, A>,
                                             _ fb: Kind<F, B>,
                                             _ fc: Kind<F, C>) -> Kind<F, (A, B, C)> {
    return F.parZip(fa, fb, fc)
}

public func parallel<F: Concurrent, A, B, C, D>(_ fa: Kind<F, A>,
                                                _ fb: Kind<F, B>,
                                                _ fc: Kind<F, C>,
                                                _ fd: Kind<F, D>) -> Kind<F, (A, B, C, D)> {
    return F.parZip(fa, fb, fc, fd)
}

public func parallel<F: Concurrent, A, B, C, D, E>(_ fa: Kind<F, A>,
                                                   _ fb: Kind<F, B>,
                                                   _ fc: Kind<F, C>,
                                                   _ fd: Kind<F, D>,
                                                   _ fe: Kind<F, E>) -> Kind<F, (A, B, C, D, E)> {
    return F.parZip(fa, fb, fc, fd, fe)
}

public func parallel<F: Concurrent, A, B, C, D, E, G>(_ fa: Kind<F, A>,
                                                      _ fb: Kind<F, B>,
                                                      _ fc: Kind<F, C>,
                                                      _ fd: Kind<F, D>,
                                                      _ fe: Kind<F, E>,
                                                      _ fg: Kind<F, G>) -> Kind<F, (A, B, C, D, E, G)> {
    return F.parZip(fa, fb, fc, fd, fe, fg)
}

public func parallel<F: Concurrent, A, B, C, D, E, G, H>(_ fa: Kind<F, A>,
                                                         _ fb: Kind<F, B>,
                                                         _ fc: Kind<F, C>,
                                                         _ fd: Kind<F, D>,
                                                         _ fe: Kind<F, E>,
                                                         _ fg: Kind<F, G>,
                                                         _ fh: Kind<F, H>) -> Kind<F, (A, B, C, D, E, G, H)> {
    return F.parZip(fa, fb, fc, fd, fe, fg, fh)
}

public func parallel<F: Concurrent, A, B, C, D, E, G, H, I>(_ fa: Kind<F, A>,
                                                            _ fb: Kind<F, B>,
                                                            _ fc: Kind<F, C>,
                                                            _ fd: Kind<F, D>,
                                                            _ fe: Kind<F, E>,
                                                            _ fg: Kind<F, G>,
                                                            _ fh: Kind<F, H>,
                                                            _ fi: Kind<F, I>) -> Kind<F, (A, B, C, D, E, G, H, I)> {
    return F.parZip(fa, fb, fc, fd, fe, fg, fh, fi)
}

public func parallel<F: Concurrent, A, B, C, D, E, G, H, I, J>(_ fa: Kind<F, A>,
                                                               _ fb: Kind<F, B>,
                                                               _ fc: Kind<F, C>,
                                                               _ fd: Kind<F, D>,
                                                               _ fe: Kind<F, E>,
                                                               _ fg: Kind<F, G>,
                                                               _ fh: Kind<F, H>,
                                                               _ fi: Kind<F, I>,
                                                               _ fj: Kind<F, J>) -> Kind<F, (A, B, C, D, E, G, H, I, J)> {
    return F.parZip(fa, fb, fc, fd, fe, fg, fh, fi, fj)
}

