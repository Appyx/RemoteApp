//
//  CommandDetailViewController.swift
//  RemoteApp
//
//  Created by Robert Gstöttner on 03/02/2017.
//  Copyright © 2017 FH. All rights reserved.
//

import UIKit

class CommandDetailViewController: UIViewController, UITextFieldDelegate {

  
    @IBOutlet var nameInput: UITextField!
    @IBOutlet var tableView: UITableView!
    @IBOutlet var editButton: UIButton!
    
    var tableHandler:TableViewHandler!
    var command:Command!
    var remote:Remote!
    
    
    override func viewDidLoad() {
        super.viewDidLoad()

        nameInput.text=command.name
        nameInput.delegate=self
        
        tableHandler=TableViewHandler(cellIdentifier: "commandPart",data:{return Database.shared.getCommandNames(forCommand: self.command)})
        tableView.dataSource=tableHandler
        tableView.delegate=tableHandler
        
        tableHandler.moveActionClosure={from,to in
            if var commands=self.command.commands{
                let entry=commands.remove(at: from)
                commands.insert(entry, at: to)
                self.command.commands=commands
            }
        }
        tableHandler.deleteActionClosure={index in
            if var commands=self.command.commands{
                commands.remove(at: index)
                self.command.commands=commands
            }
        }
        tableHandler.title="Commands"
    }
    
    override func viewWillAppear(_ animated: Bool) {
        tableHandler.update()
    }
    

    @IBAction func addAction(_ sender: Any) {
        let actionSheet = UIAlertController(title: "Choose an action", message: nil, preferredStyle: UIAlertControllerStyle.actionSheet)
        
        //action sheet cancel button
        let cancelAction = UIAlertAction(title: "Cancel", style: UIAlertActionStyle.cancel, handler: nil)
        actionSheet.addAction(cancelAction)
        
        //action sheet delay button
        let delayAction = UIAlertAction(title: "Create delay", style: UIAlertActionStyle.default, handler: {alert in
            let delayAlert=UIHelper.createAlert(keyboard:.numberPad,text:"Enter a delay in ms:",result: {delay in
                let id=Int(delay)!
                let newCommand=Command("Delay: \(id) ms")
                newCommand.signal=id*(-1)
                self.command.commands?.append(newCommand)
                Database.shared.save()
                self.tableHandler.update()
            })
            self.present(delayAlert, animated: true, completion: nil) //start delay popup
        })
        actionSheet.addAction(delayAction)
        
        //action sheet command chooser button
        let commandAction = UIAlertAction(title: "Choose a command", style: UIAlertActionStyle.default, handler: {alert in
            let storyboard = UIStoryboard(name: "Main", bundle: nil)
            let controller = storyboard.instantiateViewController(withIdentifier: "CommandChooser") as! CommandChooserViewController
            controller.remote=self.remote
            controller.command=self.command
            self.present(controller, animated: true, completion: nil) //start command chooser
        })
        actionSheet.addAction(commandAction)
        
        //start action sheet to choose delay or command chooser
        self.present(actionSheet, animated: true, completion: nil)
    }
    
    @IBAction func editAction(_ sender: Any) {
        if tableView.isEditing==true{
            tableHandler?.isEditing=false
            tableView.setEditing(false, animated: true)
            editButton.setTitle("Edit", for: UIControlState.normal)
            Database.shared.save()
        }else{
            tableHandler?.isEditing=true
            tableView.setEditing(true, animated: true)
            editButton.setTitle("Done", for: UIControlState.normal)
        }
    }
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        self.view.endEditing(true)
        if let text=nameInput.text{
            command.name=text
            Database.shared.save()
        }
        textField.resignFirstResponder()
        return false
    }
}
