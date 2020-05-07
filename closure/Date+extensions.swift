//
//  Date+extensions.swift
//  Pods
//
//  Created by Sourav Chandra on 20/11/18.
//

import Foundation

extension Date {
    static func fromTimeSeries(_ string: String) throws -> Date {
        let formatter = DateFormatter()
        formatter.dateFormat = "yyyy-MM-dd" // H:mm:ss"
        let date = formatter.date(from: string) //else {  print( "Could not parse the date \(string)") }
        return date!
    }
}
