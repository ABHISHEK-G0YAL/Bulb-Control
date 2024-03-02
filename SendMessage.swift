import Network

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
