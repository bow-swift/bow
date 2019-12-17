import Foundation

/// Utilities to read and write to the standard input/output in a functional manner.
public enum ConsoleIO {
    /// IO suspended version of `Swift.print(_:separator:terminator:)`. Refer to that function for further documentation.
    public static func print<E: Error>(_ line: @escaping @autoclosure () -> Any, separator: @escaping @autoclosure () -> CustomStringConvertible = " ", terminator: @escaping @autoclosure () -> CustomStringConvertible = "\n") -> IO<E, ()> {
        return IO.invoke { Swift.print(line(), separator: "\(separator())", terminator: "\(terminator())") }
    }
    
    /// IO suspended version of `Swift.readLine(strippingNewline:)`. Refer to that function for further documentation.
    public static func readLine<E: Error>(strippingNewline: Bool = true) -> IO<E, String?> {
        return IO.invoke { Swift.readLine(strippingNewline: strippingNewline) }
    }
}
