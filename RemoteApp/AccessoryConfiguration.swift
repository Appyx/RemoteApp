//
//  AccessoryConfiguration.swift
//  RemoteApp
//
//  Created by Robert Gstöttner on 01/02/2017.
//  Copyright © 2017 FH. All rights reserved.
//

import Foundation


class AccessoryConfiguration{
    
    var analogReference:Int?
    var name:String!
    var sensorPin:Int?
    var typeName:String!
    var usedStates:Int!
    var firstState:Bool?
    var firstStateOffSignals:Remote?
    var firstStateOnSignals:Remote?
    var secondState:Int?
    var secondStateMaxValue:Int?
    var secondStateDecreaseSignals:Remote?
    var secondStateIncreaseSignals:Remote?
    var thirdState:Bool?
    var thirdStateOffSignals:Remote?
    var thirdStateOnSignals:Remote?
    
    private(set) var username:String!
    private(set) var uuid:String!
    private(set) var port:Int!
    private(set) var sensorValue:Int?
    
    
    init(withName:String) {
        name=withName
    }
    
    init(entry:[String:Any]) {
        analogReference=entry["analogReference"] as? Int
        name=entry["name"] as! String
        port=entry["port"] as! Int
        sensorPin=entry["sensorPin"] as? Int
        typeName=entry["typeName"] as! String
        usedStates=entry["usedStates"] as! Int
        username=entry["username"] as! String
        uuid=entry["uuid"] as! String
        firstState=entry["firstState"] as? Bool
        if let value=entry["firstStateOffSignals"] as? [String:Any]{
            firstStateOffSignals=Remote(withJson: value)
        }
        if let value=entry["firstStateOnSignals"] as? [String:Any]{
            firstStateOnSignals=Remote(withJson: value)
        }
        secondState=entry["secondState"] as? Int
        secondStateMaxValue=entry["secondStateMaxValue"] as? Int
        if let value=entry["secondStateDecreaseSignals"] as? [String:Any]{
            secondStateDecreaseSignals=Remote(withJson: value)
        }
        if let value=entry["secondStateIncreaseSignals"] as? [String:Any]{
            secondStateIncreaseSignals=Remote(withJson: value)
        }
        thirdState=entry["thirdState"] as? Bool
        if let value=entry["thirdStateOffSignals"] as? [String:Any]{
            thirdStateOffSignals=Remote(withJson: value)
        }
        if let value=entry["thirdStateOnSignals"] as? [String:Any]{
            thirdStateOnSignals=Remote(withJson: value)
        }
        if let value=entry["sensorValue"] as? Float{
            sensorValue=Int(value)
        }
        else if let value=entry["sensorValue"] as? Bool{
            sensorValue=value ? 1:0
        }
        
    }
    
    static func parseJson(json:[[String:Any]])->[AccessoryConfiguration]{
        var configs:[AccessoryConfiguration] = []
        
        for entry in json{
            let config=AccessoryConfiguration(entry: entry)
            configs.append(config)
        }
        
        return configs
    }
    
    func toJson()->[String:Any]{
        var map:[String:Any]=[:]
        if let value=analogReference{
            map["analogReference"]=value
        }
        if let value=firstState{
            map["firstState"]=value
        }
        if let value=firstStateOffSignals{
            map["firstStateOffSignals"]=value.toJson()
        }
        if let value=firstStateOnSignals{
            map["firstStateOnSignals"]=value.toJson()
        }
        if let value=name{
            map["name"]=value
        }
        if let value=port{
            map["port"]=value
        }
        if let value=secondState{
            map["secondState"]=value
        }
        if let value=secondStateDecreaseSignals{
            map["secondStateDecreaseSignals"]=value.toJson()
        }
        if let value=secondStateIncreaseSignals{
            map["secondStateIncreaseSignals"]=value.toJson()
        }
        if let value=secondStateMaxValue{
            map["secondStateMaxValue"]=value
        }
        if let value=sensorPin{
            map["sensorPin"]=value
        }
        if let value=sensorValue{
            map["sensorValue"]=value
        }
        if let value=thirdState{
            map["thirdState"]=value
        }
        if let value=thirdStateOffSignals{
            map["thirdStateOffSignals"]=value.toJson()
        }
        if let value=thirdStateOnSignals{
            map["thirdStateOnSignals"]=value.toJson()
        }
        if let value=typeName{
            map["typeName"]=value
        }
        if let value=usedStates{
            map["usedStates"]=value
        }
        if let value=username{
            map["username"]=value
        }
        if let value=uuid{
            map["uuid"]=value
        }
        return map
    }
    
    static func toJson(configs:[AccessoryConfiguration])->[[String:Any]]{
        var array:[[String:Any]]=[]
        for config in configs{
            array.append(config.toJson())
        }
        return array
    }
    
    
}
