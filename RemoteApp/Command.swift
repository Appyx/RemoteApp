//
//  Command.swift
//  RemoteApp
//
//  Created by Robert Gstöttner on 04/02/2017.
//  Copyright © 2017 FH. All rights reserved.
//

import Foundation

class Command{
    
    var isCompound:Bool{
        return commands != nil
    }
    var name:String
    var signal:Int?=nil
    var commands:[Command]?=nil
    
    init(_ commandName:String) {
        name=commandName
    }
    init(_ commandName:String,signalID:Int) {
        name=commandName
        signal=signalID
    }
    init(withJson json:[String:Any]) {
        name=json["name"] as! String
        if let value=json["signal"] as? Int{
            signal=value
        }
        if let value=json["commands"] as? [[String:Any]]{
            commands=[]
            for entry in value{
                commands!.append(Command(withJson:entry))
            }
        }
    }
    
    func execute(){
        if isCompound{
            executeCompound()
        }else{
            executeSimple()
        }
    }
    
    private func executeSimple(){
        if let sig = signal{
            let client=HTTPClient.init(forType: HTTPClient.RequestType.action, jsonData: ["signalIDs":[sig]])
            client.request()
        }
    }
    
    private func executeCompound(){
        var array:[Int]=[]
        for command in commands!{
            if let sig=command.signal{
                array.append(sig)
            }
        }
        
        let client=HTTPClient.init(forType: HTTPClient.RequestType.action, jsonData: ["signalIDs":array])
        client.request()
    }
    
    func toJson()->[String:Any]{
        var map:[String:Any]=[:]
        map["name"]=name
        if let sig=signal{
            map["signal"]=sig
        }
        if let coms=commands{
            map["commands"]=Command.toJson(commands: coms)
        }
        
        return map
    }
    
    static func toJson(commands:[Command])->[[String:Any]]{
        var result:[[String:Any]]=[]
        for cmd in commands{
            result.append(cmd.toJson())
        }
        return result
    }
    
    
}
