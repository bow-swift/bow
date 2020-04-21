// nef:begin:header
/*
 layout: docs
 title: Constructor-based dependency injection
 */
// nef:end
/*:
 # Constructor-based dependency injection
 
 Constructor-based dependency injection is a familiar technique for most Object-Oriented developers that can as well be used in Functional Programming. It consists on providing dependencies of a module on its initializer, in such a way it has all dependencies it needs, and its methods only receive the parameters they need to do their job.
 
 Consider the following code:
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

class Snippet1 {
// nef:end
class InvoicePresenter {
    func showTotal(for invoice: Invoice) -> String {
        let formatter = MoneyFormatter()
        return formatter.format(amount: invoice.amount)
    }
}
// nef:begin:hidden
}
// nef:end
/*:
 This code has a dependency on `MoneyFormatter`, but is uncontrollable from the outside; that is, if we need to control it for testing, we will not be able to. We can make this dependency explicit and provide it through the initializer of the class:
 */
// nef:begin:hidden
class Snippet2 {
// nef:end
class InvoicePresenter {
    let formatter: Formatter
    
    init(formatter: Formatter) {
        self.formatter = formatter
    }
    
    func showTotal(for invoice: Invoice) -> String {
        formatter.format(amount: invoice.amount)
    }
}
// nef:begin:hidden
}
// nef:end
/*:
 This lets us control the dependency by making it explicit. We can even provide a default value for the dependency in the initializer, which would be the one we would typically use in production:
 */
// nef:begin:hidden
class Snippet3 {
// nef:end
class InvoicePresenter {
    let formatter: Formatter
    
    init(formatter: Formatter = MoneyFormatter()) {
        self.formatter = formatter
    }
    
    func showTotal(for invoice: Invoice) -> String {
        formatter.format(amount: invoice.amount)
    }
}
// nef:begin:hidden
}
// nef:end
/*:
 Constructor-based dependency injection is a useful technique that lets us supply the same dependencies to all the methods inside a given class. It also helps us hide some dependencies in a layer and not expose the to the outside.
 
 However, this technique also has some drawbacks. When we invoke one of the methods, dependencies are implicit in the fields of the class. That could reduce our ability to reason properly about the behavior of the code.
 
 An important caveat is that dependencies need to be stateless in order to guarantee referential transparency. If dependencies change their internal state after an invocation, their behavior would be different and we lose all the benefits we obtain from Functional Programming.
 */
