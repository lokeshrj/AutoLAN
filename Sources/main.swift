import Cocoa
import Network
import CoreWLAN
import ServiceManagement

class AppDelegate: NSObject, NSApplicationDelegate {
    private var statusItem: NSStatusItem!
    private var monitor: NWPathMonitor!
    private var monitorQueue = DispatchQueue(label: "com.local.AutoLAN.monitor")
    private var ethernetConnected = false

    func applicationDidFinishLaunching(_ notification: Notification) {
        setupStatusItem()
        setupNetworkMonitor()
        setupSleepWakeObservers()
    }

    // MARK: - Menu Bar

    private func setupStatusItem() {
        statusItem = NSStatusBar.system.statusItem(withLength: NSStatusItem.squareLength)
        updateIcon(ethernetActive: false)
        rebuildMenu()
    }

    private func updateIcon(ethernetActive: Bool) {
        let name = ethernetActive ? "cable.connector" : "antenna.radiowaves.left.and.right"
        if let button = statusItem.button {
            button.image = NSImage(systemSymbolName: name, accessibilityDescription: "AutoLAN")
        }
    }

    private func rebuildMenu() {
        let menu = NSMenu()

        let statusTitle = ethernetConnected ? "Ethernet: Connected" : "Ethernet: Disconnected"
        let statusLine = NSMenuItem(title: statusTitle, action: nil, keyEquivalent: "")
        statusLine.isEnabled = false
        menu.addItem(statusLine)

        menu.addItem(.separator())

        let launchItem = NSMenuItem(title: "Launch at Login", action: #selector(toggleLaunchAtLogin(_:)), keyEquivalent: "")
        launchItem.target = self
        if #available(macOS 13.0, *) {
            launchItem.state = SMAppService.mainApp.status == .enabled ? .on : .off
        } else {
            launchItem.isEnabled = false
        }
        menu.addItem(launchItem)

        menu.addItem(.separator())

        let quitItem = NSMenuItem(title: "Quit AutoLAN", action: #selector(NSApplication.terminate(_:)), keyEquivalent: "q")
        menu.addItem(quitItem)

        statusItem.menu = menu
    }

    // MARK: - Network Monitoring

    private func setupNetworkMonitor() {
        monitor = NWPathMonitor(requiredInterfaceType: .wiredEthernet)
        monitor.pathUpdateHandler = { [weak self] path in
            guard let self = self else { return }
            let connected = path.status == .satisfied
            guard connected != self.ethernetConnected else { return }
            self.ethernetConnected = connected
            self.handleEthernetChange(connected: connected)
        }
        monitor.start(queue: monitorQueue)
    }

    private func handleEthernetChange(connected: Bool) {
        if connected {
            setWiFiPower(false)
        } else {
            setWiFiPower(true)
        }
        DispatchQueue.main.async {
            self.updateIcon(ethernetActive: connected)
            self.rebuildMenu()
        }
    }

    // MARK: - WiFi Control

    private func setWiFiPower(_ on: Bool) {
        // Try CoreWLAN first
        if let iface = CWWiFiClient.shared().interface() {
            do {
                try iface.setPower(on)
                return
            } catch {
                NSLog("AutoLAN: CoreWLAN setPower failed: \(error). Falling back to networksetup.")
            }
        }
        // Fallback: networksetup
        let state = on ? "on" : "off"
        let task = Process()
        task.executableURL = URL(fileURLWithPath: "/usr/sbin/networksetup")
        task.arguments = ["-setairportpower", "en0", state]
        do {
            try task.run()
            task.waitUntilExit()
            if task.terminationStatus != 0 {
                NSLog("AutoLAN: networksetup exited with status \(task.terminationStatus)")
            }
        } catch {
            NSLog("AutoLAN: networksetup launch failed: \(error)")
        }
    }

    // MARK: - Sleep / Wake

    private func setupSleepWakeObservers() {
        NSWorkspace.shared.notificationCenter.addObserver(
            self,
            selector: #selector(handleWake(_:)),
            name: NSWorkspace.didWakeNotification,
            object: nil
        )
    }

    @objc private func handleWake(_ notification: Notification) {
        // Delay to let network interfaces reinitialize
        DispatchQueue.global().asyncAfter(deadline: .now() + 3.0) { [weak self] in
            guard let self = self else { return }
            let connected = self.monitor.currentPath.status == .satisfied
            self.ethernetConnected = connected
            self.handleEthernetChange(connected: connected)
        }
    }

    // MARK: - Launch at Login

    @objc private func toggleLaunchAtLogin(_ sender: NSMenuItem) {
        if #available(macOS 13.0, *) {
            do {
                if SMAppService.mainApp.status == .enabled {
                    try SMAppService.mainApp.unregister()
                } else {
                    try SMAppService.mainApp.register()
                }
            } catch {
                NSLog("AutoLAN: Launch at Login toggle failed: \(error)")
            }
            rebuildMenu()
        }
    }
}

// MARK: - Entry Point

let app = NSApplication.shared
app.setActivationPolicy(.accessory)

let delegate = AppDelegate()
app.delegate = delegate
app.run()
