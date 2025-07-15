import SwiftUI

struct MatrixRainView: View {
    @StateObject private var matrixModel = MatrixModel()
    
    var body: some View {
        ZStack {
            Color.black.edgesIgnoringSafeArea(.all)
            
            VStack(spacing: 20) {
                Text("Matrix Rain")
                    .font(.largeTitle)
                    .foregroundColor(.green)
                
                ScrollView {
                    LazyVGrid(columns: Array(repeating: GridItem(.flexible()), count: 10), spacing: 10) {
                        ForEach(matrixModel.symbols, id: \.self) { symbol in
                            Text(symbol)
                                .font(.system(size: 20, design: .monospaced))
                                .foregroundColor(.green)
                        }
                    }
                    .padding()
                }
                
                Button(action: {
                    if matrixModel.isRunning {
                        matrixModel.stop()
                    } else {
                        matrixModel.start()
                    }
                }) {
                    Text(matrixModel.isRunning ? "Stop" : "Start")
                        .font(.title2)
                        .foregroundColor(.white)
                        .padding()
                        .background(matrixModel.isRunning ? Color.red : Color.green)
                        .cornerRadius(10)
                }
            }
            .padding()
        }
        .onAppear {
            matrixModel.start()
        }
        .onDisappear {
            matrixModel.stop()
        }
    }
}

#Preview {
    MatrixRainView()
}
