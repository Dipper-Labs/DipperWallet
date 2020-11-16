//
//  Signature.swift
//  Cosmostation
//
//  Created by yongjoo on 25/03/2019.
//  Copyright © 2019 wannabit. All rights reserved.
//

import Foundation

public struct Signature: Codable {
    var pub_key: PublicKey = PublicKey.init()
    var signature: String = ""
    var account_number: String = ""
    var sequence: String = ""
    
    init() {}
    
    init(_ dictionary: [String: Any]) {
        self.signature = dictionary["signature"] as? String ?? ""
        self.pub_key = PublicKey.init(dictionary["pub_key"] as! [String : Any])
        self.account_number = dictionary["account_number"] as? String ?? ""
        self.sequence = dictionary["sequence"] as? String ?? ""
    }
}
