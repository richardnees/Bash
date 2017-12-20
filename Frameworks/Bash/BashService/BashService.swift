import Foundation

class BashService: NSObject {
}

extension BashService: BashXPCProtocol {
    func run(command: String, arguments: [String], withReply: @escaping (String?) -> Void) {
        let reply = Bash.sync(command: command, arguments: arguments)
        withReply(reply)
    }
    
    func run(command: String, arguments: [String], workingDirectory: String?, withReply: @escaping (String?) -> Void) {
        let reply = Bash.sync(command: command, arguments: arguments, workingDirectory: workingDirectory)
        withReply(reply)
    }
    
    func run(command: String, arguments: [String], workingDirectory: String?, environment: [String : String]?, withReply: @escaping (String?) -> Void) {
        let reply = Bash.sync(command: command, arguments: arguments, workingDirectory: workingDirectory, environment: environment)
        withReply(reply)
    }
}
