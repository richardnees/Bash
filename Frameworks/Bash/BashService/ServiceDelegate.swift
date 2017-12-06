import Foundation

class ServiceDelegate: NSObject {
}

extension ServiceDelegate: NSXPCListenerDelegate {
    func listener(_ listener: NSXPCListener, shouldAcceptNewConnection newConnection: NSXPCConnection) -> Bool {
        let exportedInterface = NSXPCInterface(with: BashXPCProtocol.self)
        newConnection.exportedInterface = exportedInterface

        let exportedObject = BashService()
        newConnection.exportedObject = exportedObject
        newConnection.resume()
        
        return true
    }
}
