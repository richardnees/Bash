import Foundation

public struct BashServiceProxy {
    public let errorHandler: ((Error) -> Void)
    public let service: BashXPCProtocol
    let xpcConnection = NSXPCConnection(serviceName: BashXPCProtocolName)

    public init?(errorHandler: @escaping ((Error) -> Void)) {
        self.errorHandler = errorHandler
        
        xpcConnection.remoteObjectInterface = NSXPCInterface(with: BashXPCProtocol.self)
        xpcConnection.resume()
        
        xpcConnection.interruptionHandler = {
            print("Connection to Service \(BashXPCProtocolName) was interrupted")
        }
        
        xpcConnection.invalidationHandler = {
            print("Connection to Service \(BashXPCProtocolName) was invalidated")
        }
        
        guard let remoteService = xpcConnection.remoteObjectProxyWithErrorHandler(errorHandler) as? BashXPCProtocol else {
            assertionFailure()
            return nil
        }
        
        service = remoteService
    }
    
    public static var isSupported: Bool {
        return false
    }
}
