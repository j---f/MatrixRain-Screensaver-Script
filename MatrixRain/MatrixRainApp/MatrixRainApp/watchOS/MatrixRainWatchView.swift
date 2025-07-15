import SwiftUI
import WatchKit

struct MatrixRainWatchView: View {
    @StateObject private var matrixModel = MatrixModel()
    
    var body: some View {
        ScrollView {
            LazyVGrid(columns: Array(repeating: GridItem(.flexible()), count: 5), spacing: 2) {
                ForEach(matrixModel.symbols.prefix(25), id: \.self) { symbol in
                    Text(symbol)
                        .font(.system(size: 14, design: .monospaced))
                        .foregroundColor(.green)
                }
            }
            .padding()
            
            Button(action: {
                if matrixModel.isRunning {
                    matrixModel.stop()
                } else {
                    matrixModel.start()
                }
            }) {
                Text(matrixModel.isRunning ? "Stop" : "Start")
                    .font(.headline)
                    .foregroundColor(.white)
                    .padding()
                    .background(matrixModel.isRunning ? Color.red : Color.green)
                    .cornerRadius(8)
            }
        }
        .onAppear {
            matrixModel.start()
        }
        .onDisappear {
            matrixModel.stop()
        }
        .edgesIgnoringSafeArea(.bottom)
    }
}

#Preview {
    MatrixRainWatchView()
}
