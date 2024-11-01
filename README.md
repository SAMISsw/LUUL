# LULUKit
![Swift 5.1](https://img.shields.io/badge/Swift-5.1-orange.svg) 
[![SPM](https://img.shields.io/badge/spm-compatible-brightgreen.svg?style=flat)](https://github.com/apple/swift-package-manager)

LULUKit is a swift package for make your captcha

## Samuel Campos

Samuel, gshababa321@gmail.com

## License

LULUKit is available under the MIT license. See the LICENSE file for more info.

## LULUKit Example Code
```swift

import SwiftUI
import PencilKit
import LULUKit 


struct ContentView: View {
    @StateObject private var captchaVerifier = C3CaptchaVerifier()
    @State private var canvasView = PKCanvasView()
    @State private var resultMessage: String = ""
    
    var body: some View {
        VStack(spacing: 20) {
            Text("Captcha de Desenho")
                .font(.largeTitle)
                .padding(.top)
            
            Text(captchaVerifier.questionShape)
                .font(.title2)
                .padding()
            
            CanvasView(canvasView: $canvasView)
                .frame(height: 300)
                .background(Color.gray.opacity(0.1))
                .cornerRadius(8)
                .padding()
            
            Button("Verificar Desenho") {
                let drawing = canvasView.drawing
                let isCorrect = captchaVerifier.isShapeCorrect(drawing: drawing)
                
                resultMessage = isCorrect ? "Correto! 🎉" : "Incorreto. Tente novamente."
                
                if isCorrect {
                    captchaVerifier.generateRandomQuestion()
                    canvasView.drawing = PKDrawing() 
                }
            }
            .padding()
            .background(Color.blue)
            .foregroundColor(.white)
            .cornerRadius(8)
            
            Text(resultMessage)
                .font(.title2)
                .foregroundColor(resultMessage == "Correto! 🎉" ? .green : .red)
                .padding()
        }
        .padding()
    }
}

@available(iOS 14.0, *)
struct CanvasView: UIViewRepresentable {
    @Binding var canvasView: PKCanvasView
    
    func makeUIView(context: Context) -> PKCanvasView {
        canvasView.isOpaque = false
        canvasView.backgroundColor = .clear
        canvasView.allowsFingerDrawing = true
        return canvasView
    }
    
    func updateUIView(_ uiView: PKCanvasView, context: Context) {}
}

