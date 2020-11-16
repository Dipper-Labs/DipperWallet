//
//  Fee.swift
//  Cosmostation
//
//  Created by yongjoo on 25/03/2019.
//  Copyright © 2019 wannabit. All rights reserved.
//

import Foundation

public struct Fee: Codable{
    var gas: String = ""
    var amount: Array<Coin> = Array<Coin>()
    
    init() {}
    
    init(_ dictionary: [String: Any]) {
        self.gas = dictionary["gas"] as? String ?? ""
        self.amount.removeAll()
        if let rawAmounts = dictionary["amount"] as? Array<NSDictionary>  {
            for amount in rawAmounts {
                self.amount.append(Coin(amount as! [String : Any]))
            }
        }
    }
    
    init(_ gas:String, _ amount:Array<Coin>) {
        self.gas = gas
        self.amount = amount
    }
}
