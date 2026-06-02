import Foundation
import UIKit

enum ImageStorage {
    private static let directoryName = "StoreImages"

    private static var imageDirectory: URL {
        let baseDirectory = FileManager.default.urls(for: .applicationSupportDirectory, in: .userDomainMask)[0]
        return baseDirectory
            .appendingPathComponent("MyGourmetRanking", isDirectory: true)
            .appendingPathComponent(directoryName, isDirectory: true)
    }

    static func saveImages(_ imageDataItems: [Data]) throws -> [String] {
        try ensureDirectoryExists()
        return try imageDataItems.map { imageData in
            let fileName = "\(UUID().uuidString).jpg"
            let fileURL = imageDirectory.appendingPathComponent(fileName)
            let preparedData = prepareImageData(imageData)
            try preparedData.write(to: fileURL, options: .atomic)
            return fileName
        }
    }

    static func image(for fileName: String) -> UIImage? {
        UIImage(contentsOfFile: imageDirectory.appendingPathComponent(fileName).path)
    }

    static func deleteImages(_ fileNames: [String]) {
        for fileName in fileNames {
            try? FileManager.default.removeItem(at: imageDirectory.appendingPathComponent(fileName))
        }
    }

    private static func ensureDirectoryExists() throws {
        try FileManager.default.createDirectory(at: imageDirectory, withIntermediateDirectories: true)
    }

    private static func prepareImageData(_ data: Data) -> Data {
        guard let image = UIImage(data: data) else {
            return data
        }

        let maxDimension: CGFloat = 1_600
        let longestSide = max(image.size.width, image.size.height)
        let scale = longestSide > maxDimension ? maxDimension / longestSide : 1
        let targetSize = CGSize(width: image.size.width * scale, height: image.size.height * scale)
        let renderer = UIGraphicsImageRenderer(size: targetSize)
        let renderedImage = renderer.image { _ in
            image.draw(in: CGRect(origin: .zero, size: targetSize))
        }
        return renderedImage.jpegData(compressionQuality: 0.84) ?? data
    }
}
