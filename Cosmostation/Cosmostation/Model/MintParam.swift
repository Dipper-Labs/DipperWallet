//
//  MintParam.swift
//  Cosmostation
//
//  Created by 정용주 on 2020/11/03.
//  Copyright © 2020 wannabit. All rights reserved.
//

import Foundation

public struct MintParam: Codable {
    var height: String = ""
    var result: MintParamResult?
    
    init() {}
    
    init(_ dictionary: [String: Any]) {
        self.height = dictionary["height"] as? String ?? ""
        self.result = MintParamResult.init(dictionary["result"] as! [String : Any])
    }
    
    public struct MintParamResult: Codable {
        var mint_denom: String = ""
        var goal_bonded: String = ""
        var blocks_per_year: String = ""
        var inflation_min: String = ""
        var inflation_max: String = ""
        var inflation_rate_change: String = ""
        
        init() {}
        
        init(_ dictionary: [String: Any]) {
            self.mint_denom = dictionary["mint_denom"] as? String ?? ""
            self.goal_bonded = dictionary["goal_bonded"] as? String ?? ""
            self.blocks_per_year = dictionary["blocks_per_year"] as? String ?? ""
            self.inflation_min = dictionary["inflation_min"] as? String ?? ""
            self.inflation_max = dictionary["inflation_max"] as? String ?? ""
            self.inflation_rate_change = dictionary["inflation_rate_change"] as? String ?? ""
        }
    }
}
