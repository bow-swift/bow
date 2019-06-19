import Foundation
import Bow

public extension Lens where A: Each {
    var every: Traversal<S, A.EachFoci> {
        return self.fix + A.each
    }
}

public extension Iso where A: Each {
    var every: Traversal<S, A.EachFoci> {
        return self.fix + A.each
    }
}

public extension Prism where A: Each {
    var every: Traversal<S, A.EachFoci> {
        return self.fix + A.each
    }
}

public extension Optional where A: Each {
    var every: Traversal<S, A.EachFoci> {
        return self.fix + A.each
    }
}

public extension Setter where A: Each {
    var every: Setter<S, A.EachFoci> {
        return self.fix + A.each
    }
}

public extension Traversal where A: Each {
    var every: Traversal<S, A.EachFoci> {
        return self.fix + A.each
    }
}

public extension Fold where A: Each {
    var every: Fold<S, A.EachFoci> {
        return self + A.each
    }
}
