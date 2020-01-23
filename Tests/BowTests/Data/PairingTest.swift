import XCTest
import Bow

class PairingTest: XCTestCase {
    func testPairingStateStore() {
        let w = Store<Int, Int>(0, id)
        let s = State<Int, Int>.var()
        
        let actions: State<Int, Void> = binding(
            |<-.set(5),
            |<-.modify { x in x + 5 },
            s <- .get(),
            |<-.set(s.get * 3 + 1),
            yield: ())^
        
        let w2 = Pairing.pairStateStore().select(actions, w.duplicate())
        
        XCTAssertEqual(w2.extract(), 31)
    }
}
