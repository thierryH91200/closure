//
//  AutoCompleteTextField.swift
//  AutoCompleteTextFieldDemo
//
//  Created by fancymax on 15/12/12.
//  Copyright © 2015年 fancy. All rights reserved.
//

import AppKit

@objc protocol AutoCompleteTableViewDelegate:NSObjectProtocol{
//    func textField(_ textField:NSTextField,completions words:[String],forPartialWordRange charRange:NSRange,indexOfSelectedItem index:Int) ->[String]
    @objc optional func textField(_ textField:NSTextField,didSelectItem item: String)
    
    func fetchStocksFromSearchTerm(term: String, completion:@escaping(_ stock : [StockSearchResult], _ stockInfoArray: [String]?, Error?) -> ())
}

class AutoCompleteTableRowView:NSTableRowView{
    override func drawSelection(in dirtyRect: NSRect) {
        if self.selectionHighlightStyle != .none{
            let selectionRect = NSInsetRect(self.bounds, 0.5, 0.5)
            NSColor.selectedMenuItemColor.setStroke()
            NSColor.selectedMenuItemColor.setFill()
            let selectionPath = NSBezierPath(roundedRect: selectionRect, xRadius: 0.0, yRadius: 0.0)
            selectionPath.fill()
            selectionPath.stroke()
        }
    }
    
    override var interiorBackgroundStyle:NSView.BackgroundStyle {
        get{
            if self.isSelected {
                return NSView.BackgroundStyle.dark
            }
            else{
                return NSView.BackgroundStyle.light
            }
        }
    }
}

class AutoCompleteTextField:NSTextField{
    @IBInspectable var popOverWidth:CGFloat = 100.0
    
    weak var tableViewDelegate:AutoCompleteTableViewDelegate?
    let popOverPadding:CGFloat = 0.0
    let maxResults = 10
    
    var autoCompletePopover:NSPopover?
    weak var autoCompleteTableView:NSTableView?
    var matches:[String]?
    
    override func awakeFromNib() {
        let column1 = NSTableColumn(identifier: NSUserInterfaceItemIdentifier(rawValue: "text"))
        column1.isEditable = false
        column1.width = popOverWidth - 2 * popOverPadding
        
        let tableView = NSTableView(frame: NSZeroRect)
        tableView.selectionHighlightStyle = NSTableView.SelectionHighlightStyle.regular
        tableView.backgroundColor = NSColor.clear
        tableView.rowSizeStyle = NSTableView.RowSizeStyle.small
        tableView.intercellSpacing = NSSize(width: 10.0, height: 0.0)
        tableView.headerView = nil
        tableView.refusesFirstResponder = true
        tableView.target = self
        tableView.doubleAction = #selector(insert(_:))
        tableView.addTableColumn(column1)
        tableView.delegate = self
        tableView.dataSource = self
        self.autoCompleteTableView = tableView
        
        let tableSrollView = NSScrollView(frame: NSZeroRect)
        tableSrollView.drawsBackground = false
        tableSrollView.documentView = tableView
        tableSrollView.hasVerticalScroller = true
        
        // see issue #1, popover throws when contentView's height=0, CoreGraphics bug?
        let contentView:NSView = NSView(frame: NSRect.init(x: 0, y: 0, width: popOverWidth, height: 1))
        contentView.addSubview(tableSrollView)
        
        let contentViewController = NSViewController()
        contentViewController.view = contentView
        
        self.autoCompletePopover = NSPopover()
        self.autoCompletePopover?.appearance = NSAppearance(named: NSAppearance.Name.vibrantLight)
        self.autoCompletePopover?.animates = false
        self.autoCompletePopover?.contentViewController = contentViewController
        self.autoCompletePopover?.delegate = self
        
        self.matches = [String]()
    }
    
    override func keyUp(with theEvent: NSEvent) {
        let row:Int = self.autoCompleteTableView!.selectedRow
        let isShow = self.autoCompletePopover!.isShown
        switch(theEvent.keyCode){
            
        case 125: //Down
            if isShow{
                self.autoCompleteTableView?.selectRowIndexes(IndexSet(integer: row + 1), byExtendingSelection: false)
                self.autoCompleteTableView?.scrollRowToVisible((self.autoCompleteTableView?.selectedRow)!)
                return //skip default behavior
            }
            
        case 126: //Up
            if isShow{
                self.autoCompleteTableView?.selectRowIndexes(IndexSet(integer: row - 1), byExtendingSelection: false)
                self.autoCompleteTableView?.scrollRowToVisible((self.autoCompleteTableView?.selectedRow)!)
                return //skip default behavior
            }
            
        case 36: // Return
            if isShow{
                self.insert(self)
            }
            return //skip default behavior
            
        case 48: //Tab
            if isShow{
                self.insert(self)
            }
            return
            
        case 49: //Space
            if isShow {
                self.insert(self)
            }
            return
            
        default:
            break
        }
        
        super.keyUp(with: theEvent)
        self.complete(self)
    }
    
    @objc func insert(_ sender: Any){
        let selectedRow = self.autoCompleteTableView!.selectedRow
        let matchCount = self.matches!.count
        if selectedRow >= 0 && selectedRow < matchCount{
            self.stringValue = self.matches![selectedRow]
            self.stringValue = self.matches![selectedRow]
            if self.tableViewDelegate!.responds(to: #selector(AutoCompleteTableViewDelegate.textField(_:didSelectItem:))){
                self.tableViewDelegate!.textField!(self,didSelectItem: self.stringValue)
            }
        }
        self.autoCompletePopover?.close()
    }
    
    override func complete(_ sender: Any?) {
        let lengthOfWord = self.stringValue.count
        let subStringRange = NSRange(location: 0, length: lengthOfWord)
        
        //This happens when we just started a new word or if we have already typed the entire word
        if subStringRange.length == 0 || lengthOfWord == 0 {
            self.autoCompletePopover?.close()
            return
        }
        let term = stringValue
        tableViewDelegate!.fetchStocksFromSearchTerm(term: term, completion: { stock, user, error in
            
            if let user = user {
                DispatchQueue.main.async(execute: {() -> Void in
                    
                    self.matches = user
                                        
                    let index = 0
                    if self.matches!.count > 0 {
                        self.autoCompleteTableView?.reloadData()
                        self.autoCompleteTableView?.selectRowIndexes(IndexSet(integer: index), byExtendingSelection: false)
                        self.autoCompleteTableView?.scrollRowToVisible(index)
                        
                        let rect = self.visibleRect
                        self.autoCompletePopover?.show(relativeTo: rect, of: self, preferredEdge: NSRectEdge.maxY)
                    }
                    else {
                        self.autoCompletePopover?.close()
                    }
                })
            }
        })
    }
        
    func completionsForPartialWordRange(_ charRange: NSRange, indexOfSelectedItem index: Int) ->[String]{
        return []
    }
}

// MARK: - NSPopoverDelegate
extension AutoCompleteTextField: NSPopoverDelegate{
    
    // caclulate contentSize only before it will show, to make it more stable
    func popoverWillShow(_ notification: Notification) {
        
        let numberOfRows = min(self.autoCompleteTableView!.numberOfRows, maxResults)
        let height = (self.autoCompleteTableView!.rowHeight + self.autoCompleteTableView!.intercellSpacing.height) * CGFloat(numberOfRows) + 2 * 0.0
        let frame = NSRect(x: 0, y: 0, width: popOverWidth, height: height)
        self.autoCompleteTableView?.enclosingScrollView?.frame = NSInsetRect(frame, popOverPadding, popOverPadding)
        self.autoCompletePopover?.contentSize = NSSize(width: frame.width, height: frame.height)
    }
    
}

// MARK: - NSTableViewDelegate
extension AutoCompleteTextField:NSTableViewDelegate{
    func tableView(_ tableView: NSTableView, rowViewForRow row: Int) -> NSTableRowView? {
        return AutoCompleteTableRowView()
    }
    
    func tableView(_ tableView: NSTableView, viewFor tableColumn: NSTableColumn?, row: Int) -> NSView? {
        var cellView = tableView.makeView(withIdentifier: NSUserInterfaceItemIdentifier(rawValue: "MyView"), owner: self) as? NSTableCellView
        if cellView == nil{
            cellView = NSTableCellView(frame: NSZeroRect)
            let textField = NSTextField(frame: NSZeroRect)
            textField.isBezeled = false
            textField.drawsBackground = false
            textField.isEditable = false
            textField.isSelectable = false
            cellView!.addSubview(textField)
            cellView!.textField = textField
            cellView!.identifier = NSUserInterfaceItemIdentifier(rawValue: "MyView")
        }
        let attrs = [NSAttributedString.Key.foregroundColor:NSColor.black,NSAttributedString.Key.font:NSFont.systemFont(ofSize: 13)]
        let mutableAttriStr = NSMutableAttributedString(string: self.matches![row], attributes: attrs)
        cellView!.textField!.attributedStringValue = mutableAttriStr
        
        return cellView
    }
}

// MARK: - NSTableViewDataSource
extension AutoCompleteTextField:NSTableViewDataSource{
    func numberOfRows(in tableView: NSTableView) -> Int {
        if self.matches == nil{
            return 0
        }
        return self.matches!.count
    }
}
