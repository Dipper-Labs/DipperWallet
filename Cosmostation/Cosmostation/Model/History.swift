//
//  History.swift
//  Cosmostation
//
//  Created by yongjoo on 25/03/2019.
//  Copyright © 2019 wannabit. All rights reserved.
//

import Foundation

public class History {
    var hits: Hits = Hits.init()
 
    init() {}
    
    init(_ dictionary: [String: Any]) {
        self.hits = Hits.init(dictionary["hits"] as! [String : Any])
    }
    
    
    public class Hits {
        var total: Int64 = -1
        var hits: Array<InnerHits> = Array<InnerHits>()
        
        init() {}
        
        init(_ dictionary: [String: Any]) {
            self.total = dictionary["total"] as? Int64 ?? -1
            
            self.hits.removeAll()
            if let rawHits = dictionary["hits"] as? Array<NSDictionary> {
                for rawHit in rawHits {
                    self.hits.append(InnerHits(rawHit as! [String : Any]))
                }
            }
        }
    }
    
    public class InnerHits {
        var _source: Source = Source.init()
        
        init() {}
        
        init(_ dictionary: [String: Any]) {
            self._source = Source.init(dictionary["_source"] as! [String : Any])
        }
    }
    
    public class Source {
        var hash: String = ""
        var height: Int64 = -1
        var time: String = ""
        var timestamp: String = ""
        var tx: StdTx = StdTx.init()
        var result: Result = Result.init()
        var log: Data?
        var allResult: Bool = true
        
        init() {}
        
        init(_ dictionary: [String: Any]) {
            self.hash = dictionary["hash"] as? String ?? ""
            self.height = dictionary["height"] as? Int64 ?? -1
            self.time = dictionary["time"] as? String ?? ""
            self.timestamp = dictionary["timestamp"] as? String ?? ""
            self.tx = StdTx.init(dictionary["tx"] as! [String : Any])
            
            if let rawResult = dictionary["result"] as? [String : Any] {
                self.result = Result.init(rawResult)
            }
            
            if let logs = dictionary["logs"] as? Array<NSDictionary> {
                for log in logs {
                    if let success = log.object(forKey: "success") as? Bool {
                        if(!success) {
                            self.allResult = false
                            return;
                        }
                    }
                }
            }
            
            if let logs = dictionary["logs"] as? NSDictionary {
                if let code = logs.object(forKey: "code") as? Int {
                    if(code > -1) {
                        self.allResult = false
                        return;
                    }
                }
            }
            
        }
    }
    
}
