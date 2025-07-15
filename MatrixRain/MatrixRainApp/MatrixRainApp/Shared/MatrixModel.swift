import Foundation
import SwiftUI

@MainActor
class MatrixModel: ObservableObject {
    @Published var symbols: [String] = []
    @Published var isRunning = false
    
    private var timer: Timer?
    private let possibleSymbols = "01アイウエオカキクケコサシスセソタチツテトナニヌネノハヒフヘホマミムメモヤユヨラリルレロワヲン"
    
    func start() {
        isRunning = true
        timer = Timer.scheduledTimer(withTimeInterval: 0.1, repeats: true) { [weak self] _ in
            self?.updateSymbols()
        }
    }
    
    func stop() {
        isRunning = false
        timer?.invalidate()
        timer = nil
    }
    
    private func updateSymbols() {
        var newSymbols: [String] = []
        for _ in 0..<50 {
            if let randomChar = possibleSymbols.randomElement() {
                newSymbols.append(String(randomChar))
            }
        }
        symbols = newSymbols
    }
}
