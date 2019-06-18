import Foundation
import Bow

// MARK: Optics extensions
public extension String {
    static var traversal: Traversal<String, Character> {
        return StringTraversal()
    }
}

// MARK: Instance of `Each` for String
extension String: Each {
    public typealias EachFoci = Character
    
    public static var each: Traversal<String, Character> {
        return traversal
    }
}

private class StringTraversal: Traversal<String, Character> {
    override func modifyF<F: Applicative>(_ s: String, _ f: @escaping (Character) -> Kind<F, Character>) -> Kind<F, String> {
        return F.map(s.map(id).k().traverse(f), { x in
            String(ArrayK.fix(x).asArray)
        })
    }
}
