import Cocoa
import Bash

class ViewController: NSViewController {

    @IBOutlet weak var pathControl: NSPathControl!
    @IBOutlet weak var chooseButton: NSButton!
    @IBOutlet var textView: NSTextView!
    
    var bashProxy: BashServiceProxy?
    
    override func viewWillAppear() {
        super.viewWillAppear()

        guard let window = view.window else {
            assertionFailure("Where is our window?")
            return
        }

        guard BashServiceProxy.isSupported else {
            return
        }
        
        bashProxy = BashServiceProxy { error in
            let alert = NSAlert(error: error)
            alert.window.appearance = window.appearance
            DispatchQueue.main.async {
                alert.beginSheetModal(for: window) { response in
                    // Ignore
                }
            }
        }
    }
    
    override func viewDidAppear() {
        super.viewDidAppear()
        
        guard let window = view.window else {
            assertionFailure("Where is our window?")
            return
        }

        window.toolbar?.items.forEach { item in
            if let pathControl = item.view as? NSPathControl {
                let url = URL(fileURLWithPath: "/Applications")
                pathControl.delegate = self
                pathControl.url = url
                handle(path: url.path)
                return
            }
        }
    }
    
    @IBAction func choosePath(_ sender: NSPathControl) {
        guard let url = sender.clickedPathItem?.url else {
            assertionFailure("Where is our URL?")
            return
        }
        sender.url = url
        handle(path: url.path)
    }
    
    func handle(path: String) {
        
        let command =  "ls"
        let arguments =  ["-la", path]

        if BashServiceProxy.isSupported {
            bashProxy?.service.run(command: command, arguments: arguments) { (reply) in
                DispatchQueue.main.async {
                    self.textView.string = reply ?? ""
                }
            }
        } else {
            Bash.async(command: command, arguments: arguments) { string in
                DispatchQueue.main.async {
                    self.textView.string = string
                }
            }
        }
        
    }
}

extension ViewController: NSPathControlDelegate {
    func pathControl(_ pathControl: NSPathControl, willDisplay openPanel: NSOpenPanel) {
        openPanel.canChooseDirectories = true
        openPanel.canChooseFiles = false
    }
}
