// LULUKit (Samuel Campos de Andrade)

import Foundation
import PencilKit

@available(iOS 13.0, *)
public class C3CaptchaVerifier: ObservableObject {
    public var currentShape: String = ""
    public var questionShape: String = ""

    public init() {
        generateRandomQuestion()
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
    }
@available(iOS 14.0, *)
    public func isShapeCorrect(drawing: PKDrawing) -> Bool {
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
            return false
        }
    }
    
   @available(iOS 14.0, *)
    private func isApproximateCircle(_ stroke: PKStroke) -> Bool {
        let boundingRect = boundingBox(for: stroke)
        let width = boundingRect.width
        let height = boundingRect.height
        let aspectRatio = width / height
        return abs(aspectRatio - 1.0) < 0.2 && (width * height) > 1000
    }
    @available(iOS 14.0, *)
    private func isApproximateRectangle(_ stroke: PKStroke) -> Bool {
        let boundingRect = boundingBox(for: stroke)
        let width = boundingRect.width
        let height = boundingRect.height
        let aspectRatio = width / height
        return (abs(aspectRatio - 1.0) < 0.2 || abs(aspectRatio - 2.0) < 0.2) && (width * height) > 1000
    }
    @available(iOS 14.0, *)
    private func isApproximateTriangle(_ stroke: PKStroke) -> Bool {
        return stroke.path.count >= 3
    }
    @available(iOS 14.0, *)
    private func isApproximateLine(_ stroke: PKStroke) -> Bool {
        return stroke.path.count >= 2
    }
    @available(iOS 14.0, *)
    private func isApproximatePentagon(_ stroke: PKStroke) -> Bool {
        return stroke.path.count >= 5
    }
    @available(iOS 14.0, *)
    private func isApproximateHexagon(_ stroke: PKStroke) -> Bool {
        return stroke.path.count >= 6
    }
    @available(iOS 14.0, *)
    private func isApproximateStar(_ stroke: PKStroke) -> Bool {
        return stroke.path.count >= 10
    }
    @available(iOS 14.0, *)
    private func isApproximateHeart(_ stroke: PKStroke) -> Bool {
        return stroke.path.count >= 10
    }
    @available(iOS 14.0, *)
    private func isApproximateDiamond(_ stroke: PKStroke) -> Bool {
        return stroke.path.count >= 4
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
@available(iOS 14.0, *)
public struct CGPointWrapper: Hashable {
    let location: CGPoint

    public func hash(into hasher: inout Hasher) {
        hasher.combine(location.x)
        hasher.combine(location.y)
    }
  
    public static func == (lhs: CGPointWrapper, rhs: CGPointWrapper) -> Bool {
        return lhs.location == rhs.location
    }
}
