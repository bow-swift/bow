import Foundation

@available(tvOS, unavailable)
@available(watchOS, unavailable)
public extension FileManager {
    
    // MARK: Locating System Directories
    
    /// IO suspended version of `FileManager.url(for:in:appropriateFor:create:)`. Refer to that method for further documentation.
    func urlIO(for directory: FileManager.SearchPathDirectory, in domain: FileManager.SearchPathDomainMask, appropriateFor url: URL, create shouldCreate: Bool) -> IO<Error, URL> {
        return IO.invoke { try self.url(for: directory, in: domain, appropriateFor: url, create: shouldCreate) }
    }
    
    // MARK: Discovering Directory Contents
    
    /// IO suspended version of `FileManager.contensOfDirectory(at:includingPropertiesForKeys:options:)`. Refer to that method for further documentation.
    func contentsOfDirectoryIO(at url: URL, includingPropertiesForKeys keys: [URLResourceKey]?, options mask: FileManager.DirectoryEnumerationOptions = []) -> IO<Error, [URL]> {
        return IO.invoke { try self.contentsOfDirectory(at: url, includingPropertiesForKeys: keys, options: mask) }
    }
    
    /// IO suspended version of `FileManager.contentsOfDirectory(atPath:)`. Refer to that method for further documentation.
    func contentsOfDirectoryIO(atPath path: String) -> IO<Error, [String]> {
        return IO.invoke { try self.contentsOfDirectory(atPath: path) }
    }
    
    /// IO suspended version of `FileManager.subpathsOfDirectory(atPath:)`. Refer to that method for further documentation.
    func subpathsOfDirectoryIO(atPath path: String) -> IO<Error, [String]> {
        return IO.invoke { try self.subpathsOfDirectory(atPath: path) }
    }
    
    // MARK: Creating and Deleting Items
    
    /// IO suspended version of `FileManager.createDirectory(at:withIntermediateDirectories:attributes:)`. Refer to that method for further documentation.
    func createDirectoryIO(at url: URL, withIntermediateDirectories createIntermediates: Bool, attributes: [FileAttributeKey: Any]? = nil) -> IO<Error, ()> {
        return IO.invoke { try self.createDirectory(at: url, withIntermediateDirectories: createIntermediates, attributes: attributes) }
    }
    
    /// IO suspended version of `FileManager.createDirectory(atPath:withIntermediateDirectories:attributes:)`. Refer to that method for further documentation.
    func createDirectoryIO(atPath path: String, withIntermediateDirectories createIntermediates: Bool, attributes: [FileAttributeKey: Any]? = nil) -> IO<Error, ()> {
        return IO.invoke { try self.createDirectory(atPath: path, withIntermediateDirectories: createIntermediates, attributes: attributes) }
    }
    
    /// IO suspended version of `FileManager.createFile(atPath:contents:attributes:)`. Refer to that method for further documentation.
    func createFileIO(atPath path: String, contents: Data?, attributes: [FileAttributeKey: Any]? = nil) -> IO<Error, Bool> {
        return IO.invoke { self.createFile(atPath: path, contents: contents, attributes: attributes) }
    }
    
    /// IO suspended version of `FileManager.removeItem(at:)`. Refer to that method for further documentation.
    func removeItemIO(at url: URL) -> IO<Error, ()> {
        return IO.invoke { try self.removeItem(at: url) }
    }
    
    /// IO suspended version of `FileManager.removeItem(atPath:)`. Refer to that method for further documentation.
    func removeItemIO(atPath path: String) -> IO<Error, ()> {
        return IO.invoke { try self.removeItem(atPath: path) }
    }
    
    /// IO suspended version of `FileManager.trashItem(at:resultingItemURL:)`. Refer to that method for further documentation.
    @available(iOS 11.0, *)
    func trashItemIO(at url: URL, resultingItemURL outResultingURL: AutoreleasingUnsafeMutablePointer<NSURL?>?) -> IO<Error, ()> {
        return IO.invoke { try self.trashItem(at: url, resultingItemURL: outResultingURL) }
    }
    
    // MARK: Replacing Items
    
    /// IO suspended version of `FileManager.replaceItemAt(_:withItemAt:backupItemName:options:)`. Refer to that method for further documentation.
    func replaceItemIO(at originalItemURL: URL, withItemAt newItemURL: URL, backupItemName: String? = nil, options: FileManager.ItemReplacementOptions = []) -> IO<Error, URL?> {
        return IO.invoke { try self.replaceItemAt(originalItemURL, withItemAt: newItemURL, backupItemName: backupItemName, options: options) }
    }
    
    // MARK: Moving and Copying Items
    
    /// IO suspended version of `FileManager.copyItem(at:to:)`. Refer to that method for further documentation.
    func copyItemIO(at originalItemURL: URL, to newItemURL: URL) -> IO<Error, ()> {
        return IO.invoke { try self.copyItem(at: originalItemURL, to: newItemURL) }
    }
    
    /// IO suspended version of `FileManager.copyItem(atPath:toPath:)`. Refer to that method for further documentation.
    func copyItemIO(atPath originalItemPath: String, toPath newItemPath: String) -> IO<Error, ()> {
        return IO.invoke { try self.copyItem(atPath: originalItemPath, toPath: newItemPath) }
    }
    
    /// IO suspended version of `FileManager.moveItem(at:to:)`. Refer to that method for further documentation.
    func moveItemIO(at originalItemURL: URL, to newItemURL: URL) -> IO<Error, ()> {
        return IO.invoke { try self.moveItem(at: originalItemURL, to: newItemURL) }
    }
    
    /// IO suspended version of `FileManager.moveItem(atPath:toPath:)`. Refer to that method for further documentation.
    func moveItemIO(atPath originalItemPath: String, to newItemPath: String) -> IO<Error, ()> {
        return IO.invoke { try self.moveItem(atPath: originalItemPath, toPath: newItemPath) }
    }
    
    // MARK: Managing iCloud-Based Items
    
    /// IO suspended version of `FileManager.setUbiquitous(_:itemAt:destinationURL:)`. Refer to that method for further documentation.
    func setUbiquitousIO(_ flag: Bool, itemAt url: URL, destinationURL: URL) -> IO<Error, ()> {
        return IO.invoke { try self.setUbiquitous(flag, itemAt: url, destinationURL: destinationURL) }
    }
    
    /// IO suspended version of `FileManager.startDownloadingUbiquitousItem(at:)`. Refer to that method for further documentation.
    func startDownloadingUbiquitousItemIO(at url: URL) -> IO<Error, ()> {
        return IO.invoke { try self.startDownloadingUbiquitousItem(at: url) }
    }
    
    /// IO suspended version of `FileManager.evictUbiquitousItem(at:)`. Refer to that method for further documentation.
    func evictUbiquitousItemIO(at url: URL) -> IO<Error, ()> {
        return IO.invoke { try self.evictUbiquitousItem(at: url) }
    }
    
    /// IO suspended version of `FileManager.url(forPublishingUbiquitousItemAt:expiration:)`. Refer to that method for further documentation.
    func urlIO(forPublishingUbiquitousItemAt url: URL, expiration outDate: AutoreleasingUnsafeMutablePointer<NSDate?>?) -> IO<Error, URL> {
        return IO.invoke { try self.url(forPublishingUbiquitousItemAt: url, expiration: outDate) }
    }
    
    // MARK: Accessing File Provider Services
    
    /// IO suspended version of `FileManager.getFileProviderServicesForItem(at:completionHandler:)`. Refer to that method for further documentation.
    @available(OSX 10.13, *)
    @available(iOS 11.0, *)
    func getFileProviderServicesForItemIO(at url: URL) -> IO<Error, [NSFileProviderServiceName: NSFileProviderService]> {
        return IO.async { callback in
            self.getFileProviderServicesForItem(at: url) { services, error in
                if let services = services {
                    callback(.right(services))
                } else if let error = error {
                    callback(.left(error))
                }
            }
        }^
    }
    
    // MARK: Creating Symbolic and Hard Links
    
    /// IO suspended version of `FileManager.createSymbolicLink(at:withDestinationPath:)`. Refer to that method for further documentation.
    func createSymbolicLinkIO(at url: URL, withDestinationURL destinationURL: URL) -> IO<Error, ()> {
        return IO.invoke { try self.createSymbolicLink(at: url, withDestinationURL: destinationURL) }
    }
    
    /// IO suspended version of `FileManager.createSymbolicLink(atPath:withDestinationPath:)`. Refer to that method for further documentation.
    func createSymbolicLinkIO(atPath path: String, withDestinationPath destinationPath: String) -> IO<Error, ()> {
        return IO.invoke { try self.createSymbolicLink(atPath: path, withDestinationPath: destinationPath) }
    }
    
    /// IO suspended version of `FileManager.linkItem(at:to:)`. Refer to that method for further documentation.
    func linkItemIO(at url: URL, to destinationURL: URL) -> IO<Error, ()> {
        return IO.invoke { try self.linkItem(at: url, to: destinationURL) }
    }
    
    /// IO suspended version of `FileManager.linkItem(atPath:toPath:)`. Refer to that method for further documentation.
    func linkItemIO(atPath path: String, toPath destinationPath: String) -> IO<Error, ()> {
        return IO.invoke { try self.linkItem(atPath: path, toPath: destinationPath) }
    }
    
    /// IO suspended version of `FileManager.destinationOfSymbolicLink(atPath:)`. Refer to that method for further documentation.
    func destinationOfSymbolicLinkIO(atPath path: String) -> IO<Error, String> {
        return IO.invoke { try self.destinationOfSymbolicLink(atPath: path) }
    }
    
    // MARK: Getting and Setting Attributes
    
    /// IO suspended version of `FileManager.componentsToDisplay(forPath:)`. Refer to that method for further documentation.
    func componentsToDisplayIO(forPath path: String) -> IO<Error, [String]?> {
        return IO.invoke { self.componentsToDisplay(forPath: path) }
    }
    
    /// IO suspended version of `FileManager.displayName(atPath:)`. Refer to that method for further documentation.
    func displayNameIO(atPath path: String) -> IO<Error, String> {
        return IO.invoke { self.displayName(atPath: path) }
    }
    
    /// IO suspended version of `FileManager.attributesOfItem(atPath:)`. Refer to that method for further documentation.
    func attributesOfItemIO(atPath path: String) -> IO<Error, [FileAttributeKey: Any]> {
        return IO.invoke { try self.attributesOfItem(atPath: path) }
    }
    
    /// IO suspended version of `FileManager.attributesOfFileSystem(forPath:)`. Refer to that method for further documentation.
    func attributesOfFileSystemIO(forPath path: String) -> IO<Error, [FileAttributeKey: Any]> {
        return IO.invoke { try self.attributesOfFileSystem(forPath: path) }
    }
    
    /// IO suspended version of `FileManager.setAttributes(_:ofItemAtPath:)`. Refer to that method for further documentation.
    func setAttributesIO(_ attrs: [FileAttributeKey: Any], ofItemAtPath path: String) -> IO<Error, ()> {
        return IO.invoke { try self.setAttributes(attrs, ofItemAtPath: path) }
    }
    
    // MARK: Getting and Comparing File Contents
    
    /// IO suspended version of `FileManager.contents(atPath:)`. Refer to that method for further documentation.
    func contentsIO(atPath path: String) -> IO<Error, Data?> {
        return IO.invoke { self.contents(atPath: path) }
    }
    
    /// IO suspended version of `FileManager.contentsEqual(atPath:andPath:)`. Refer to that method for further documentation.
    func contentsEqualIO(atPath path: String, andPath otherPath: String) -> IO<Error, Bool> {
        return IO.invoke { self.contentsEqual(atPath: path, andPath: otherPath) }
    }
    
    // MARK: Managing the Current Directory
    
    /// IO suspended version of `FileManager.changeCurrentDirectoryPath(_:)`. Refer to that method for further documentation.
    func changeCurrentDirectoryPathIO(_ path: String) -> IO<Error, Bool> {
        return IO.invoke { self.changeCurrentDirectoryPath(path) }
    }
}
