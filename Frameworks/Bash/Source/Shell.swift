import Foundation

public struct Shell {
        
    // MARK: Syncronous

    public static func sync(
        launchPath: String,
        arguments: [String],
        workingDirectory: String? = nil,
        environment: [String:String]? = nil) -> String {
        
        let task = Process()
        task.launchPath = launchPath
        task.arguments = arguments
        
        if let workingDirectory = workingDirectory {
            task.currentDirectoryPath = workingDirectory
        }

        if let environment = environment {
            task.environment = environment
        }

        let pipe = Pipe()
        task.standardOutput = pipe
        task.launch()
        
        let data = pipe.fileHandleForReading.readDataToEndOfFile()
        if let output = String(data: data, encoding: String.Encoding.utf8) {
            if output.isEmpty == false {
                let subString = String(output[output.startIndex..<output.index(output.endIndex, offsetBy: -1)])
                return subString
            }
            return output
        }
        return ""
    }
    
    // MARK: Asyncronous

    public static func async(
        launchPath: String,
        arguments: [String],
        workingDirectory: String? = nil,
        environment: [String:String]? = nil,
        progress: @escaping (_ progressString: String) -> (),
        completion: @escaping (_ completionString: String) -> ()) {
        
        DispatchQueue.global(qos: .background).async {
            let task = Process()
            task.launchPath = launchPath
            task.arguments = arguments
            
            if let workingDirectory = workingDirectory {
                task.currentDirectoryPath = workingDirectory
            }
            
            if let environment = environment {
                task.environment = environment
            }

            let pipe = Pipe()
            task.standardOutput = pipe
            task.launch()
            
            let fileHandle = pipe.fileHandleForReading
            var output: String = ""
            
            repeat {
                let data = fileHandle.availableData
                if let string = String(data: data, encoding: String.Encoding.utf8) {
                    output.append(string)
                    DispatchQueue.main.async {
                        progress(string.trimmingCharacters(in: .whitespacesAndNewlines))
                    }
                }
                fileHandle.waitForDataInBackgroundAndNotify()
            } while fileHandle.availableData.count > 0
            
            DispatchQueue.main.async {
                completion(output)
            }
        }
    }
}
