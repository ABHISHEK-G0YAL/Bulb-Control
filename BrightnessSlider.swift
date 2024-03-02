import SwiftUI

struct BrightnessSlider: View {
    @State private var brightness: Double = 100
    
    var body: some View {
        Slider(
            value: $brightness,
            in: 0...100,
            step: 1.0
        ) {
            Text("Brightness")
        } minimumValueLabel: {
            Text("0")
        } maximumValueLabel: {
            Text("100")
        }
        .padding()
        .onChange(of: brightness) { _ in
            debounceTimer?.invalidate()
            debounceTimer = Timer.scheduledTimer(withTimeInterval: 0.4, repeats: false) { _ in
                sendMessage(opPrefix.brightness.rawValue + String(format: "%03d", Int(brightness)))
            }
        }
    }
}
