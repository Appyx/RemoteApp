//
//  Database.swift
//  RemoteApp
//
//  Created by Robert Gstöttner on 01/02/2017.
//  Copyright © 2017 FH. All rights reserved.
//

import Foundation
import HomeKit

final class Database {
    static let shared = Database()
    
    public var accessories:[AccessoryConfiguration]!
    public var remotes:[Remote]=[]
    public var types:[AccessoryType]=[]
    public let levels=["Analog Sensor","Digital Sensor","Always On","On/Off","On/Off + Control","On/Off + Control + On/Off"]
    
    private init(){
        let defaults=UserDefaults.standard
        if let value = defaults.string(forKey: "serverUrl") {
            HTTPClient.serverUrl=value
        }
        if let value = defaults.string(forKey: "serverPort") {
            HTTPClient.serverPort=value
        }
    }
    
    func updateServerLocation(){
        let defaults = UserDefaults.standard
        defaults.set(HTTPClient.serverUrl, forKey: "serverUrl")
        defaults.set(HTTPClient.serverPort,forKey: "serverPort")
    }

    func refresh(callback:@escaping ()->()){
        let client=HTTPClient(forType: HTTPClient.RequestType.info)
        client.request(response: {json in
            self.accessories=AccessoryConfiguration.parseJson(json: json["accessories"] as! [[String:Any]])
            self.remotes=Remote.parseJson(json: json["remotes"] as! [[String:Any]])
            self.types=AccessoryType.parseAll(json: json["types"] as! [[String:Any]])
            callback()
        })
    }
    
    func save(callback:@escaping ()->()){
        let acc=AccessoryConfiguration.toJson(configs: accessories)
        let rem=Remote.toJson(remotes: remotes)
        let json:[String:Any] = ["accessories":acc,"remotes":rem]
        let client = HTTPClient.init(forType: HTTPClient.RequestType.save, jsonData: json)
        client.request(response: {_ in callback()})
        print("saved")
    }
    
    func save(){
        save(callback: {_ in})
    }
    
    func getRemoteNames()->[String]{
        var array:[String]=[]
        for remote in remotes{
            array.append(remote.name)
        }
        return array
    }
    
    func getAccessoryNames()->[String]{
        var array:[String]=[]
        for acc in accessories{
            array.append(acc.name)
        }
        return array
    }
    
    func getCommandNames(forRemote:String)->[String]{
        var foundRemote:Remote!
        for remote in remotes{
            if remote.name == forRemote{
                foundRemote=remote
            }
        }
        var array:[String]=[]
        for command in foundRemote.commands{
            array.append(command.name)
        }
        return array
    }
    
    func getCommandNames(forCommand:Command)->[String]{
        var array:[String]=[]
        for command in forCommand.commands!{
            array.append(command.name)
        }
        return array
    }
    
    func getSimpleCommandMap(firstRemote:Remote)->[(String,[String])]{
        var map:[(String,[String])]=[]
        
        var array:[String]=[]
        for command in firstRemote.commands{
            if !command.isCompound{
                array.append(command.name)
            }
        }
        map.append((firstRemote.name,array))
        
        
        for remote in remotes{
            array=[]
            if remote.name != firstRemote.name{
                for command in remote.commands{
                    if !command.isCompound{
                        array.append(command.name)
                    }
                }
                map.append((remote.name,array))
            }
        }
        return map
    }
    
    func getFullCommandMap()->[(String,[String])]{
        var map:[(String,[String])]=[]
        var array:[String]=[]
        
        for remote in remotes{
            array=[]
            for command in remote.commands{
                
                array.append(command.name)
                
            }
            map.append((remote.name,array))
        }
        return map
    }
    
    func getCommand(commandName:String,remoteName: String)->Command?{
        let remote=getRemote(name: remoteName)
        for command in remote!.commands{
            if command.name==commandName {
                return command
            }
        }
        return nil
    }
    
    func getRemote(name:String)->Remote?{
        for remote in remotes{
            if remote.name==name {
                return remote
            }
        }
        return nil
    }
    
    func getServiceforType(level:Int?)->[String]{
        var array:[String]=[]
        if let value=level{
            for type in types{
                if value >= 0 && value <= type.possibleStates{ //device
                    array.append(type.name)
                }
                if value < 0 && value == type.possibleStates{ //sensor
                    array.append(type.name)
                }
            }
        }
        return array
    }
    
    func getType(forName:String)->AccessoryType?{
        for type in types{
            if type.name==forName{
                return type
            }
        }
        return nil
    }
    
}

