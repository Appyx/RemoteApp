//
//  HomeKitHandler.swift
//  RemoteApp
//
//  Created by Robert Gstöttner on 05/02/2017.
//  Copyright © 2017 FH. All rights reserved.
//

import Foundation
import HomeKit

class HomeKitHandler: NSObject,HMHomeManagerDelegate,HMAccessoryBrowserDelegate {

    let manager:HMHomeManager
    let browser:HMAccessoryBrowser
    
    override init() {
        manager=HMHomeManager()
        browser=HMAccessoryBrowser()
    }
    
    func handle(){
        manager.delegate=self
        browser.delegate=self
    }
    
    
    
    func homeManagerDidUpdateHomes(_ manager: HMHomeManager){
        
        print(manager.homes.count)
        print("hallo")
        for home in manager.homes{
            print(home.name)
        }
        
        if let home = manager.primaryHome{
            for acc in home.accessories{
                print(acc.name)
            }
        }
    }
    
    func homeManagerDidUpdatePrimaryHome(_ manager: HMHomeManager){
        print("hallo")
        print(manager.primaryHome?.name ?? "nothing")
    }
    
    func add(){
        browser.startSearchingForNewAccessories()
    }
    
    func accessoryBrowser(_ browser: HMAccessoryBrowser, didFindNewAccessory accessory: HMAccessory) {
        print("hallo")
        print("found \(accessory.name)")
        /*if let home = manager.primaryHome{
            home.addAccessory(accessory, completionHandler: {error in
                
            })
            
        }
        browser.stopSearchingForNewAccessories()*/
    }
}
