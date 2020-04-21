// nef:begin:header
/*
 layout: docs
 title: Partial application
 */
// nef:end
// nef:begin:hidden
import Bow
// nef:end
/*:
 # Partial application
 
 Partial application is perhaps the most simple technique to handle dependencies. It is based on making the dependencies explicit as parameters to the function that uses them. Later, different versions of the function can be obtained by fixing the parameters corresponding to the dependencies to specific values.
 
 For instance, consider the following function:
 */
// nef:begin:hidden
struct Invoice {
    let amount: Double
}

let invoice = Invoice(amount: 100)

protocol Formatter {
    func format(amount: Double) -> String
}

struct MoneyFormatter: Formatter {
    func format(amount: Double) -> String {
        "\(amount) €"
    }
}

struct TestFormatter: Formatter {
    func format(amount: Double) -> String {
        "\(amount) €"
    }
}
// nef:end
func showTotal(for invoice: Invoice) -> String {
    let formatter = MoneyFormatter()
    return formatter.format(amount: invoice.amount)
}
/*:
 This function has a dependency on `MoneyFormatter`, which is not visible from the outside. If we needed to control it, it wouldn't be possible. The first step we need to take is to make it available as a parameter:
 */
func showTotal(formatter: Formatter, for invoice: Invoice) -> String {
    formatter.format(amount: invoice.amount)
}
/*:
 If you pay attention, we are placing our dependency in the first place of the parameter list. This is to have a convenience for doing partial application.
 
 Now, we can use the operator `|>` provided in Bow in order to fix the first parameter of a function to a specific value. This operator returns a function with one fewer argument than the original one passed as a parameter, that has the same behavior and uses the supplied dependency. We can use it to create production and test versions of the previous function:
 */
let prodShowTotal: (Invoice) -> String =
    MoneyFormatter() |> showTotal(formatter:for:)

let testShowTotal: (Invoice) -> String =
    TestFormatter() |> showTotal(formatter:for:)

/*:
 We can invoke them as:
 */
prodShowTotal(invoice)
testShowTotal(invoice)
/*:
 This technique is very easy to apply, as it only relies on making dependencies explicit as parameters, and then creating specific versions for the different implementations of the dependencies we would like to apply.
 
 However, there are some drawbacks associated to this technique. First, having to place dependencies at the beginning of the function signature often leads to weird function names, especially considering the named arguments used commonly in Swift. This can be avoided though, if we do partial application manually:
 */
func showTotal(for invoice: Invoice, using formatter: Formatter) -> String {
    formatter.format(amount: invoice.amount)
}

func prodShowTotal(for invoice: Invoice) -> String {
    showTotal(for: invoice, using: MoneyFormatter())
}
/*:
 Notice that this is equivalent to using default values to parameters in a function:
 */
func showTotalDefaults(
    for invoice: Invoice,
    using formatter: Formatter = MoneyFormatter()
) -> String {
    formatter.format(amount: invoice.amount)
}
/*:
 This provides a default way of invoking the function using production dependencies, and at the same time having the ability to replace the dependency when needed.
 
 Another problem that we may have with this dependency is dealing with transitive dependencies. If we have multiple functions using a dependency and calling each other, we would probably like to make sure that all of them use the same version of the dependency, but this becomes harder and harder to guarantee as the number of functions increases.
 
 Finally, this technique may lead to a big proliferation of functions with some of their arguments partially applied, making it difficult to know which of them is the one we need to use.
 
 In summary, partial application is a simple technique for dependency management, but must be used knowing the associated costs.
 */
