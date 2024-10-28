// LULUKit (Samuel Campos de Andrade)

import Foundation
import PencilKit
import AVFoundation

@available(iOS 13.0, *)
public class C3CaptchaVerifier: ObservableObject {
    public var currentShape: String = ""
    public var questionShape: String = ""
    private var attemptCount: Int = 0
    private var startTime: Date?
    private let minimumResponseTime: TimeInterval = 2.0
    private var audioPlayer: AVAudioPlayer?

    public init() {
        generateRandomQuestion()
        startTime = Date()
    }

    public func generateRandomQuestion() {
        let shapes = ["círculo", "retângulo", "triângulo", "linha", "pentágono", "hexágono", "estrela", "coração", "losango"]
        let questions = [
            "Desenhe um círculo.",
            "Desenhe um retângulo.",
            "Desenhe um triângulo.",
            "Desenhe uma linha.",
            "Desenhe um pentágono.",
            "Desenhe um hexágono.",
            "Desenhe uma estrela.",
            "Desenhe um coração.",
            "Desenhe um losango."
        ]

        if let randomShape = shapes.randomElement(),
           let randomQuestion = questions.first(where: { $0.contains(randomShape) }) {
            currentShape = randomShape
            questionShape = randomQuestion
        }
        startTime = Date()
        attemptCount = 0
    }
    
    @available(iOS 14.0, *)
    public func isShapeCorrect(drawing: PKDrawing) -> Bool {
        guard hasSufficientResponseTime() else { return false }
        attemptCount += 1

        let strokes = drawing.strokes
        guard strokes.count == 1, let firstStroke = strokes.first else { return false }
        
        switch currentShape {
        case "círculo":
            return isApproximateCircle(firstStroke)
        case "retângulo":
            return isApproximateRectangle(firstStroke)
        case "triângulo":
            return isApproximateTriangle(firstStroke)
        case "linha":
            return isApproximateLine(firstStroke)
        case "pentágono":
            return isApproximatePentagon(firstStroke)
        case "hexágono":
            return isApproximateHexagon(firstStroke)
        case "estrela":
            return isApproximateStar(firstStroke)
        case "coração":
            return isApproximateHeart(firstStroke)
        case "losango":
            return isApproximateDiamond(firstStroke)
        default:
            playErrorSound()
            return false
        }
    }
    
    private func hasSufficientResponseTime() -> Bool {
        guard let start = startTime else { return false }
        let elapsedTime = Date().timeIntervalSince(start)
        return elapsedTime >= minimumResponseTime
    }

    @available(iOS 14.0, *)
    private func isApproximateCircle(_ stroke: PKStroke) -> Bool {
        let boundingRect = boundingBox(for: stroke)
        let width = boundingRect.width
        let height = boundingRect.height
        let aspectRatio = width / height
        let isCircle = abs(aspectRatio - 1.0) < 0.2 && (width * height) > 1000
        return isCircle && hasSufficientResponseTime()
    }

    public func getAttemptCount() -> Int {
        return attemptCount
    }

    @available(iOS 14.0, *)
    private func isPartialShape(_ stroke: PKStroke) -> Bool {
        let path = stroke.path
        return path.count < 3
    }

    private func evaluateResponseTime() -> String {
        guard let start = startTime else { return "Tempo não disponível" }
        let elapsedTime = Date().timeIntervalSince(start)
        if elapsedTime < minimumResponseTime {
            return "Resposta rápida demais. Tente novamente."
        } else {
            return "Resposta dentro do tempo aceitável."
        }
    }

    private func playErrorSound() {
        let path = Bundle.main.path(forResource: "errorSound", ofType: "mp3")!
        let url = URL(fileURLWithPath: path)
        do {
            audioPlayer = try AVAudioPlayer(contentsOf: url)
            audioPlayer?.play()
        } catch {
            print("Erro ao reproduzir o som de erro: \(error)")
        }
    }

    @available(iOS 14.0, *)
    private func isValidStrokeWidth(_ stroke: PKStroke) -> Bool {
        return stroke.path.map { $0.location.x }.max() ?? 0 - (stroke.path.map { $0.location.x }.min() ?? 0) < 5
    }

    @available(iOS 14.0, *)
    private func boundingBox(for stroke: PKStroke) -> CGRect {
        let path = stroke.path
        var minX: CGFloat = .infinity
        var maxX: CGFloat = -.infinity
        var minY: CGFloat = .infinity
        var maxY: CGFloat = -.infinity
        
        for point in path {
            let x = point.location.x
            let y = point.location.y
            if x < minX { minX = x }
            if x > maxX { maxX = x }
            if y < minY { minY = y }
            if y > maxY { maxY = y }
        }
        
        return CGRect(x: minX, y: minY, width: maxX - minX, height: maxY - minY)
    }
}
