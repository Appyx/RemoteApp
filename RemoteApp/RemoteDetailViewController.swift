//
//  RemoteDetailViewController.swift
//  RemoteApp
//
//  Created by Robert Gstöttner on 31/01/2017.
//  Copyright © 2017 FH. All rights reserved.
//

import UIKit

class RemoteDetailViewController: UIViewController {
    
    var remote:Remote!
    var tableHandler:TableViewHandler!
    
    var touchpad:Touchpad? = nil

    @IBOutlet var editButton: UIButton!
    @IBOutlet var tableView: UITableView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        navigationItem.title=remote.name
        
        
        tableHandler=TableViewHandler(cellIdentifier: "command",data:{return Database.shared.getCommandNames(forRemote: self.remote.name)})
        tableView.dataSource=tableHandler
        tableView.delegate=tableHandler
        
        tableHandler.selectActionClosure={ index in
            self.remote.commands[index].execute()
        }
        tableHandler.editActionClosure={index in
            let command=self.remote.commands[index];
            
            if command.isCompound{
                self.performSegue(withIdentifier: "showCompoundCommand", sender: index) //start compound command editing
            }else{
                let renameAlert=UIHelper.createAlert(text:"Enter the new name:",result: {newName in
                    command.name=newName
                    Database.shared.save()
                    self.tableHandler.update()
                })
                self.present(renameAlert, animated: true, completion: nil) //start renaming popup
            }
        }
        tableHandler.deleteActionClosure={index in
            self.remote.commands.remove(at: index)
        }
        tableHandler.moveActionClosure={from,to in
            let entry=self.remote.commands.remove(at: from)
            self.remote.commands.insert(entry, at: to)
        }
        tableHandler.modifyCellClosure={cell,index in
            if self.remote.commands[index].isCompound{
                cell.contentView.viewWithTag(101)?.backgroundColor=UIColor.black
            }else{
                cell.contentView.viewWithTag(101)?.backgroundColor=UIColor(colorLiteralRed: 51/255.0, green: 150/255.0, blue: 236/255.0, alpha: 1.0)
            }
        }
    }
    
    override func viewWillAppear(_ animated: Bool) {
        tableHandler.update()
        if remote.supportsTouchpad && touchpad == nil{
            touchpad=Touchpad(superview: self.view)
            view.addSubview(touchpad!)
            
            if let command=remote.touchpadDown{
                touchpad?.downClosure={
                    command.execute()
                }
            }
            if let command=remote.touchpadUp{
                touchpad?.upClosure={
                    command.execute()
                }
            }
            if let command=remote.touchpadLeft{
                touchpad?.leftClosure={
                    command.execute()
                }
            }
            if let command=remote.touchpadRight{
                touchpad?.rightClosure={
                    command.execute()
                }
            }
            if let command=remote.touchpadMiddle{
                touchpad?.middleClosure={
                    command.execute()
                }
            }
        }
    }
    
    @IBAction func editAction(_ sender: Any) {
        if tableView.isEditing==true{
            tableHandler?.isEditing=false
            tableView.setEditing(false, animated: true)
            editButton.setTitle("Edit", for: UIControlState.normal)
            touchpad?.editMode=false
            touchpad?.middleClosure=nil
            if let command=remote.touchpadMiddle{
                touchpad?.middleClosure={
                    command.execute()
                }
            }
            Database.shared.save()
        }else{
            tableHandler?.isEditing=true
            tableView.setEditing(true, animated: true)
            editButton.setTitle("Done", for: UIControlState.normal)
            touchpad?.editMode=true
            touchpad?.middleClosure={
                let storyboard = UIStoryboard(name: "Main", bundle: nil)
                let controller = storyboard.instantiateViewController(withIdentifier: "TouchpadConfiguration") as! TouchpadConfigurationViewController
                controller.remote=self.remote
                controller.editMode=true
                self.present(controller, animated: true, completion: nil)
            }
        }
    }

    @IBAction func addButton(_ sender: Any) {
        let actionSheet = UIAlertController(title: "Choose an action", message: nil, preferredStyle: UIAlertControllerStyle.actionSheet)
        
        //action sheet cancel button
        let cancelAction = UIAlertAction(title: "Cancel", style: UIAlertActionStyle.cancel, handler: nil)
        actionSheet.addAction(cancelAction)
        
        //action sheet record button
        let recordAction = UIAlertAction(title: "Record new command", style: UIAlertActionStyle.default, handler: {alert in
            let storyboard = UIStoryboard(name: "Main", bundle: nil)
            let controller = storyboard.instantiateViewController(withIdentifier: "RecordSignal") as! RecordSignalViewController
            controller.remote=self.remote
            controller.isEasyMode=true
            self.present(controller, animated: true, completion: nil) //start rocord assistant
        })
        actionSheet.addAction(recordAction)
        
        //action sheet empty button
        let commandAction = UIAlertAction(title: "Create empty command", style: UIAlertActionStyle.default, handler: {alert in
            let renameAlert=UIHelper.createAlert(text:"Enter the new name:",result: {newName in
                let command=Command(newName)
                command.commands=[]
                self.remote.addCommand(command)
                self.tableHandler.update()
            })
            self.present(renameAlert, animated: true, completion: nil) //create empty command -> start popup to enter name
        })
        actionSheet.addAction(commandAction)

        //start action sheet to choose record/empty command
        self.present(actionSheet, animated: true, completion: nil)
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if let id=segue.identifier{
            if id == "showCompoundCommand"{
                let controller = segue.destination as! CommandDetailViewController //segue triggered by editing compound command
                controller.command=remote.commands[(sender as! Int)]
                controller.remote=remote
            }
        }
    }
}
