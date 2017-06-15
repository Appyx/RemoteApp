//
//  AccessoryType.swift
//  RemoteApp
//
//  Created by Robert Gstöttner on 01/02/2017.
//  Copyright © 2017 FH. All rights reserved.
//

import Foundation


class AccessoryType{
    
    let description:String
    let name:String
    let possibleStates:Int
    
    
    init(entry:[String:Any]){
        description=entry["description"] as! String
        name=entry["name"] as! String
        possibleStates=entry["possibleStates"] as! Int
    }
    
    
    static func parseAll(json:[[String:Any]])->[AccessoryType]{
        var types:[AccessoryType] = []
        
        for entry in json{
            let type=AccessoryType(entry: entry)
            types.append(type)
        }
    
        return types
    }
    
}
