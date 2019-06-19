import Foundation
import Bow

public extension Lens where A: At {
    func at(_ i: A.AtIndex) -> Lens<S, A.AtFoci>  {
        return self.fix + A.at(i)
    }
}

public extension Iso where A: At {
    func at(_ i: A.AtIndex) -> Lens<S, A.AtFoci> {
        return self.fix + A.at(i)
    }
}

public extension Prism where A: At {
    func at(_ i: A.AtIndex) -> Optional<S, A.AtFoci> {
        return self.fix + A.at(i)
    }
}

public extension Optional where A: At {
    func at(_ i: A.AtIndex) -> Optional<S, A.AtFoci> {
        return self.fix + A.at(i)
    }
}

public extension Getter where A: At {
    func at(_ i: A.AtIndex) -> Getter<S, A.AtFoci> {
        return self + A.at(i)
    }
}

public extension Setter where A: At {
    func at(_ i: A.AtIndex) -> Setter<S, A.AtFoci> {
        return self.fix + A.at(i)
    }
}

public extension Traversal where A: At {
    func at(_ i: A.AtIndex) -> Traversal<S, A.AtFoci> {
        return self.fix + A.at(i)
    }
}

public extension Fold where A: At {
    func at(_ i: A.AtIndex) -> Fold<S, A.AtFoci> {
        return self + A.at(i)
    }
}
