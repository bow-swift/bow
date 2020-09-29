import XCTest
import Bow
import BowFree
import BowFreeGenerators
import BowLaws

fileprivate final class ForOpsF {}
fileprivate typealias OpsFPartial = ForOpsF
fileprivate typealias OpsFOf<A> = Kind<ForOpsF, A>

fileprivate class OpsF<A>: OpsFOf<A> {
    enum _OpsF {
        case read((String) -> A)
        case write(String, A)
    }
    
    let value: _OpsF
    
    private init(_ value: _OpsF) {
        self.value = value
    }
    
    static func read(_ callback: @escaping (String) -> A) -> OpsF<A> {
        OpsF(.read(callback))
    }
    
    static func write(_ content: String, _ next: A) -> OpsF<A> {
        OpsF(.write(content, next))
    }
}

fileprivate postfix func ^<A>(_ value: OpsFOf<A>) -> OpsF<A> {
    value as! OpsF<A>
}

fileprivate typealias Ops<A> = Program<OpsFPartial, A>

fileprivate func read() -> Ops<String> {
    Ops.liftF(OpsF.read(id))
}

fileprivate func write(content: String) -> Ops<Void> {
    Ops.liftF(OpsF.write(content, ()))
}

fileprivate func program() -> Ops<Void> {
    let name = Ops<String>.var()
    
    return binding(
        |<-write(content: "What's your name?"),
        name <- read(),
        |<-write(content: "Hello \(name.get)!"),
        yield: ()
    )^
}

fileprivate class StateInterpreter: FunctionK<OpsFPartial, StatePartial<([String], [String])>> {
    
    override func invoke<A>(
        _ fa: OpsFOf<A>
    ) -> StateOf<([String], [String]), A> {
        switch fa^.value {
        
        case .read(let callback):
            return State { state -> (([String], [String]), A) in
                let input = state.0[0]
                let remaining = Array(state.0.dropFirst())
                return ((remaining, state.1), callback(input))
            }
            
        case .write(let content, let next):
            return State { state -> (([String], [String]), A) in
                let outputs = state.1 + [content]
                return ((state.0, outputs), next)
            }
        }
    }
}

extension ProgramPartial: EquatableK where F: Monad & EquatableK {
    public static func eq<A>(
        _ lhs: ProgramOf<F, A>,
        _ rhs: ProgramOf<F, A>
    ) -> Bool where A: Equatable {
        lhs^.run() == rhs^.run()
    }
}

class ProgramTest: XCTestCase {
    func testInterpretsProgram() {
        let state = program().foldMapK(StateInterpreter())^
        let final = state.runS((["Bow"], []))
        let outputs = ["What's your name?", "Hello Bow!"]
        XCTAssertEqual(final.0, [String]())
        XCTAssertEqual(final.1, outputs)
    }
    
    func testFunctorLaws() {
        FunctorLaws<ProgramPartial<ForId>>.check()
    }
    
    func testApplicativeLaws() {
        ApplicativeLaws<ProgramPartial<ForId>>.check()
    }

    func testSelectiveLaws() {
        SelectiveLaws<ProgramPartial<ForId>>.check()
    }
    
    func testMonadLaws() {
        MonadLaws<ProgramPartial<ForId>>.check()
    }
}
