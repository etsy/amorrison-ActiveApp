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
        notificationCenter.addObserver(self, selector: #selector(screensaverDidStop), name: NSNotification.Name("com.apple.screensaver.didstop"), object: nil)
        notificationCenter.addObserver(self, selector: #selector(systemWillSleep), name: NSNotification.Name("com.apple.systemWillSleep"), object: nil)
        notificationCenter.addObserver(self, selector: #selector(systemWillPowerOn), name: NSNotification.Name("com.apple.systemWillPowerOn"), object: nil)
        notificationCenter.addObserver(self, selector: #selector(systemDidWake), name: NSNotification.Name("com.apple.systemDidWake"), object: nil)
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
                        if exists (first window whose name is not "") then
                            set frontAppTitle to name of (first window whose name is not "")
                        else if exists windows then
                            set frontAppTitle to "Untitled"
                        end if
                    end tell
                    return frontApp & "," & frontAppTitle
                on error
                    return "Screen Locked"
                end try
            end tell
        """

        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "yyyy-MM-dd HH:mmss"
        let date = dateFormatter.string(from: Date())
        var error: NSDictionary?
        if let scriptObject = NSAppleScript(source: script) {
            let output: NSAppleEventDescriptor = scriptObject.executeAndReturnError(&error)
            let active: String? = output.stringValue
            
            if lastActive == nil || lastActive != active {
                if let activeUnwrapped = active {
                    print("\(date),\(activeUnwrapped)")
                } else {
                    print("\(date),None")
                }
            }
            lastActive = active
        } else if let error = error {
            print("\(date),error,\(error)")
        }
        fflush(stdout)
    }

    @objc func screenIsLocked(notification: Notification) {
        logEvent("screen locked")
    }

    @objc func screenIsUnlocked(notification: Notification) {
        logEvent("screen unlocked")
    }
    
    @objc func screensaverDidStart(notification: Notification) {
        logEvent("screensaver start")
    }
    
    @objc func screensaverDidStop(notification: Notification) {
        logEvent("screensaver did stop")
    }

    @objc func systemWillSleep(notification: Notification) {
        logEvent("system will sleep")
    }

    @objc func systemWillPowerOn(notification: Notification) {
        logEvent("system will power on")
    }

    @objc func systemDidWake(notification: Notification) {
        logEvent("system did wake")
    }

    func logEvent(_ event: String) {
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "yyyy-MM-dd HH:mm:ss"
        let date = dateFormatter.string(from: Date())
        print("\(date),\(event)")
    }
}

// Main
let appTracker = AppTracker()
RunLoop.current.run()
