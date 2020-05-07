

import AppKit
import Alamofire

class StockSearchResult : NSObject {
    var symbol: String?
    var name: String?
    var type: String?
    var region: String?
    var marketOpen: String?
    var marketClose: String?
    var timezone: String?
    var currency: String?
    var matchScore: String?
    
    init(symbol : String, name: String, type: String, region : String, marketOpen : String, marketClose : String, timezone : String, currency : String, matchScore : String ) {
        self.symbol      = symbol
        self.name        = name
        self.type        = type
        self.region      = type
        self.marketOpen  = marketOpen
        self.marketClose = marketClose
        self.timezone    = timezone
        self.currency    = currency
        self.matchScore  = matchScore
    }
}

struct ChartPoint {
    var date: Date?
    var volume: Int?
    var open: CGFloat?
    var close: CGFloat?
    var low: CGFloat?
    var high: CGFloat?
}

enum ChartTimeRange {
    case OneDay, FiveDays, TenDays, OneMonth, ThreeMonths, OneYear, FiveYears
}


class SwiftStockKit {
    
    static let shared = SwiftStockKit()
    
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
    
    func fetchChartPoints( symbol: String, range: ChartTimeRange, completion:@escaping(_ chartPoints: [ChartPoint]) -> ()) {
        
        var chartPoints = [ChartPoint]()
        
        let chartURL = chartUrlForRange(symbol: symbol, range: range)
        AF.request(chartURL).responseData { response in
            
            if let data = response.value {
                
                let jsonString =  NSString(data: data, encoding: String.Encoding.utf8.rawValue)!
                let jsonData = jsonString.data(using: String.Encoding.utf8.rawValue)!
                
                if jsonString.contains("Thank you for using Alpha Vantage") == true {
                    completion(chartPoints)
                } else {
                    let user = try! JSONDecoder().decode(TimeSeriesRs.self, from: jsonData)
                    for dataPoint in user.rows {
                        //GMT off by 5 hrs
                        //   let date = Date(timeIntervalSince1970: (dataPoint["Timestamp"] as? Double ?? dataPoint["Date"] as! Double) - 18000.0)
                        chartPoints.append(
                            ChartPoint(
                                date:  dataPoint.key,
                                volume: Int(dataPoint.value.volume ),
                                open: CGFloat(Double(dataPoint.value.open )!),
                                close: CGFloat(Double( dataPoint.value.close)!),
                                low: CGFloat(Double( dataPoint.value.low)!),
                                high: CGFloat(Double( dataPoint.value.high)!)
                            )
                        )
                    }
                    completion(chartPoints)
                }
            }
        }
    }
    
    func chartUrlForRange(symbol: String, range: ChartTimeRange) -> String {
        
        var timeString = String()
        
        switch (range) {
        case .OneDay:
            timeString = "TIME_SERIES_DAILY"
        case .FiveDays:
            timeString = "TIME_SERIES_WEEKLY"
        case .TenDays:
            timeString = "TIME_SERIES_WEEKLY"
        case .OneMonth:
            timeString = "TIME_SERIES_MONTHLY"
        case .ThreeMonths:
            timeString = "TIME_SERIES_MONTHLY"
        case .OneYear:
            timeString = "TIME_SERIES_MONTHLY"
        case .FiveYears:
            timeString = "TIME_SERIES_MONTHLY"
        }
        return "https://www.alphavantage.co/query?function=\(timeString)&symbol=\(symbol)&apikey=QO7P95AT6A0S5956"
    }
}



//extension NSBezierPath {
//
//    public var cgPath: CGPath {
//        let path = CGMutablePath()
//        var points = [CGPoint](repeating: .zero, count: 3)
//
//        for i in 0 ..< self.elementCount {
//            let type = self.element(at: i, associatedPoints: &points)
//            switch type {
//            case .moveTo:
//                path.move(to: points[0])
//            case .lineTo:
//                path.addLine(to: points[0])
//            case .curveTo:
//                path.addCurve(to: points[2], control1: points[0], control2: points[1])
//            case .closePath:
//                path.closeSubpath()
//            @unknown default:
//                fatalError()
//            }
//        }
//        return path
//    }
//}
//
//
//
