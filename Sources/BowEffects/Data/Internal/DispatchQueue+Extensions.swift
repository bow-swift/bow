import Foundation

extension DispatchQueue {
    public static var currentLabel: String {
        return String(validatingUTF8: __dispatch_queue_get_label(nil)) ?? ""
    }
}
