// Integrating flask server with swift
// created 7/2/2025: saidb
//

import Foundation
import UIKit

/// The decoded prediction from /api/predict
struct Prediction: Decodable, Identifiable {
    let seen: Bool
    let id: String?
    let score: Double

    private enum CodingKeys: String, CodingKey {
        case seen = "Lizard already seen"
        case id, score
    }
}

enum NetworkError: Error {
    case invalidImage
    case badResponse(Int)
    case decodingFailed
}

final class NetworkManager {
    static let shared = NetworkManager()
    private init() {}

    // flask server url
    private let baseURL = URL(string: "http://137.22.1.119:5050")!

    // upload image for prediction
    func predict(image: UIImage) async throws -> Prediction {
        let url = baseURL.appendingPathComponent("/api/predict")
        var req = URLRequest(url: url)
        req.httpMethod = "POST"

        // build multipart/form-data
        let boundary = UUID().uuidString
        req.setValue("multipart/form-data; boundary=\(boundary)",
                     forHTTPHeaderField: "Content-Type")

        guard let data = image.jpegData(compressionQuality: 0.8) else {
            throw NetworkError.invalidImage
        }

        var body = Data()
        body.append("--\(boundary)\r\n".data(using: .utf8)!)
        body.append("""
            Content-Disposition: form-data; name="file"; filename="photo.jpg"\r
            Content-Type: image/jpeg\r
            \r
            """.data(using: .utf8)!)
        body.append(data)
        body.append("\r\n--\(boundary)--\r\n".data(using: .utf8)!)

        req.httpBody = body

        // perform request
        let (respData, resp) = try await URLSession.shared.data(for: req)

        guard let http = resp as? HTTPURLResponse,
              200..<300 ~= http.statusCode else {
            let code = (resp as? HTTPURLResponse)?.statusCode ?? -1
            throw NetworkError.badResponse(code)
        }

        do {
            return try JSONDecoder().decode(Prediction.self, from: respData)
        } catch {
            throw NetworkError.decodingFailed
        }
