//
//  PraramAutoController.swift
//  closure
//
//  Created by thierry hentic on 03/05/2020.
//  Copyright © 2020 thierry hentic. All rights reserved.
//

import Cocoa
import Charts

class ParamAutoController: NSViewController, NSTextFieldDelegate {
    
    @IBOutlet weak var searchField: AutoCompleteTextField!
    @IBOutlet weak var chartView: LineChartView!
    @IBOutlet weak var tableVIew: NSTableView!
    
    var stockInfoArray = [StockSearchResult]()
    var searchResults: [StockSearchResult] = []

    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do view setup here.
        
        searchField.tableViewDelegate = self
        initGraph()
        
    }
    
    func initGraph() {
        
        chartView.dragEnabled = false
        chartView.setScaleEnabled(true)
        chartView.pinchZoomEnabled = false
        chartView.drawGridBackgroundEnabled = false
        chartView.highlightPerDragEnabled = true
        chartView.noDataText = "No_chart_Data_Available"
        
        chartView.scaleYEnabled = false
        chartView.scaleXEnabled = false
        
        // MARK: xAxis
        let xAxis = chartView.xAxis
        xAxis.labelPosition = .bottom
        xAxis.labelFont = NSFont(name: "HelveticaNeue-Light", size: CGFloat(10.0))!
        xAxis.drawAxisLineEnabled = true
        xAxis.drawGridLinesEnabled = true
        xAxis.drawLimitLinesBehindDataEnabled = true
        xAxis.avoidFirstLastClippingEnabled = false
        xAxis.granularity = 1.0
        xAxis.spaceMin = xAxis.granularity / 5
        xAxis.spaceMax = xAxis.granularity / 5
        xAxis.labelRotationAngle = -45.0
        xAxis.labelTextColor           = .labelColor
        
        // MARK: leftAxis
        let leftAxis = chartView.leftAxis
        leftAxis.labelPosition = .outsideChart
        leftAxis.labelFont = NSFont(name: "HelveticaNeue-Light", size: CGFloat(12.0))!
        leftAxis.drawGridLinesEnabled = true
        leftAxis.granularityEnabled = true
        leftAxis.yOffset = -9.0
        leftAxis.labelTextColor           = .labelColor
        
        // MARK: rightAxis
        chartView.rightAxis.enabled = false
        
        // MARK: legend
        let legend = chartView.legend
        legend.enabled = true
        legend.form = .square
        legend.drawInside = false
        legend.orientation = .horizontal
        legend.verticalAlignment = .bottom
        legend.horizontalAlignment = .left
        
        // MARK: description
        chartView.chartDescription?.enabled = false
    }
    
    func updateChartData(chartPoints : [ChartPoint]) {
        
        guard chartPoints.isEmpty == false  else {
            chartView.data = nil
            chartView.data?.notifyDataChanged()
            chartView.notifyDataSetChanged()
            return }
        
        var values0 = [ChartDataEntry]()
        for i in 0..<chartPoints.count {
            values0.append(ChartDataEntry(x: Double(chartPoints[i].date!.timeIntervalSince1970), y: Double(chartPoints[i].close!)))
        }
        
        let dataSetPointe = setDataSet(values: values0, label: "label", color: #colorLiteral(red: 0.2745098174, green: 0.4862745106, blue: 0.1411764771, alpha: 1) )
        var dataSets = [LineChartDataSet]()
        dataSets.append(dataSetPointe)
        
        let data = LineChartData(dataSets: dataSets)
        data.setValueTextColor ( #colorLiteral(red: 0, green: 0, blue: 0, alpha: 1))
        data.setValueFont ( NSFont(name: "HelveticaNeue-Light", size: CGFloat(9.0))!)
        
        chartView.data = data
    }
    
    func setDataSet (values : [ChartDataEntry], label: String, color : NSColor) -> LineChartDataSet
    {
        var dataSet =  LineChartDataSet()
        
        let pFormatter = NumberFormatter()
        pFormatter.numberStyle = .currency
        pFormatter.maximumFractionDigits = 2
        
        dataSet = LineChartDataSet(entries: values, label: label)
        dataSet.axisDependency = .left
        dataSet.mode = .stepped
        dataSet.valueTextColor = #colorLiteral(red: 0.4745098054, green: 0.8392156959, blue: 0.9764705896, alpha: 1)
        dataSet.lineWidth = 1.5
        
        dataSet.drawCirclesEnabled = false
        dataSet.drawValuesEnabled = true
        dataSet.valueFormatter = DefaultValueFormatter(formatter: pFormatter  )
        
        dataSet.drawFilledEnabled = false //true
        dataSet.fillAlpha = 0.26
        dataSet.fillColor = #colorLiteral(red: 0.2745098174, green: 0.4862745106, blue: 0.1411764771, alpha: 1)
        dataSet.highlightColor = #colorLiteral(red: 0.4513868093, green: 0.9930960536, blue: 1, alpha: 1)
        dataSet.highlightLineWidth = 4.0
        dataSet.drawHorizontalHighlightIndicatorEnabled = false
        dataSet.formSize = 15.0
        dataSet.colors = [color]
        return dataSet
    }
}

extension ParamAutoController : AutoCompleteTableViewDelegate {
    
    func fetchStocksFromSearchTerm(term: String, completion: @escaping ([StockSearchResult], [String]?, Error?) -> ()) {
        
        var stockInfoArray = [StockSearchResult]()
        var result = [String]()
        
        let searchURL = "https://www.alphavantage.co/query?function=SYMBOL_SEARCH&keywords=\(term)&apikey=QO7P95AT6A0S5956"
        let url = URL(string:searchURL)!
        
        let task = URLSession.shared.dataTask(with: url, completionHandler: { data, response, error in
            
            guard let data = data else { return }
            do {
                let jsonString =  NSString(data: data, encoding: String.Encoding.utf8.rawValue)!
                let jsonData = jsonString.data(using: String.Encoding.utf8.rawValue)!
                if jsonString.contains("Thank you for using Alpha Vantage") == true {
                    completion([], [], nil)
                } else {
                    
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
                    
                    for use in stockInfoArray {
                        result.append(use.symbol! + "   " + use.name! )
                    }
                    completion(stockInfoArray, result, nil)
                }
            }
        })
        task.resume()
    }
    
    func textField(_ textField:NSTextField,didSelectItem item: String) {
        
        print(textField.stringValue)
        
        SwiftStockKit.shared.fetchChartPoints(symbol: item, range: .OneDay) { (chartPoints) -> () in
            
//            if let searchResult = chartPoints {
                DispatchQueue.main.async(execute: {() -> Void in
//                    self.searchResults = searchResult
                    self.tableVIew.reloadData()
                })
                
//            }

            
            let sortechartPoints = chartPoints.sorted (by: { $0.date!.timeIntervalSince1970 < $1.date!.timeIntervalSince1970 })
            self.updateChartData(chartPoints: sortechartPoints)
        }
    }
    
}

extension ParamAutoController : NSTableViewDataSource {
    
    func numberOfRows(in tableView: NSTableView) -> Int {
        return searchResults.count
    }
}

extension ParamAutoController: NSTableViewDelegate {
    
    func tableView(_ tableView: NSTableView, viewFor tableColumn: NSTableColumn?, row: Int) -> NSView? {
        //        let currentPurchase = viewModel.purchases[row]
        
        let view = PurchasesDetailView()
        view.sympolLbl.stringValue = searchResults[row].symbol!
        view.companyLbl.stringValue = searchResults[row].name!
        //        view.infoLbl.stringValue = searchResults[row].exchange!
        
        return view
    }
    
    func tableView(_ tableView: NSTableView, heightOfRow row: Int) -> CGFloat {
        return 70.0
    }
}
