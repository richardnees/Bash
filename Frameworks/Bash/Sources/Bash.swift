import Foundation

public struct Bash {
    
    static let bashPath = "/bin/bash"
    static func arguments(for command: String) -> [String] {
        return [
            "-l",
            "-c",
            "which \(command)"
        ]
    }

    // MARK: Syncronous
    
    public static func sync(
        command: String,
        arguments: [String],
        workingDirectory: String? = nil,
        environment: [String:String]? = nil) -> String {
        let whichPathForCommand = Process().sync(
            launchPath: bashPath,
            arguments: Bash.arguments(for: command),
            workingDirectory: workingDirectory,
            environment: environment)
        return Process().sync(launchPath: whichPathForCommand, arguments: arguments, workingDirectory: workingDirectory, environment: environment)
    }

    // MARK: Asyncronous

    public static func async(
        command: String,
        arguments: [String],
        workingDirectory: String? = nil,
        environment: [String:String]? = nil,
        progress: ((String) -> ())? = nil,
        completion: @escaping (String) -> ()) {
        
        let whichPathForCommand = Process().sync(launchPath: bashPath, arguments: Bash.arguments(for: command), workingDirectory: workingDirectory, environment: nil)
        
        Process().async(
            launchPath: whichPathForCommand,
            arguments: arguments,
            workingDirectory: workingDirectory,
            environment: environment,
            progress: { string in
                progress?(string)
                
        }) { output in
            completion(output)
        }
    }
}
