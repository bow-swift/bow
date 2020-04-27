import Foundation

@available(tvOS, unavailable)
@available(watchOS, unavailable)
public extension FileManager {
    
    // MARK: - Creating and Deleting Items
    
    /// IO suspended version of `FileManager.trashItem(at:resultingItemURL:)`. Refer to that method for further documentation.
    @available(iOS 11.0, *)
    func trashItemIO(
        at url: URL,
        resultingItemURL outResultingURL: AutoreleasingUnsafeMutablePointer<NSURL?>?) -> IO<Error, ()> {
        IO.invoke {
            try self.trashItem(at: url, resultingItemURL: outResultingURL)
        }
    }
    
    // MARK: - Managing iCloud-Based Items
    
    /// IO suspended version of `FileManager.setUbiquitous(_:itemAt:destinationURL:)`. Refer to that method for further documentation.
    func setUbiquitousIO(
        _ flag: Bool,
        itemAt url: URL,
        destinationURL: URL) -> IO<Error, ()> {
        IO.invoke {
            try self.setUbiquitous(flag, itemAt: url, destinationURL: destinationURL)
        }
    }
    
    /// IO suspended version of `FileManager.startDownloadingUbiquitousItem(at:)`. Refer to that method for further documentation.
    func startDownloadingUbiquitousItemIO(at url: URL) -> IO<Error, ()> {
        IO.invoke {
            try self.startDownloadingUbiquitousItem(at: url)
        }
    }
    
    /// IO suspended version of `FileManager.evictUbiquitousItem(at:)`. Refer to that method for further documentation.
    func evictUbiquitousItemIO(at url: URL) -> IO<Error, ()> {
        IO.invoke {
            try self.evictUbiquitousItem(at: url)
        }
    }
    
    /// IO suspended version of `FileManager.url(forPublishingUbiquitousItemAt:expiration:)`. Refer to that method for further documentation.
    func urlIO(
        forPublishingUbiquitousItemAt url: URL,
        expiration outDate: AutoreleasingUnsafeMutablePointer<NSDate?>?) -> IO<Error, URL> {
        IO.invoke {
            try self.url(forPublishingUbiquitousItemAt: url, expiration: outDate)
        }
    }
    
    // MARK: - Accessing File Provider Services
    
    /// IO suspended version of `FileManager.getFileProviderServicesForItem(at:completionHandler:)`. Refer to that method for further documentation.
    @available(OSX 10.13, *)
    @available(iOS 11.0, *)
    func getFileProviderServicesForItemIO(at url: URL) -> IO<Error, [NSFileProviderServiceName: NSFileProviderService]> {
        IO.async { callback in
            self.getFileProviderServicesForItem(at: url) { services, error in
                if let services = services {
                    callback(.right(services))
                } else if let error = error {
                    callback(.left(error))
                }
            }
        }^
    }
}
