import Foundation

public enum ConsoleIO {
    public static func print<E: Error>(_ line: Any, separator: String = " ", terminator: String = "\n") -> IO<E, ()> {
        return IO.invoke { Swift.print(line, separator: separator, terminator: terminator) }
    }
    
    public static func readLine<E: Error>(strippingNewline: Bool = true) -> IO<E, String?> {
        return IO.invoke { Swift.readLine(strippingNewline: strippingNewline) }
    }
}
