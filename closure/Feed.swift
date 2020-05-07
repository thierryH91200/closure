import Foundation

public struct TimeSeriesRs {
    var meta: Meta
    var rows: Dictionary<Date, Row>;
    
    private enum CodingKeys: String, CodingKey {
        case meta = "Meta Data"
        case rows = "Time Series (Daily)"
    }
    
    public struct Meta {
        var information: String
        var symbol: String
        var lastRefreshed: Date
        var outputSize: String
        var timeZone: String
        
        private enum CodingKeys: String, CodingKey {
            case information = "1. Information"
            case symbol = "2. Symbol"
            case lastRefreshed = "3. Last Refreshed"
            case outputSize = "4. Output Size"
            case timeZone = "5. Time Zone"
        }
    }
    
    public struct Row : Codable {
        var open: String
        var high: String
        var low: String
        var close: String
        var volume: String
        
        private enum CodingKeys: String, CodingKey {
            case open = "1. open"
            case high = "2. high"
            case low = "3. low"
            case close = "4. close"
            case volume = "5. volume"
        }
    }
}

extension TimeSeriesRs.Meta : Decodable {
    public init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        let information = try container.decode(String.self, forKey: .information)
        let symbol = try container.decode(String.self, forKey: .symbol)
        let lastRefreshedString = try container.decode(String.self, forKey: .lastRefreshed)
        let outputSize = try container.decode(String.self, forKey: .outputSize)
        let timeZone = try container.decode(String.self, forKey: .timeZone)
        //    let lastRefreshed = try Date.parse(from: lastRefreshedString)
        let lastRefreshed = try Date.fromTimeSeries(lastRefreshedString)
//        let lastRefreshed = Date()
        
        self.init(information: information, symbol: symbol, lastRefreshed: lastRefreshed, outputSize: outputSize, timeZone: timeZone)
    }
}

extension TimeSeriesRs : Decodable {
    public init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        let meta = try container.decode(Meta.self, forKey: .meta)
        let rowsContainer = try container.nestedContainer(keyedBy: DynamicKey.self, forKey: .rows)
        var rows = Dictionary<Date, Row>()
        try rowsContainer.allKeys.forEach { key in
            let date = try Date.fromTimeSeries(key.stringValue)
            //      let date = try Date.parse(from: key.stringValue)
            let row = try rowsContainer.decode(Row.self, forKey: key)
            rows[date] = row
        }
        self.init(meta: meta, rows: rows)
    }
}

//struct searchEndPoint : Codable {
    
public struct Search  {
    var symbol: String
    var name: String
    var type: String
    var region: String
    var marketOpen: String
    var marketClose: String
    var timezone: String
    var currency: String
    var matchScore: String
    
    private enum CodingKeys: String, CodingKey {
        case symbol = "1. symbol"
        case name = "2. name"
        case type = "3. type"
        case region = "4. region"
        case marketOpen = "5. marketOpen"
        case marketClose = "6. marketClose"
        case timezone = "7. timezone"
        case currency = "8. currency"
        case matchScore = "9. matchScore"
    }
}

public struct Searchs : Decodable {
    
    var meta: [Search]
    
    private enum CodingKeys: String, CodingKey {
        case meta = "bestMatches"
    }
}

extension Search : Decodable {
    public init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        let symbol = try container.decode(String.self, forKey: .symbol)
        let name = try container.decode(String.self, forKey: .name)
        let type = try container.decode(String.self, forKey: .type)
        let region = try container.decode(String.self, forKey: .region)
        let marketOpen = try container.decode(String.self, forKey: .marketOpen)
        let marketClose = try container.decode(String.self, forKey: .marketClose)
        let timezone = try container.decode(String.self, forKey: .timezone)
        let currency = try container.decode(String.self, forKey: .currency)
        let matchScore = try container.decode(String.self, forKey: .matchScore)

        self.init(symbol: symbol, name: name, type: type, region:region, marketOpen:marketOpen, marketClose:marketClose,timezone: timezone,currency:currency, matchScore:matchScore)
    }
}

extension CGFloat {
    
    init?(string: String) {
        guard let number = NumberFormatter().number(from: string) else {
            return nil
        }
        self.init(number.floatValue)
    }
}

