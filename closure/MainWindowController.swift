//
//  MainWindowController.swift
//  closure
//
//  Created by thierry hentic on 02/05/2020.
//  Copyright © 2020 thierry hentic. All rights reserved.
//

import AppKit


class MainWindowController: NSWindowController {
    
    @IBOutlet weak var tabView: NSTabView!

    var paramAutoController: ParamAutoController!
    var paramSimpleController: ParamSimpleController!
    var paramStockController: ParamStockController!
    
    override var windowNibName: NSNib.Name? {
        return "MainWindowController"
    }
    
    override func windowDidLoad() {
        super.windowDidLoad()
        
        paramSimpleController = ParamSimpleController()
        paramAutoController = ParamAutoController()
        paramStockController = ParamStockController()

        let autoItem = NSTabViewItem(viewController: paramAutoController)
        autoItem.label = "Auto"
        
        let stockItem = NSTabViewItem(viewController: paramStockController)
        stockItem.label = "Stock"

        let simpleItem = NSTabViewItem(viewController: paramSimpleController)
        simpleItem.label = "Simple"
        
        let items = tabView.tabViewItems
        for item in items {
            tabView.removeTabViewItem(item)
        }

        tabView.addTabViewItem(simpleItem)
        tabView.addTabViewItem(stockItem)
        tabView.addTabViewItem(autoItem)
    }
    
}

