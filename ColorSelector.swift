import SwiftUI

struct ColorSelector: View {
    @State private var selectedColor: Color = .red
    
    private func getRGBValues(_ color: Color) -> String {
        let ciColor = CIColor(color: UIColor(color))
        let redValue = String(format: "%03d", Int(ciColor.red * 255))
        let greenValue = String(format: "%03d", Int(ciColor.green * 255))
        let blueValue = String(format: "%03d", Int(ciColor.blue * 255))
        return redValue + greenValue + blueValue
    }
    
    var body: some View {
        ColorPicker(
            "Choose Color",
            selection: $selectedColor,
            supportsOpacity: false
        )
        .padding()
        .onChange(of: selectedColor) { _ in
            debounceTimer?.invalidate()
            debounceTimer = Timer.scheduledTimer(withTimeInterval: 0.4, repeats: false) { _ in
                sendMessage(opPrefix.color.rawValue + getRGBValues(selectedColor))
            }
        }
    }
}
