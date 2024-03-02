import SwiftUI

var debounceTimer: Timer? = nil;

enum opPrefix: String {
    case power = "0001xx09xxx"
    case color = "0001xx01"
    case brightness = "0001xx07"
    case temperature = "0001xx10"
}

struct ContentView: View {
    var body: some View {
        VStack {
            OnOffToggle()
            ColorSelector()
            BrightnessSlider()
            Spacer()
        }
    }
}
