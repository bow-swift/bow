import Foundation

public class Coreader<A, B> : CoreaderT<ForId, A, B> {
    public init(_ run : @escaping (A) -> B) {
        super.init({ idA in run((idA as! Id<A>).extract()) })
    }
    
    public func runId(_ a : A) -> B {
        return self.run(Id<A>.pure(a))
    }
}
