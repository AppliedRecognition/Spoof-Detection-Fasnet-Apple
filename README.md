# Spoof Detection using FASnet Model

> **Deprecated, and this repository is archived.** No new versions will be published.
>
> It was a cloud FASnet spoof-detection model, and it is not the liveness classifier the
> Ver-ID 3 pipeline uses: FASnet classifies three classes at 112×112, against the two
> classes at 224×224 the Stage 2 classifier works on. Nothing in the current stack depends
> on it, and its only consumer was `Spoof-Detection-Fusion-Apple`, which is archived for the
> same reason.
>
> Use [`Spoof-Device-Detection-Ver-ID-3-Apple`](https://github.com/AppliedRecognition/Spoof-Device-Detection-Ver-ID-3-Apple)
> instead.
>
> Archiving makes the repository read-only. It stays clonable and its tags stay resolvable,
> so an existing `Package.resolved` that pins a version here keeps working.

Detects spoof in images

## Installation

### Swift Package Manager

1. Open your project in Xcode.
2. Select your project in the Project Navigator.
3. Click on the Package Dependencies tab.
4. Click the + icon and enter `https://github.com/AppliedRecognition/Spoof-Detection-Fasnet-Apple.git` in the search box labelled "Search or Enter Package URL".
5. In the Dependency Rule drop-down select Up to Next Major Version and enter 1.0.0 in the adjacent text box.
6. Press the "Add Package" button.

## Usage

You will need an API key to use the spoof detection in your project. The API key in tests is rate-limited and not suitable for production applications. Please [contact Applied Recognition](mailto:support@appliedrecognition.com) to obtain an API key.
                                                                                                                                    
### Sample code

Find out whether a face in an image is a spoof.

```swift
import FASnetSpoofDetection
import VerIDCommonTypes

let uiImage: UIImage // The image in which to detect spoof devices
let face: Face // Face detected in the image

let apiKey: String // Your API key
let url: URL // Service URL

let spoofDetection = FASnetSpoofDetection(apiKey: apiKey, url: url)
guard let cgImage = uiImage.cgImage, let image = Image(cgImage: cgImage) else {
    fatalError("Image conversion failed")
}
Task {
    let isSpoof = try await spoofDetection.isSpoofInImage(image, regionOfInterest: face.bounds)
}
```
