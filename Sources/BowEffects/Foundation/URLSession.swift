import Foundation
#if canImport(FoundationNetworking)
import FoundationNetworking
#endif

import Bow

/// Utilities to perform data, download and upload tasks in a functional manner.
public extension URLSession {
    typealias DataIO = IO<Error, (response: URLResponse, data: Data)>
    typealias DownloadIO = IO<Error, (response: URLResponse, url: URL)>
    
    // MARK: Adding Data Tasks to a Session
    
    /// IO suspended version of `URLSession.dataTask(with:)`. Refer to that function for further documentation.
    func dataTaskIO(with url: URL) -> DataIO {
        IO.async { callback in
            self.dataTask(with: url, completionHandler: self.onResponse(callback)).resume()
        }^
    }
    
    /// IO suspended version of `URLSession.dataTask(with:)`. Refer to that function for further documentation.
    func dataTaskIO(with request: URLRequest) -> DataIO {
        IO.async { callback in
            self.dataTask(with: request, completionHandler: self.onResponse(callback)).resume()
        }^
    }
    
    // MARK: Adding Download Tasks to a Session
    
    /// IO suspended version of `URLSession.downloadTask(with:)`. Refer to that function for further documentation.
    func downloadTaskIO(with url: URL) -> DownloadIO {
        IO.async { callback in
            self.downloadTask(with: url, completionHandler: self.onResponse(callback)).resume()
        }^
    }
    
    /// IO suspended version of `URLSession.downloadTask(with:)`. Refer to that function for further documentation.
    func downloadTaskIO(with request: URLRequest) -> DownloadIO {
        IO.async { callback in
            self.downloadTask(with: request, completionHandler: self.onResponse(callback)).resume()
        }^
    }
    
    /// IO suspended version of `URLSession.downloadTask(withResumeData:)`. Refer to that function for further documentation.
    func downloadTaskIO(withResumeData data: Data) -> DownloadIO {
        IO.async { callback in
            self.downloadTask(withResumeData: data, completionHandler: self.onResponse(callback)).resume()
        }^
    }
    
    // MARK: Adding Upload Tasks to a Session
    
    /// IO suspended version of `URLSession.uploadTask(with:from:)`. Refer to that function for further documentation.
    func uploadTaskIO(
        with request: URLRequest,
        from data: Data) -> DataIO {
        IO.async { callback in
            self.uploadTask(with: request, from: data, completionHandler: self.onResponse(callback)).resume()
        }^
    }
    
    /// IO suspended version of `URLSession.uploadTask(with:fromFile:)`. Refer to that function for further documentation.
    func uploadTaskIO(
        with request: URLRequest,
        fromFile url: URL) -> DataIO {
        IO.async { callback in
            self.uploadTask(with: request, fromFile: url, completionHandler: self.onResponse(callback)).resume()
        }^
    }
    
    private func onResponse(_ callback: @escaping (Either<Error, (response: URLResponse, data: Data)>) -> ()) -> (Data?, URLResponse?, Error?) -> () {
        { data, response, error in
            if let data = data, let response = response {
                callback(.right((response, data)))
            } else if let error = error {
                callback(.left(error))
            }
        }
    }
    
    private func onResponse(_ callback: @escaping (Either<Error, (response: URLResponse, url: URL)>) -> ()) -> (URL?, URLResponse?, Error?) -> () {
        { url, response, error in
            if let url = url, let response = response {
                callback(.right((response, url)))
            } else if let error = error {
                callback(.left(error))
            }
        }
    }
}
