import XCTest
import OHHTTPStubs
import OHHTTPStubsSwift
import VerIDCommonTypes
import UniformTypeIdentifiers
@testable import FASnetSpoofDetection

final class FASnetSpoofDetectionTests: XCTestCase {
    
    var spoofDetection: FASnetSpoofDetection!
    
    lazy var testImage: Image? = {
        guard let imageUrl = Bundle.module.url(forResource: "face_on_iPad_001", withExtension: "jpg", subdirectory: nil) else {
            return nil
        }
        guard let imageData = try? Data(contentsOf: imageUrl) else {
            return nil
        }
        guard let cgImage = UIImage(data: imageData)?.cgImage else {
            return nil
        }
        guard let image = Image(cgImage: cgImage, orientation: .up, depthData: nil) else {
            return nil
        }
        return image
    }()
    let testImageFaceRect = CGRect(x: 1020, y: 1420, width: 1070, height: 1350)
    
    override func setUpWithError() throws {
        HTTPStubs.setEnabled(true)
        HTTPStubs.removeAllStubs()
        self.spoofDetection = try self.createSpoofDetection()
    }
    
    override func tearDown() {
        HTTPStubs.removeAllStubs()
        HTTPStubs.setEnabled(false)
    }
    
    func testDetectSpoof() async throws {
        let expectedScore: Float = 0.8
        stub(condition: pathEndsWith("/detect_spoof") && isMethodPOST()) { _ in
            do {
                let json = try JSONEncoder().encode(expectedScore)
                return HTTPStubsResponse(data: json, statusCode: 200, headers: ["Content-Type": "application/json"])
            } catch {
                return HTTPStubsResponse(error: error)
            }
        }
        guard let image = self.testImage else {
            XCTFail()
            return
        }
        let score = try await self.spoofDetection.detectSpoofInImage(image, regionOfInterest: self.testImageFaceRect)
        XCTAssertEqual(score, expectedScore, accuracy: 0.001)
    }
    
    func testDetectSpoofInCloud() async throws {
        try XCTSkipIf(Self.cloudAPIKey == nil, "Set VERID_CLOUD_API_KEY to run the tests that call the cloud service.")
        HTTPStubs.removeAllStubs()
        HTTPStubs.setEnabled(false)
        guard let image = self.testImage else {
            XCTFail()
            return
        }
        let score = try await self.spoofDetection.detectSpoofInImage(image, regionOfInterest: self.testImageFaceRect)
        XCTAssertGreaterThan(score, 0.5)
    }
    
    @available(iOS 14, *)
    func testCreateSpoofImages() throws {
        throw XCTSkip()
        guard let image = self.testImage else {
            XCTFail()
            return
        }
        let images = try self.spoofDetection.createInferenceImagesFromImage(image, roi: self.testImageFaceRect).compactMap { UIImage(cgImage: $0).jpegData(compressionQuality: 1.0)?.base64EncodedString() }
        XCTAssertEqual(images.count, 2)
        let dict: [String:[String]] = [
            "images": images
        ]
        let json = try JSONEncoder().encode(dict)
        let attachment = XCTAttachment(data: json, uniformTypeIdentifier: UTType.json.identifier)
        attachment.lifetime = .keepAlways
        attachment.name = "fasnet.json"
        self.add(attachment)
    }
    
    private func createSpoofDetection() throws -> FASnetSpoofDetection {
        guard let configUrl = Bundle.module.url(forResource: "config", withExtension: "json") else {
            throw XCTSkip()
        }
        guard let configData = try? Data(contentsOf: configUrl) else {
            throw XCTSkip()
        }
        guard let config = try? JSONDecoder().decode(Config.self, from: configData) else {
            throw XCTSkip()
        }
        guard let url = URL(string: config.url) else {
            throw XCTSkip()
        }
        // Constructed with whatever key is available, including none. The stubbed tests never
        // reach the network, so only the cloud test needs a real key, and it skips itself.
        // Skipping here would skip the whole class, because `setUpWithError` calls this.
        return FASnetSpoofDetection(apiKey: Self.cloudAPIKey ?? "", url: url)
    }

    /// The cloud API key, taken from the environment.
    ///
    /// It used to sit in `Resources/config.json`, which is committed — and this repository is
    /// public — so a live key for a metered service was republished in every clone. The endpoint
    /// stays in the committed config; the key does not. Without one the cloud tests skip, which
    /// is what a test needing a credential should do on a machine that has none.
    private static var cloudAPIKey: String? {
        ProcessInfo.processInfo.environment["VERID_CLOUD_API_KEY"].flatMap { $0.isEmpty ? nil : $0 }
    }
}

fileprivate struct Config: Decodable {
    
    let url: String
    
}
