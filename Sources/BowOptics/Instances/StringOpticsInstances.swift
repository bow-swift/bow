import Foundation
import Bow

public extension String {
    public static func traversal() -> Traversal<String, Character> {
        return StringTraversal()
    }
    
    public static func each() -> EachInstance {
        return EachInstance()
    }
    
    fileprivate class StringTraversal: Traversal<String, Character> {
        override func modifyF<F: Applicative>(_ s: String, _ f: @escaping (Character) -> Kind<F, Character>) -> Kind<F, String> {
            return F.map(s.map(id).k().traverse(f), { x in
                String(ArrayK.fix(x).asArray)
            })
        }
    }
    
    public class EachInstance : Each {
        public typealias S = String
        public typealias A = Character
        
        public func each() -> Traversal<String, Character> {
            return String.traversal()
        }
    }
}
