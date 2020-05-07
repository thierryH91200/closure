//
//  DynamicKey.swift
//  
//
//  Created by Eugene Rysaj on 05.03.2020.
//

struct DynamicKey: CodingKey {
    var stringValue: String
    var intValue: Int? = nil
    
    init?(intValue: Int) {
        return nil
    }
    
    init?(stringValue: String) {
        self.stringValue = stringValue
    }
}
