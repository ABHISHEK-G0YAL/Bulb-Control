import SwiftUI
import Network

var debounceTimer: Timer? = nil;

enum opPrefix: String {
    case power = "0001xx09xxx"
    case color = "0001xx01"
    case brightness = "0001xx07"
    case temperature = "0001xx10"
}

func getRGBValues(_ color: Color) -> String {
    let ciColor = CIColor(color: UIColor(color))
    let redValue = String(format: "%03d", Int(ciColor.red * 255))
    let greenValue = String(format: "%03d", Int(ciColor.green * 255))
    let blueValue = String(format: "%03d", Int(ciColor.blue * 255))
    return redValue + greenValue + blueValue
}

struct ContentView: View {
    @State private var isOn: Bool = false;
    @State private var selectedColor: Color = .red
    @State private var brightness: Double = 100

    var body: some View {
        VStack {
            Toggle(isOn: $isOn) {
                Text("Turn \(isOn ? "Off" : "On")")
            }
            .padding()
            .onChange(of: isOn) { _ in
                sendMessage(opPrefix.power.rawValue + (isOn ? "1" : "0"))
            }
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
            Spacer()
        }
    }
}

func sendMessage(_ message: String) {
    let port: NWEndpoint.Port = 80
    let tcp = NWProtocolTCP.Options.init()
    tcp.noDelay = true
    let connection = NWConnection(
        to: NWEndpoint.hostPort(host: "192.168.4.1", port: port),
        using: NWParameters.init(tls: nil, tcp: tcp)
    )
    func sendMSG() {        
        guard let content = message.data(using: .ascii) else {
            print("Error converting message to Data")
            return
        }
        guard connection.state == .ready else {
            print("Connection is not ready to send data")
            return
        }
        connection.send(
            content: content,
            completion: .contentProcessed({ error in
                if let error = error {
                    print("Error sending data: \(error)")
                } else {
                    print("Data was sent to TCP destination: \(message)")
                }
            })
        )
    }
    func receive() {
        connection.receiveMessage { (data, context, isComplete, error) in
            if (isComplete) {
                print("Receive is complete, count bytes: \(data?.count ?? 0)")
                if (data != nil) {
                    //                    let receivedString = String(data: data!, encoding: .utf8)
                    //                    print(receivedString!)
                } else {
                    print("Data == nil")
                }
            }
        }
    }
    connection.stateUpdateHandler = { (newState) in
        switch (newState) {
        case .ready:
            print("Socket State: Ready")
            sendMSG()
            receive()
        default:
            break
        }
    }
    let serialQueue = DispatchQueue(label: "serial.queue");
    connection.start(queue: serialQueue);
}
