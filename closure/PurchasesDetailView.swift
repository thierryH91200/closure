//
//  PurchasesDetailView.swift
//  TableDemo
//
//  Created by Gabriel Theodoropoulos.
//  Copyright © 2019 Appcoda. All rights reserved.
//

import AppKit

class PurchasesDetailView: NSView, LoadableView {
    
    // MARK: - IBOutlet Properties
    @IBOutlet weak var sympolLbl: NSTextField!
    @IBOutlet weak var companyLbl: NSTextField!
    @IBOutlet weak var infoLbl: NSTextField!
    
    
    // MARK: - Properties
    var mainView: NSView?
    
    // MARK: - Init
    init() {
        super.init(frame: NSRect.zero)
        
        _ = load(fromNIBNamed: "PurchasesDetailView")
        layer?.backgroundColor = .white
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }
}
