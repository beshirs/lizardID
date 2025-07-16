// xcode not working at the momemnt, add the tensorflowliteswift library 
import TensorFlowLite
import UIKit

struct Reference {
  let id: String
  let vector: [Float]
}

final class ModelHandler {
  private let interpreter: Interpreter
  private let references: [Reference]

  init?() {
    // Loads .tflite model from bundle
    guard let modelPath = Bundle.main.path(forResource: "lizard_embedding", ofType: "tflite") else { return nil }
    interpreter = try! Interpreter(modelPath: modelPath)
    try! interpreter.allocateTensors()

    // Loads reference embeddings JSON
    let url = Bundle.main.url(forResource: "reference_embeddings", withExtension: "json")!
    let data = try! Data(contentsOf: url)
    references = try! JSONDecoder().decode([Reference].self, from: data)
  }

  func computeEmbedding(from uiImage: UIImage) -> [Float]? {
    // resizes
    guard let pixelBuffer = uiImage.resize(to: CGSize(width:224, height:224)).normalizedBuffer() else { return nil }
    try! interpreter.copy(pixelBuffer, toInputAt: 0)
    try! interpreter.invoke()
    let outputTensor = try! interpreter.output(at: 0)
    let emb = [Float](unsafeData: outputTensor.data)  // utility extension
    let norm = sqrt(emb.reduce(0){$0 + $1*$1})
    return emb.map { $0 / norm }
  }

  func predict(uiImage: UIImage, threshold: Float = 0.8) -> (seen: Bool, id: String?, score: Float)? {
    guard let newEmb = computeEmbedding(from: uiImage) else { return nil }
    var bestScore: Float = -1
    var bestID: String?
    for ref in references {
      let dot = zip(newEmb, ref.vector).map(*).reduce(0, +)
      if dot > bestScore {
        bestScore = dot; bestID = ref.id
      }
    }
    return (bestScore >= threshold, bestID, bestScore)
  }
}
