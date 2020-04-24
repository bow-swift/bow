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
    
    
    
    
    
    
    
//    
//    // MARK: Creating Symbolic and Hard Links
//    
//    /// IO suspended version of `FileManager.createSymbolicLink(at:withDestinationPath:)`. Refer to that method for further documentation.
//    func createSymbolicLinkIO(
//        at url: URL,
//        withDestinationURL destinationURL: URL) -> IO<Error, ()> {
//        IO.invoke {
//            try self.createSymbolicLink(at: url, withDestinationURL: destinationURL)
//        }
//    }
//    
//    /// IO suspended version of `FileManager.createSymbolicLink(atPath:withDestinationPath:)`. Refer to that method for further documentation.
//    func createSymbolicLinkIO(
//        atPath path: String,
//        withDestinationPath destinationPath: String) -> IO<Error, ()> {
//        IO.invoke {
//            try self.createSymbolicLink(atPath: path, withDestinationPath: destinationPath)
//        }
//    }
//    
//    /// IO suspended version of `FileManager.linkItem(at:to:)`. Refer to that method for further documentation.
//    func linkItemIO(
//        at url: URL,
//        to destinationURL: URL) -> IO<Error, ()> {
//        IO.invoke {
//            try self.linkItem(at: url, to: destinationURL)
//        }
//    }
//    
//    /// IO suspended version of `FileManager.linkItem(atPath:toPath:)`. Refer to that method for further documentation.
//    func linkItemIO(
//        atPath path: String,
//        toPath destinationPath: String) -> IO<Error, ()> {
//        IO.invoke {
//            try self.linkItem(atPath: path, toPath: destinationPath)
//        }
//    }
//    
//    /// IO suspended version of `FileManager.destinationOfSymbolicLink(atPath:)`. Refer to that method for further documentation.
//    func destinationOfSymbolicLinkIO(atPath path: String) -> IO<Error, String> {
//        IO.invoke {
//            try self.destinationOfSymbolicLink(atPath: path)
//        }
//    }
//    
//    // MARK: Getting and Setting Attributes
//    
//    /// IO suspended version of `FileManager.componentsToDisplay(forPath:)`. Refer to that method for further documentation.
//    func componentsToDisplayIO(forPath path: String) -> IO<Error, [String]?> {
//        IO.invoke {
//            self.componentsToDisplay(forPath: path)
//        }
//    }
//    
//    /// IO suspended version of `FileManager.displayName(atPath:)`. Refer to that method for further documentation.
//    func displayNameIO(atPath path: String) -> IO<Error, String> {
//        IO.invoke {
//            self.displayName(atPath: path)
//        }
//    }
//    
//    /// IO suspended version of `FileManager.attributesOfItem(atPath:)`. Refer to that method for further documentation.
//    func attributesOfItemIO(atPath path: String) -> IO<Error, [FileAttributeKey: Any]> {
//        IO.invoke {
//            try self.attributesOfItem(atPath: path)
//        }
//    }
//    
//    /// IO suspended version of `FileManager.attributesOfFileSystem(forPath:)`. Refer to that method for further documentation.
//    func attributesOfFileSystemIO(forPath path: String) -> IO<Error, [FileAttributeKey: Any]> {
//        IO.invoke {
//            try self.attributesOfFileSystem(forPath: path)
//        }
//    }
//    
//    /// IO suspended version of `FileManager.setAttributes(_:ofItemAtPath:)`. Refer to that method for further documentation.
//    func setAttributesIO(
//        _ attrs: [FileAttributeKey: Any],
//        ofItemAtPath path: String) -> IO<Error, ()> {
//        IO.invoke {
//            try self.setAttributes(attrs, ofItemAtPath: path)
//        }
//    }
//    
//    // MARK: Getting and Comparing File Contents
//    
//    /// IO suspended version of `FileManager.contents(atPath:)`. Refer to that method for further documentation.
//    func contentsIO(atPath path: String) -> IO<Error, Data?> {
//        IO.invoke {
//            self.contents(atPath: path)
//        }
//    }
//    
//    /// IO suspended version of `FileManager.contentsEqual(atPath:andPath:)`. Refer to that method for further documentation.
//    func contentsEqualIO(
//        atPath path: String,
//        andPath otherPath: String) -> IO<Error, Bool> {
//        IO.invoke {
//            self.contentsEqual(atPath: path, andPath: otherPath)
//        }
//    }
//    
//    // MARK: Managing the Current Directory
//    
//    /// IO suspended version of `FileManager.changeCurrentDirectoryPath(_:)`. Refer to that method for further documentation.
//    func changeCurrentDirectoryPathIO(_ path: String) -> IO<Error, Bool> {
//        IO.invoke {
//            self.changeCurrentDirectoryPath(path)
//        }
//    }
}
