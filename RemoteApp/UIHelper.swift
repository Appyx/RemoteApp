//
//  UIHelper.swift
//  RemoteApp
//
//  Created by Robert Gstöttner on 03/02/2017.
//  Copyright © 2017 FH. All rights reserved.
//

import UIKit
import Foundation

class UIHelper{
    
    static func createAlert(keyboard:UIKeyboardType = .alphabet,text:String,result:@escaping (String)->())->UIAlertController{
        var renameTextField:UITextField?
        
        let renameAlert=UIAlertController(title: text, message: nil, preferredStyle: UIAlertControllerStyle.alert)
        renameAlert.addTextField(configurationHandler: { textField -> Void in
            textField.keyboardType=keyboard
            renameTextField=textField
        })
        
        let cancelAction = UIAlertAction(title: "Cancel", style: UIAlertActionStyle.cancel, handler: nil)
        renameAlert.addAction(cancelAction)
        
        let okAction = UIAlertAction(title: "OK", style: UIAlertActionStyle.default, handler: {(alert :UIAlertAction!) in
            if let name=renameTextField?.text{
                result(name)
            }
        })
        renameAlert.addAction(okAction)
        
        return renameAlert
    }
    
}
