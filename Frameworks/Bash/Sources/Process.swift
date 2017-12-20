import Foundation

extension Process {
        
    // MARK: Syncronous

    public func sync(
        launchPath: String,
        arguments: [String],
        workingDirectory: String? = nil,
        environment: [String:String]? = nil) -> String {
        
        self.launchPath = launchPath
        self.arguments = arguments
        
        if let workingDirectory = workingDirectory {
            currentDirectoryPath = workingDirectory
        }

        if let environment = environment {
            self.environment = environment
        }

        let pipe = Pipe()
        standardOutput = pipe
        launch()
        
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

    public func async(
        launchPath: String,
        arguments: [String],
        workingDirectory: String? = nil,
        environment: [String:String]? = nil,
        progress: @escaping (_ progressString: String) -> (),
        completion: @escaping (_ completionString: String) -> ()) {
        
        DispatchQueue.global(qos: .background).async {

            self.launchPath = launchPath
            self.arguments = arguments
            
            if let workingDirectory = workingDirectory {
                self.currentDirectoryPath = workingDirectory
            }
            
            if let environment = environment {
                self.environment = environment
            }

            let pipe = Pipe()
            self.standardOutput = pipe
            self.launch()
            
            var output: String = ""
            let handle = pipe.fileHandleForReading

            handle.readabilityHandler = { pipe in
                if let string = String(data: pipe.availableData, encoding: String.Encoding.utf8) {
                    output.append(string)
                    DispatchQueue.main.async {
                        progress(string.trimmingCharacters(in: .whitespacesAndNewlines))
                    }
                }
            }
            
            self.terminationHandler = { _ in
                handle.readabilityHandler = nil
            }
            
            DispatchQueue.main.async {
                completion(output)
            }
        }
    }
}
