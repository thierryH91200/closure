//
//  ParamStockController.swift
//  closure
//
//  Created by thierry hentic on 03/05/2020.
//  Copyright © 2020 thierry hentic. All rights reserved.
//

import Cocoa

class ParamStockController: NSViewController {
    
    @IBOutlet weak var tableView: NSTableView!
    
    var stockInfoArray = [StockSearchResult]()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do view setup here.
        
        stockInfoArray.removeAll()
        tableView.dataSource = self
        tableView.delegate = self
        
        loadData(term: "A")
    }
    
    func loadData(term : String) {
        
        fetchStocksFromSearchTerm(term: term, completion: { user, error in
            
            if let user = user {
                DispatchQueue.main.async(execute: {() -> Void in
                    self.stockInfoArray = user
                    self.tableView.reloadData()
                })
            }
        })
    }
    
    
    func fetchStocksFromSearchTerm(term: String, completion:@escaping(_ stockInfoArray: [StockSearchResult]?, Error?) -> ()) {
        
        var stockInfoArray = [StockSearchResult]()
        
        let searchURL = "https://www.alphavantage.co/query?function=SYMBOL_SEARCH&keywords=\(term)&apikey=QO7P95AT6A0S5956"
        let url = URL(string:searchURL)!
        
        let task = URLSession.shared.dataTask(with: url, completionHandler: { data, response, error in
            
            guard let data = data else { return }
            do {
                let jsonString =  NSString(data: data, encoding: String.Encoding.utf8.rawValue)!
                let jsonData = jsonString.data(using: String.Encoding.utf8.rawValue)!
                
                let user = try! JSONDecoder().decode(Searchs.self, from: jsonData)
                
                for dictionary in user.meta {
                    stockInfoArray.append(StockSearchResult(
                        symbol: dictionary.symbol,
                        name: dictionary.name,
                        type: dictionary.type,
                        region: dictionary.region,
                        marketOpen: dictionary.marketOpen,
                        marketClose: dictionary.marketClose,
                        timezone: dictionary.timezone,
                        currency: dictionary.currency,
                        matchScore: dictionary.matchScore))
                }
                completion(stockInfoArray, nil)
            }
        })
        task.resume()
    }
}

extension ParamStockController: NSTableViewDataSource {
    
    func numberOfRows(in tableView: NSTableView) -> Int {
        return stockInfoArray.count
    }
}

extension ParamStockController: NSTableViewDelegate {
    
    func tableView(_ tableView: NSTableView, viewFor tableColumn: NSTableColumn?, row: Int) -> NSView? {
        
        let identifier = tableColumn!.identifier
        switch identifier {
        case .symbol :
            let result = tableView.makeView(withIdentifier: .symbol, owner: self) as! NSTableCellView
            result.textField?.stringValue = stockInfoArray[row].symbol!
            return result
            
        case .name :
            let result = tableView.makeView(withIdentifier: .name, owner: self) as! NSTableCellView
            result.textField?.stringValue = stockInfoArray[row].name!
            return result
            
        case .type :
            let result = tableView.makeView(withIdentifier: .type, owner: self) as! NSTableCellView
            result.textField?.stringValue = stockInfoArray[row].type!
            return result
            
        case .region :
            let result = tableView.makeView(withIdentifier: .region, owner: self) as! NSTableCellView
            result.textField?.stringValue = stockInfoArray[row].region!
            return result
        default:
            return nil
            
        }
    }
    
}

extension NSUserInterfaceItemIdentifier {
    
    // Stock
    static let symbol       = NSUserInterfaceItemIdentifier("symbol")
    static let name         = NSUserInterfaceItemIdentifier("name")
    static let type         = NSUserInterfaceItemIdentifier("type")
    static let region       = NSUserInterfaceItemIdentifier("region")
    
}


