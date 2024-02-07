import Cocoa

class AppTracker: NSObject {
    var lastActive: String?
    var timer: Timer?

    override init() {
        super.init()
        setupNotificationListeners()
        startTrackingActiveApplications()
    }

    func setupNotificationListeners() {
        let notificationCenter = DistributedNotificationCenter.default()
        notificationCenter.addObserver(self, selector: #selector(screenIsLocked), name: NSNotification.Name("com.apple.screenIsLocked"), object: nil)
        notificationCenter.addObserver(self, selector: #selector(screenIsUnlocked), name: NSNotification.Name("com.apple.screenIsUnlocked"), object: nil)
        notificationCenter.addObserver(self, selector: #selector(screensaverDidStart), name: NSNotification.Name("com.apple.screensaver.didstart"), object: nil)
        notificationCenter.addObserver(self, selector: #selector(screensaverWillStop), name: NSNotification.Name("com.apple.screensaver.willstop"), object: nil)
        notificationCenter.addObserver(self, selector: #selector(screensaverDidStop), name: NSNotification.Name("com.apple.screensaver.didstop"), object: nil)
    }

    func startTrackingActiveApplications() {
        timer = Timer.scheduledTimer(withTimeInterval: 2.0, repeats: true) { [weak self] _ in
            self?.trackActiveApplication()
        }
    }

    func trackActiveApplication() {
        let script = """
        tell application "System Events"
            set frontApp to name of first application process whose frontmost is true
            set frontAppTitle to ""
            try
                tell application process frontApp
                    if exists first window then
                        set firstWindow to first window
                        set frontAppTitle to name of firstWindow
                    end if
                end tell
                return frontApp & "," & frontAppTitle
            on error
                return "Screen Locked"
            end try
        end tell
        """

        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "yyyy-MM-dd HH:mm:ss"
        let date = dateFormatter.string(from: Date())
        var error: NSDictionary?
        if let scriptObject = NSAppleScript(source: script) {
            let output: NSAppleEventDescriptor = scriptObject.executeAndReturnError(&error)
            let active: String? = output.stringValue
            
            if lastActive != active {
                
                if let activeUnwrapped = active {
                    print("\(date),\(activeUnwrapped)")
                } else {
                    print("\(date),None")
                }
                lastActive = active
            }
        } else if let error = error {
            print("\(date),error,\(error)")
        }
    }

    @objc func screenIsLocked(notification: Notification) {
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "yyyy-MM-dd HH:mm:ss"
        let date = dateFormatter.string(from: Date())
        print("\(date),screen locked")
    }
    
    @objc func screenIsUnlocked(notification: Notification) {
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "yyyy-MM-dd HH:mm:ss"
        let date = dateFormatter.string(from: Date())
        print("\(date),screen unlocked")
    }
    
    @objc func screensaverDidStart(notification: Notification) {
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "yyyy-MM-dd HH:mm:ss"
        let date = dateFormatter.string(from: Date())
        print("\(date),screensaver started")
    }
    
    @objc func screensaverWillStop(notification: Notification) {
        // let dateFormatter = DateFormatter()
        // dateFormatter.dateFormat = "yyyy-MM-dd HH:mm:ss"
        // let date = dateFormatter.string(from: Date())
        // print("\(date),screensaver will stop")
    }
    
    @objc func screensaverDidStop(notification: Notification) {
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "yyyy-MM-dd HH:mm:ss"
        let date = dateFormatter.string(from: Date())
        print("\(date),screensaver stopped")
    }
}

// Main
let appTracker = AppTracker()
RunLoop.current.run()
