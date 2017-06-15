//
//  CommandChooserViewController.swift
//  RemoteApp
//
//  Created by Robert Gstöttner on 03/02/2017.
//  Copyright © 2017 FH. All rights reserved.
//

import UIKit

class CommandChooserViewController: UIViewController,UITableViewDelegate,UITableViewDataSource {
    
    var command:Command!
    var remote:Remote!
    var accessory:AccessoryConfiguration?
    
    var resultClosure:((Command,String)->())? //used for accessory (acc has no field to store command temporary)
    
    var tableData:[(String,[String])]!
    
    @IBOutlet var tableView: UITableView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        if accessory == nil{
            tableData=Database.shared.getSimpleCommandMap(firstRemote: remote)
        }else{
           tableData=Database.shared.getFullCommandMap()
        }
        
        tableView.dataSource=self
        tableView.delegate=self
    }
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return tableData.count
    }
    
    
    func tableView(_ tableView: UITableView,numberOfRowsInSection section: Int) -> Int {
        return tableData[section].1.count;
    }
    
    func tableView(_ tableView: UITableView,cellForRowAt indexPath: IndexPath) -> UITableViewCell{
        let cell=tableView.dequeueReusableCell(withIdentifier: "command")
        
        cell?.textLabel?.text=tableData[indexPath.section].1[indexPath.row]

        return cell!
        
        
    }
    
    func tableView(_ tableView: UITableView,didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath as IndexPath, animated: true)
        
        let remoteName=tableData[indexPath.section].0
        let commandName=tableData[indexPath.section].1[indexPath.row]
        
        let newCommand=Database.shared.getCommand(commandName: commandName, remoteName: remoteName)!
        
        if accessory == nil{
            command.commands?.append(newCommand) //set the result directly
            Database.shared.save()
            self.view.window!.rootViewController?.dismiss(animated: true, completion: nil)
        }else{
            resultClosure!(newCommand,remoteName) //return the result to caller
            self.dismiss(animated: true, completion: nil)
        }
        
    }
    
    func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        return tableData[section].0
    }
    
}
