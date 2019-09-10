import Foundation
import Bow

public extension URLSession {
    typealias DataIO = IO<Error, (response: URLResponse, data: Data)>
    typealias DownloadIO = IO<Error, (response: URLResponse, url: URL)>
    
    func dataTaskIO(with url: URL) -> DataIO {
        return IO.async { callback in
            self.dataTask(with: url, completionHandler: self.onResponse(callback)).resume()
        }^
    }
    
    func dataTaskIO(with request: URLRequest) -> DataIO {
        return IO.async { callback in
            self.dataTask(with: request, completionHandler: self.onResponse(callback)).resume()
        }^
    }
    
    func downloadTaskIO(with url: URL) -> DownloadIO {
        return IO.async { callback in
            self.downloadTask(with: url, completionHandler: self.onResponse(callback)).resume()
        }^
    }
    
    func downloadTaskIO(with request: URLRequest) -> DownloadIO {
        return IO.async { callback in
            self.downloadTask(with: request, completionHandler: self.onResponse(callback)).resume()
        }^
    }
    
    func downloadTaskIO(withResumeData data: Data) -> DownloadIO {
        return IO.async { callback in
            self.downloadTask(withResumeData: data, completionHandler: self.onResponse(callback)).resume()
        }^
    }
    
    func uploadTaskIO(with request: URLRequest, from data: Data) -> DataIO {
        return IO.async { callback in
            self.uploadTask(with: request, from: data, completionHandler: self.onResponse(callback)).resume()
        }^
    }
    
    func uploadTaskIO(with request: URLRequest, fromFile url: URL) -> DataIO {
        return IO.async { callback in
            self.uploadTask(with: request, fromFile: url, completionHandler: self.onResponse(callback)).resume()
        }^
    }
    
    private func onResponse(_ callback: @escaping (Either<Error, (response: URLResponse, data: Data)>) -> ()) -> (Data?, URLResponse?, Error?) -> () {
        return { data, response, error in
            if let data = data, let response = response {
                callback(.right((response, data)))
            } else if let error = error {
                callback(.left(error))
            }
        }
    }
    
    private func onResponse(_ callback: @escaping (Either<Error, (response: URLResponse, url: URL)>) -> ()) -> (URL?, URLResponse?, Error?) -> () {
        return { url, response, error in
            if let url = url, let response = response {
                callback(.right((response, url)))
            } else if let error = error {
                callback(.left(error))
            }
        }
    }
}
