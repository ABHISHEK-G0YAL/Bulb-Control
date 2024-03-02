import SwiftUI

struct TemperatureSlider: View {
    @State private var temperature: Double = 2700
    // Represents the temperature as a color, interpolating between warm and cool white
    private func temperatureColor(_ temperature: Double) -> Color {
        let warmWhite = (red: 1.0, green: 0.9, blue: 0.76) // A warm white approximation
        let coolWhite = (red: 0.925, green: 0.976, blue: 0.99) // A cool white approximation
        
        // Calculate the interpolation factor (0 to 1)
        let factor = (temperature - 2700) / (6500 - 2700)

        // Interpolate between warm and cool white
        return Color(
            red: warmWhite.red + (coolWhite.red - warmWhite.red) * factor,
            green: warmWhite.green + (coolWhite.green - warmWhite.green) * factor,
            blue: warmWhite.blue + (coolWhite.blue - warmWhite.blue) * factor
        )
    }
    
    var body: some View {
        VStack {
            Text("Temperature")
                .font(.system(size: 17, weight: .regular))
                .foregroundColor(.secondary) 
                .frame(maxWidth: .infinity, alignment: .leading)
            HStack {
                Slider(value: $temperature, in: 2700...6500, step: 100)
                .onChange(of: temperature) { _ in
                    debounceTimer?.invalidate()
                    debounceTimer = Timer.scheduledTimer(withTimeInterval: 0.4, repeats: false) { _ in
                        sendMessage(opPrefix.temperature.rawValue + String(Int(temperature)))
                    }
                }
                
                // Display the current temperature and color
                VStack(spacing: 10) {
                    Circle()
                        .fill(temperatureColor(temperature))
                        .frame(width: 30, height: 30)
                        .shadow(radius: 3)
                    Text("\(Int(temperature))K")
                        .font(.caption2)
                }
            }
        }
        .padding()
    }
}
