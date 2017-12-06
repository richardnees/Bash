import Foundation

public let BashXPCProtocolName = "com.richardnees.xpc.BashService"

@objc public protocol BashXPCProtocol {
    func run(command: String, arguments: [String], withReply: @escaping (String?) -> Void)
    func run(command: String, arguments: [String], workingDirectory: String?, withReply: @escaping (String?) -> Void)
    func run(command: String, arguments: [String], workingDirectory: String?, environment: [String:String]?, withReply: @escaping (String?) -> Void)
}
