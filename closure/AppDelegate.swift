//
//  AppDelegate.swift
//  closure
//
//  Created by thierry hentic on 02/05/2020.
//  Copyright © 2020 thierry hentic. All rights reserved.
//

import Cocoa

@NSApplicationMain
class AppDelegate: NSObject, NSApplicationDelegate {

        @IBOutlet weak var window: NSWindow!


        var mainWindowController : MainWindowController?
        
        func applicationDidFinishLaunching(_ aNotification: Notification) {
            // Insert code here to initialize your application
            initializeAndShowMainWindow()
        }
        
        func applicationWillTerminate(_ aNotification: Notification) {
            // Insert code here to tear down your application
        }
        
        
        func applicationShouldTerminateAfterLastWindowClosed (_ sender: NSApplication) -> Bool {
            return true
        }

        func initializeAndShowMainWindow() {
            mainWindowController = MainWindowController()
            mainWindowController?.showWindow(self)
        }



    }

