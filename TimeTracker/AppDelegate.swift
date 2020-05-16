//
//  AppDelegate.swift
//  TimeTracker
//
//  Created by Sergey Andronov on 15/05/2020.
//  Copyright © 2020 Sergey Andronov. All rights reserved.
//

import Cocoa

@NSApplicationMain
class AppDelegate: NSObject, NSApplicationDelegate {
    var statusBarItem: NSStatusItem!
    var statusBarMenu: NSMenu!
    var savedSecondsPassed: TimeInterval!
    var startDate: Date!
    var timer: Timer?
    
    let defaults = UserDefaults.standard
    
    func applicationDidFinishLaunching(_ aNotification: Notification) {
        savedSecondsPassed = TimeInterval(defaults.integer(forKey: "savedSecondsPassed"))
        
        statusBarItem = NSStatusBar.system.statusItem(withLength: NSStatusItem.variableLength)
        statusBarItem.button?.imagePosition = .imageLeft
        updateMenuIcon()
        updateMenuTime()
        statusBarItem.button?.action = #selector(self.statusBarButtonClicked(_:))
        statusBarItem.button?.sendAction(on: [.leftMouseUp, .rightMouseUp])
        
        statusBarMenu = NSMenu(title: "Status Bar Menu")
        statusBarMenu.delegate = self
        statusBarMenu.addItem(
           withTitle: "Reset timer",
           action: #selector(self.resetTimer),
           keyEquivalent: "r")
        statusBarMenu.addItem(
           withTitle: "Quit",
           action: #selector(NSApplication.terminate(_:)),
           keyEquivalent: "q")
    }

    func applicationWillTerminate(_ aNotification: Notification) {
        stopTimer()
        defaults.set(savedSecondsPassed, forKey: "savedSecondsPassed")
    }
    
    @objc func statusBarButtonClicked(_ sender: NSStatusBarButton) {
        let event = NSApp.currentEvent!

        if event.type == NSEvent.EventType.rightMouseUp {
            rigthClick()
        } else {
            leftClick()
        }
    }
    
    func leftClick() {
        statusBarItem.menu = nil
        toggleTimer()
    }
    
    func rigthClick() {
        statusBarItem.menu = statusBarMenu
        statusBarItem.button?.performClick(nil)
    }

    private func currentSeconds() -> TimeInterval {
        if startDate == nil { return TimeInterval(0) }
        
        return Date().timeIntervalSince(startDate)
    }
    
    private func saveSeconds() {
        savedSecondsPassed = seconds()
        defaults.set(savedSecondsPassed, forKey: "savedSecondsPassed")
    }
    
    private func seconds() -> TimeInterval {
        return savedSecondsPassed + currentSeconds()
    }
    
    private func toHM(seconds: TimeInterval) -> String {
        let hour = Int(seconds) / 3600
        let minute = Int(seconds) / 60 % 60

        return String(format: "%02i:%02i", hour, minute)
    }
    
    private func toHMS(seconds: TimeInterval) -> String {
        let hour = Int(seconds) / 3600
        let minute = Int(seconds) / 60 % 60
        let second = Int(seconds) % 60

        return String(format: "%02i:%02i:%02i", hour, minute, second)
    }
    
    private func updateMenuTime() {
        statusBarItem.button?.title = toHM(seconds: seconds())
    }
    
    private func updateMenuIcon() {
        let iconImage: NSImage?
        
        if isTimerRunning() {
            iconImage = NSImage(named: "CircleFilledImage")
        } else {
            iconImage = NSImage(named: "CircleBlankImage")
        }
        iconImage?.isTemplate = true
        
        statusBarItem.button?.image = iconImage
    }
}

extension AppDelegate: NSMenuDelegate {
    func menuDidClose(_ menu: NSMenu) {
        statusBarItem.menu = nil // remove menu so button works as before
    }
}

// MARK: Timer
extension AppDelegate {
    func startTimer() {
        if isTimerRunning() { return }
       
        startDate = Date()
        timer = Timer.scheduledTimer(
            timeInterval: 5.0,
            target: self,
            selector: #selector(onTimerUpdate),
            userInfo: nil,
            repeats: true
        )
        timer?.tolerance = 0.5
        updateMenuIcon()
        print("Timer has started")
    }
    
    func stopTimer() {
        timer?.invalidate()
        timer = nil
        
        saveSeconds()
        updateMenuTime()
        startDate = nil
        updateMenuIcon()
        print("Timer has stoped")
    }
    
    func toggleTimer() {
        if isTimerRunning() {
            stopTimer()
        } else {
            startTimer()
        }
    }
    
    @objc func resetTimer() {
        timer?.invalidate()
        timer = nil
        
        savedSecondsPassed = TimeInterval(0)
        startDate = nil
        
        saveSeconds()
        updateMenuTime()
        print("Timer is reseted")
    }
    
    @objc func onTimerUpdate() {
        updateMenuTime()
        print("Tick-tack! seconds: ", toHMS(seconds: seconds()))
    }
    
    private func isTimerRunning() -> Bool {
        return timer != nil
    }
}
