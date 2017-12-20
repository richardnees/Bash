import Cocoa

class WindowController: NSWindowController {

    override func windowDidLoad() {
        super.windowDidLoad()
    
        guard let window = window else { return }

        window.appearance = NSAppearance(named: .vibrantDark)
        window.isMovableByWindowBackground = true
    }
}
