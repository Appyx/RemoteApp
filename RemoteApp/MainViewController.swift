//
//  MainViewController.swift
//  RemoteApp
//
//  Created by Robert Gstöttner on 31/01/2017.
//  Copyright © 2017 FH. All rights reserved.
//

import UIKit

class MainViewController: UIViewController {
    
    @IBOutlet var activityIndicator: UIActivityIndicatorView!
    
    @IBOutlet var accessoryButton: UIButton!
    @IBOutlet var remoteButton: UIButton!
    
    @IBOutlet var newAccessoryButton: UIButton!
    @IBOutlet var newRemoteButton: UIButton!
    
    var isLoading=true;
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        loadData()
        NotificationCenter.default.addObserver(self, selector: #selector(serverError), name: NSNotification.Name(rawValue: "server_error"), object: nil);
    }
    
    func loadData(){
        Database.shared.refresh(callback: {error in
            DispatchQueue.main.async {
                self.isLoading=false
                self.activityIndicator.stopAnimating()
                self.updateUI()
            }
        })
    }
    
    func serverError(){
        var urlTextField:UITextField!
        var portTextField:UITextField!
        
        let errorAlert=UIAlertController(title: "Server Error", message: "There was an error conneting to the server located at:", preferredStyle: UIAlertControllerStyle.alert)
        errorAlert.addTextField(configurationHandler: { textField -> Void in
            textField.keyboardType=UIKeyboardType.URL
            textField.text=HTTPClient.serverUrl
            urlTextField=textField
        })
        errorAlert.addTextField(configurationHandler: { textField -> Void in
            textField.keyboardType=UIKeyboardType.numberPad
            textField.text=HTTPClient.serverPort
            portTextField=textField
        })
        
        let okAction = UIAlertAction(title: "Retry", style: UIAlertActionStyle.default, handler: {(alert :UIAlertAction!) in
            if let value = urlTextField.text {
                HTTPClient.serverUrl=value
            }
            if let value = portTextField.text {
                HTTPClient.serverPort=value
            }
            Database.shared.updateServerLocation()
            self.loadData()
        })
        errorAlert.addAction(okAction)
        self.present(errorAlert, animated: true, completion: nil)
    }
    
    func updateUI(){
        if isLoading{
            return
        }
        if Database.shared.accessories?.count==0{
            newAccessoryButton.isHidden=false
            accessoryButton.isHidden=true
        }else{
            accessoryButton.isHidden=false
            newAccessoryButton.isHidden=true
        }
        if Database.shared.remotes.count==0{
            newRemoteButton.isHidden=false
            remoteButton.isHidden=true
        }else{
            remoteButton.isHidden=false
            newRemoteButton.isHidden=true
        }
    }
    
    override func viewWillAppear(_ animated: Bool) {
        updateUI()
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if let id=segue.identifier{
            if id == "firstRemoteSegue" {
                (segue.destination as! AssistantViewController).type=AssistantType.Remote
            }
            if id=="firstAccessorySegue" {
                (segue.destination as! AssistantViewController).type=AssistantType.Accessory
            }
        }
    }
    
    
}
