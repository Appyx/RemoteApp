//
//  Remote.swift
//  RemoteApp
//
//  Created by Robert Gstöttner on 01/02/2017.
//  Copyright © 2017 FH. All rights reserved.
//

import Foundation

class Remote{
    var name:String
    var commands:[Command]=[]
    var supportsTouchpad:Bool{
        return touchpadUp != nil || touchpadDown != nil || touchpadLeft != nil || touchpadRight != nil || touchpadMiddle != nil
    }
    var touchpadUp:Command?=nil
    var touchpadDown:Command?=nil
    var touchpadLeft:Command?=nil
    var touchpadRight:Command?=nil
    var touchpadMiddle:Command?=nil
    
    init(withName:String) {
        name=withName
    }
    
    init(withJson json:[String:Any]){
        name=json["name"] as! String
        if let value=json["commands"] as? [[String:Any]]{
            for entry in value{
                commands.append(Command(withJson:entry))
            }
        }
        if let value=json["touchpadUp"] as? [String:Any]{
            touchpadUp=Command(withJson: value)
        }
        if let value=json["touchpadDown"] as? [String:Any]{
            touchpadDown=Command(withJson: value)
        }
        if let value=json["touchpadLeft"] as? [String:Any]{
            touchpadLeft=Command(withJson: value)
        }
        if let value=json["touchpadRight"] as? [String:Any]{
            touchpadRight=Command(withJson: value)
        }
        if let value=json["touchpadMiddle"] as? [String:Any]{
            touchpadMiddle=Command(withJson: value)
        }
    }
    
    func addCommand(_ command:Command){
        commands.append(command)
    }
    
    static func parseJson(json:[[String:Any]])->[Remote]{
        var remotes:[Remote] = []
        
        for entry in json{
            let remote=Remote(withJson: entry)
            remotes.append(remote)
        }
        
        return remotes
    }
    
    func toJson()->[String:Any]{
        var map:[String:Any]=[:]
        map["name"]=name
        map["commands"]=Command.toJson(commands: commands)
        if let value=touchpadUp{
            map["touchpadUp"]=value.toJson()
        }
        if let value=touchpadDown{
            map["touchpadDown"]=value.toJson()
        }
        if let value=touchpadLeft{
            map["touchpadLeft"]=value.toJson()
        }
        if let value=touchpadRight{
            map["touchpadRight"]=value.toJson()
        }
        if let value=touchpadMiddle{
            map["touchpadMiddle"]=value.toJson()
        }
        return map
    }
    
    static func toJson(remotes:[Remote])->[[String:Any]]{
        var array:[[String:Any]]=[]
        for remote in remotes{
            array.append(remote.toJson())
        }
        return array
    }
}
