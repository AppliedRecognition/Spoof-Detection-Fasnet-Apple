// The Swift Programming Language
// https://docs.swift.org/swift-book
import VerIDCommonTypes
import FASnetSpoofDetectionCore
import UIKit

public class FASnetSpoofDetection: FASnetSpoofDetectionCore {
    
    public let apiKey: String
    public let url: URL
    
    public init(apiKey: String, url: URL) {
        self.apiKey = apiKey
        self.url = url
        try! super.init()
    }
    
    public override func detectSpoofInImages(_ images: [CGImage]) async throws -> Float {
        let imageData = images.compactMap { image in
            return UIImage(cgImage: image).jpegData(compressionQuality: 1.0)
        }
        let body = try self.createRequestBodyFromImageData(imageData)
        var request = URLRequest(url: self.url)
        request.httpMethod = "POST"
        request.setValue(self.apiKey, forHTTPHeaderField: "x-api-key")
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        let (data, response) = try await URLSession.shared.upload(for: request, from: body)
        guard let statusCode = (response as? HTTPURLResponse)?.statusCode, statusCode < 400 else {
            throw NetworkRequestError.requestFailed
        }
        let score = try JSONDecoder().decode(Float.self, from: data)
        return score
    }
    
    private func createRequestBodyFromImageData(_ data: [Data]) throws -> Data {
        return try JSONEncoder().encode(ImagesPayload(images: data))
    }
}

fileprivate struct ImagesPayload: Encodable {
    
    let images: [Data]
}
