import Foundation

public extension String {
    public static func traversal() -> Traversal<String, Character> {
        return StringTraversal()
    }
    
    public static func each() -> StringEach {
        return StringEach()
    }
}

fileprivate class StringTraversal : Traversal<String, Character> {
    override func modifyF<Appl, F>(_ applicative: Appl, _ s: String, _ f: @escaping (Character) -> Kind<F, Character>) -> Kind<F, String> where Appl : Applicative, F == Appl.F {
        return applicative.map(s.map(id).k().traverse(f, applicative), { x in
            String(x.fix().asArray)
        })
    }
}

public class StringEach : Each {
    public typealias S = String
    public typealias A = Character
    
    public func each() -> Traversal<String, Character> {
        return String.traversal()
    }
}
