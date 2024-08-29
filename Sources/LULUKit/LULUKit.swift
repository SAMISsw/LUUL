// O Nome sa sua view principal deve ser ContentView

import SwiftUI
import PencilKit
import AVFoundation
import Speech

public struct C3: View {
    @State private var isTestPassed = false
    @State private var navigateToDrawingView = false
    @State private var currentShape: String = ""
    @State private var questionShape: String = ""
    @State private var drawingView = PKCanvasView()
    @State private var toolPicker = PKToolPicker()
    let synthesizer = AVSpeechSynthesizer()
    
    public var body: some View {
        NavigationView {
            VStack {
                if !isTestPassed {
                    if navigateToDrawingView {
                        DrawingView(
                            drawingView: $drawingView, 
                            toolPicker: $toolPicker, 
                            currentShape: $currentShape, 
                            questionShape: $questionShape, 
                            isShapeCorrect: $isTestPassed, 
                            navigateToNewView: $isTestPassed
                        )
                    } else {
                        HStack {
                            Text("꒒ꀎ꒒ꀎ")
                                .font(.custom("Noteworthy", size: 40))
                                .foregroundColor(.white)
                                .bold()
                                .padding()
                                .background(Color.orange)
                                .cornerRadius(6.8)
                            
                            Spacer()
                            
                            Button(action: {
                                generateRandomQuestion()
                                navigateToDrawingView = true
                            }) {
                                Image(systemName: "checkmark")
                                    .padding()
                                    .foregroundColor(.white)
                                    .background(Color.orange)
                                    .cornerRadius(6.8)
                            }
                        }
                        .padding(3)
                        .background(Color.orange)
                        .frame(width: 350, height: 100)
                        .cornerRadius(7.8)
                    }
                } else { 
                    NewView()
                }
            }
            .navigationBarHidden(true)
        }
    }
    
    public func generateRandomQuestion() {
        let shapes = ["círculo", "retângulo", "triângulo", "linha"]
        let questions = [
            "Desenhe um círculo.",
            "Desenhe um retângulo.",
            "Desenhe um triângulo.",
            "Desenhe uma linha."
        ]
        
        if let randomShape = shapes.randomElement(), 
            let randomQuestion = questions.first(where: { $0.contains(randomShape) }) {
            currentShape = randomShape
            questionShape = randomQuestion
        }
    }
}

public struct DrawingView: View {
    @Binding var drawingView: PKCanvasView
    @Binding var toolPicker: PKToolPicker
    @Binding var currentShape: String
    @Binding var questionShape: String
    @Binding var isShapeCorrect: Bool
    @Binding var navigateToNewView: Bool
    
    @State private var hasDrawn = false
    @State private var drawingStartTime: Date?
    @State private var showingAlert = false
    @State private var alertMessage = ""
    
    public var body: some View {
        VStack {
            Text("꒒ꀎ꒒ꀎ")
                .font(.custom("Noteworthy", size: 40))
                .foregroundColor(.orange)
                .bold()
            Text(questionShape)
                .font(.custom("Noteworthy", size: 30.85))
                .foregroundColor(.orange)
                .bold()
            
            DrawingViewRepresentable(
                canvasView: $drawingView, 
                toolPicker: $toolPicker, 
                onUpdate: {
                    if hasDrawn {
                        isShapeCorrect = checkShape()
                        if isShapeCorrect {
                            navigateToNewView = true
                        } else {
                            showAlert(message: "Desenho incorreto ou incapaz para um humano. Tente novamente.")
                        }
                    }
                }
            )
            .frame(height: 300)
            .background(Color.white)
            .border(Color.black, width: 1)
            
            HStack {
                Button(action: {
                    let currentTime = Date()
                    let elapsedTime = currentTime.timeIntervalSince(drawingStartTime ?? currentTime)
                    
                    if elapsedTime > 1.3 {
                        isShapeCorrect = checkShape()
                        if isShapeCorrect {
                            navigateToNewView = true
                        } else {
                            showAlert(message: "Desenho incorreto ou incapaz para um humano. Tente novamente.")
                        }
                    } else {
                        showAlert(message: "Tempo insuficiente para análise. Tente novamente.")
                    }
                }) {
                    Image(systemName: "checkmark.circle.fill")
                        .font(.system(size: 40))
                        .foregroundColor(.orange)
                        .padding()
                }
                .padding()
                
                Spacer()
            }
            
            if navigateToNewView {
                NewView()
            }
        }
        .onAppear {
            configureToolPicker()
            drawingStartTime = Date()
        }
        .onChange(of: drawingView.drawing) { _ in
            hasDrawn = true
        }
        .alert(isPresented: $showingAlert) {
            Alert(
                title: Text("Acesso Negado"),
                message: Text(alertMessage),
                dismissButton: .default(Text("OK"))
            )
        }
    }
    
    public func checkShape() -> Bool {
        let strokes = drawingView.drawing.strokes
        guard strokes.count == 1, let firstStroke = strokes.first else { return false }
        
        switch questionShape {
        case _ where questionShape.contains("círculo"):
            return isApproximateCircle(firstStroke)
        case _ where questionShape.contains("retângulo"):
            return isApproximateRectangle(firstStroke)
        case _ where questionShape.contains("triângulo"):
            return isApproximateTriangle(firstStroke)
        case _ where questionShape.contains("linha"):
            return isApproximateLine(firstStroke)
        default:
            return false
        }
    }
    
    public func isApproximateCircle(_ stroke: PKStroke) -> Bool {
        let boundingRect = boundingBox(for: stroke)
        let width = boundingRect.width
        let height = boundingRect.height
        let aspectRatio = width / height
        
        return abs(aspectRatio - 1.0) < 0.2 && (width * height) > 1000
    }
    
    public func isApproximateRectangle(_ stroke: PKStroke) -> Bool {
        let boundingRect = boundingBox(for: stroke)
        let width = boundingRect.width
        let height = boundingRect.height
        let aspectRatio = width / height
        
        return (abs(aspectRatio - 1.0) < 0.2 || abs(aspectRatio - 2.0) < 0.2) && (width * height) > 1000
    }
    
    public func isApproximateTriangle(_ stroke: PKStroke) -> Bool {
        let points = stroke.path.map { CGPointWrapper(location: $0.location) }
        let uniquePoints = Set(points)
        return uniquePoints.count >= 3
    }
    
    public func isApproximateLine(_ stroke: PKStroke) -> Bool {
        let points = stroke.path.map { CGPointWrapper(location: $0.location) }
        
        return points.count >= 2
    }
    
    public func boundingBox(for stroke: PKStroke) -> CGRect {
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
    
    public func showAlert(message: String) {
        alertMessage = message
        showingAlert = true
    }
    
    public func configureToolPicker() {
        if let window = UIApplication.shared.windows.first {
            toolPicker.setVisible(true, forFirstResponder: drawingView)
            toolPicker.addObserver(drawingView)
            drawingView.becomeFirstResponder()
        }
    }
}

public struct DrawingViewRepresentable: UIViewRepresentable {
    @Binding var canvasView: PKCanvasView
    @Binding var toolPicker: PKToolPicker
    var onUpdate: () -> Void
    
    public func makeUIView(context: Context) -> PKCanvasView {
        canvasView.delegate = context.coordinator
        toolPicker.addObserver(canvasView)
        canvasView.tool = toolPicker.selectedTool
        return canvasView
    }
    
    public func updateUIView(_ uiView: PKCanvasView, context: Context) {
        uiView.tool = toolPicker.selectedTool
        onUpdate()
    }
    
    public func makeCoordinator() -> Coordinator {
        Coordinator(self)
    }
    
    public class Coordinator: NSObject, PKCanvasViewDelegate {
        var parent: DrawingViewRepresentable
        
        public init(_ parent: DrawingViewRepresentable) {
            self.parent = parent
        }
        
        public func canvasViewDrawingDidChange(_ canvasView: PKCanvasView) {
            parent.onUpdate()
        }
    }
}

public struct NewView: View {
    public var body: some View {
        ContentView()
    }
}
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
