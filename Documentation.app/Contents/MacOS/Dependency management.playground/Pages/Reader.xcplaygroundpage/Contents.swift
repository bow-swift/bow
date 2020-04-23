// nef:begin:header
/*
 layout: docs
 title: Reader
 */
// nef:end
// nef:begin:hidden
import Bow
// nef:end
/*:
 # Reader
 
 The Reader pattern is a fancy name for returning functions as part of other functions. That is, `Reader<A, B>` corresponds to a function `(A) -> B`.
 
 Even these two constructions are equivalent, they have different semantics. `Reader` wraps a function, but thanks to being a nominal type, we can add methods that work with the underlying function in an easier way. This is something we cannot do with a plain function `(A) -> B`, as functions are not nominal types and therefore cannot be extended.
 
 Let's introduce an example to illustrate the usage of `Reader`. Consider the following code:
 */
// nef:begin:hidden
struct Line {
    let description: String
}

struct Invoice {
    let amount: Double
    let lines: [Line]
}

let invoice = Invoice(amount: 0, lines: [])

protocol Formatter {
    func format(amount: Double) -> String
    func format(lines: [Line]) -> String
}

struct MoneyFormatter: Formatter {
    func format(amount: Double) -> String {
        "\(amount) €"
    }
    
    func format(lines: [Line]) -> String {
        ""
    }
}

struct TestFormatter: Formatter {
    func format(amount: Double) -> String {
        "\(amount) €"
    }
    
    func format(lines: [Line]) -> String {
        ""
    }
}
class Snippet1 {
// nef:end
func showTotal(for invoice: Invoice) -> String {
    let formatter = MoneyFormatter()
    return formatter.format(amount: invoice.amount)
}
// nef:begin:hidden
}
// nef:end
/*:
 This function has a hidden dependency on `MoneyFormatter` that cannot be controlled from the outside. We can make it explicit by passing the dependency as a parameter:
 */
func showTotal(for invoice: Invoice, using formatter: Formatter) -> String {
    formatter.format(amount: invoice.amount)
}
/*:
 This lets us control the dependency by supplying it as an argument to the function. However, we could have more functions using the same dependency:
 */
func showLines(for invoice: Invoice, using formatter: Formatter) -> String {
    formatter.format(lines: invoice.lines)
}
/*:
 In these situations, we would like to guarantee that the same dependency is supplied to all the functions. This is where the `Reader` can be useful. The first step we can do is to curry our functions:
 */
func showTotalCurried(for invoice: Invoice) -> (Formatter) -> String {
    { formatter in
        formatter.format(amount: invoice.amount)
    }
}

func showLinesCurried(for invoice: Invoice) -> (Formatter) -> String {
    { formatter in
        formatter.format(lines: invoice.lines)
    }
}
/*:
 The output of these functions is, itself, a function `(Formatter) -> String`. We have mentioned above that this is equivalent to `Reader<Formatter, String>`; therefore, we can perform that change:
 */
func showTotal(for invoice: Invoice) -> Reader<Formatter, String> {
    Reader { formatter in
        Id(formatter.format(amount: invoice.amount))
    }
}

func showLines(for invoice: Invoice) -> Reader<Formatter, String> {
    Reader { formatter in
        Id(formatter.format(lines: invoice.lines))
    }
}
/*:
 These functions return computations where supplying the dependencies is postponed to a later moment. This way, we can compose operations with the same dependencies using combinators like `map`, `zip` or `flatMap`:
 */
func showReport(for invoice: Invoice) -> Reader<Formatter, String> {
    Reader.map(
        showLines(for: invoice),
        showTotal(for: invoice)) { lines, total in
            """
            \(lines)
            ------------------
            Total: \(total)
            """
    }^
}
/*:
 Finally, we can invoke the function and supply the dependency as:
 */
// In production:
showReport(for: invoice).run(MoneyFormatter())

// In testing:
showReport(for: invoice).run(TestFormatter())
/*:
 Note that, even though both `showTotal` and `showLines` need to receive an `Invoice`, we are not moving it to the `Reader` input type. We have to differentiate between data that a function receives to compute its output, and dependencies that a function needs to do its job. Generally, there would be a single instance of a dependency (in this case, the `Formatter`), whereas we can invoke this function with multiple different invoices.
 
 This approach lets us work with multiple functions and guarantee that all of them will receive the same dependencies. It provides a rich API to enable powerful composition in the same way we do with other types. The Reader pattern can be generalized to effectful functions using `Kleisli` or `ReaderT`, which model effectful functions `(A) -> F<B>`, where `F` is the effect type. The behavior is equivalent to what was shown above; in fact, `Reader` is a specific case of `Kleisli`, where the effect is the `Id` type.
 */
