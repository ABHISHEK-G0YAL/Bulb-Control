import SwiftUI

struct OnOffToggle: View {
    @State private var isOn: Bool = false;
    
    var body: some View {
        Toggle(isOn: $isOn) {
            Text("Turn \(isOn ? "Off" : "On")")
        }
        .padding()
        .onChange(of: isOn) { _ in
            sendMessage(opPrefix.power.rawValue + (isOn ? "1" : "0"))
        }
    }
}
