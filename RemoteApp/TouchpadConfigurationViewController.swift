//
//  TouchpadConfigurationViewController.swift
//  RemoteApp
//
//  Created by Robert Gstöttner on 02/02/2017.
//  Copyright © 2017 FH. All rights reserved.
//

import UIKit

class TouchpadConfigurationViewController: UIViewController,UITableViewDelegate,UITableViewDataSource {
    
    private static var state:TouchpadDirection=TouchpadDirection.Up

    @IBOutlet var skipButton: UIButton!
    @IBOutlet var descriptionLabel: UILabel!
    @IBOutlet var tableView: UITableView!
    
    var remote:Remote!=nil
    var isLast=false
    var editMode=false
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        tableView.delegate=self
        tableView.dataSource=self
        
        var text:String=""
        if let key=getCommand(forState: TouchpadConfigurationViewController.state){
           text = "(The actual key is \"\(key.name)\")"
        }
        
        if TouchpadConfigurationViewController.state != TouchpadDirection.Middle{
            descriptionLabel.text="Please choose the key that should be used by swiping to the \(TouchpadConfigurationViewController.state.rawValue):\n\(text)"
        }else{
            isLast=true
            skipButton.setTitle("Finish", for: .normal)
            descriptionLabel.text="Please choose the key that should be used by a REGULAR TAP:\n\(text)"
        }
    }

    @IBAction func skipButton(_ sender: Any) {
        next()
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath){
        switch TouchpadConfigurationViewController.state {
        case TouchpadDirection.Up:
            remote.touchpadUp=remote.commands[indexPath.row]
            break
        case TouchpadDirection.Down:
            remote.touchpadDown=remote.commands[indexPath.row]
            break
        case TouchpadDirection.Left:
            remote.touchpadLeft=remote.commands[indexPath.row]
            break
        case TouchpadDirection.Right:
            remote.touchpadRight=remote.commands[indexPath.row]
            break
        case TouchpadDirection.Middle:
            remote.touchpadMiddle=remote.commands[indexPath.row]
            break
        }
        next()
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell{
        let cell=tableView.dequeueReusableCell(withIdentifier: "CommandCell")!
        cell.textLabel?.text=remote.commands[indexPath.row].name
        return cell
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int{
        return remote.commands.count
    }
    
    func next(){
        switch TouchpadConfigurationViewController.state {
        case TouchpadDirection.Up:
            TouchpadConfigurationViewController.state=TouchpadDirection.Down
            break
        case TouchpadDirection.Down:
            TouchpadConfigurationViewController.state=TouchpadDirection.Left
            break
        case TouchpadDirection.Left:
            TouchpadConfigurationViewController.state=TouchpadDirection.Right
            break
        case TouchpadDirection.Right:
            TouchpadConfigurationViewController.state=TouchpadDirection.Middle
            break
        case TouchpadDirection.Middle:
            TouchpadConfigurationViewController.state=TouchpadDirection.Up
            break
        }
        
        if isLast {
            self.view.window!.rootViewController?.dismiss(animated: true, completion: nil)
            if !editMode{
                Database.shared.remotes.append(remote)
                Database.shared.save()
            }
        }else{
            let storyboard = UIStoryboard(name: "Main", bundle: nil)
            let controller = storyboard.instantiateViewController(withIdentifier: "TouchpadConfiguration") as! TouchpadConfigurationViewController
            controller.remote=remote
            controller.editMode=editMode
            self.present(controller, animated: true, completion: nil)
        }
    }
    
    func getCommand(forState:TouchpadDirection)->Command?{
        switch forState {
        case TouchpadDirection.Up:
            return remote.touchpadUp
        case TouchpadDirection.Down:
            return remote.touchpadDown
        case TouchpadDirection.Left:
            return remote.touchpadLeft
        case TouchpadDirection.Right:
            return remote.touchpadRight
        case TouchpadDirection.Middle:
            return remote.touchpadMiddle
        }
    }
}


enum TouchpadDirection:String{
    case Up="UP"
    case Down="BOTTOM"
    case Left="LEFT"
    case Right="RIGHT"
    case Middle
}
