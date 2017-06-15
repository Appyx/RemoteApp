//
//  CommandTableView.swift
//  HomeRemote
//
//  Created by Robert Gstöttner on 28/04/16.
//  Copyright © 2016 FH. All rights reserved.
//

import Foundation
import UIKit

class TableViewHandler:NSObject,UITableViewDelegate,UITableViewDataSource{
    
    var cellID:String
    var isEditing=false
    var isSelectAble=false
    var title:String? = nil
    
    var selectActionClosure:((Int)->())?=nil
    var editActionClosure:((Int)->())?=nil
    var deleteActionClosure:((Int)->())?=nil
    var moveActionClosure:((Int,Int)->())?=nil
    var modifyCellClosure:((UITableViewCell,Int)->())?=nil
    
    var dataClosure:()->([String])
    
    var table:UITableView?=nil
    
    init(cellIdentifier:String,data:@escaping ()->([String])){
        cellID=cellIdentifier
        dataClosure=data
    }
    
    func update(){
        table?.reloadData()
    }
    
    func tableView(_ tableView: UITableView,numberOfRowsInSection section: Int) -> Int {
        table=tableView
        return dataClosure().count;
    }
    
    func tableView(_ tableView: UITableView,cellForRowAt indexPath: IndexPath) -> UITableViewCell{
        let cell=tableView.dequeueReusableCell(withIdentifier: cellID)! as UITableViewCell
        if let label=cell.contentView.viewWithTag(100) as? UILabel{
            label.text=dataClosure()[indexPath.row]
        }else{
            cell.textLabel?.text=dataClosure()[indexPath.row]
        }
        if let function=modifyCellClosure{
            function(cell,indexPath.row)
        }
        return cell
    }
    
    func tableView(_ tableView: UITableView,didSelectRowAt indexPath: IndexPath) {
        if !isSelectAble{
            tableView.deselectRow(at: indexPath as IndexPath, animated: true)
        }
        if let function=self.selectActionClosure{
            function(indexPath.row)
        }
    }
    
    func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        return title
    }
    
    func tableView(_ tableView: UITableView, canMoveRowAt indexPath: IndexPath) -> Bool {
        return moveActionClosure != nil
    }
    
    func tableView(_ tableView: UITableView, moveRowAt sourceIndexPath: IndexPath, to destinationIndexPath: IndexPath) {
        if let function=moveActionClosure{
            function(sourceIndexPath.row,destinationIndexPath.row)
        }
    }
   
    
    func tableView(_ tableView: UITableView,editingStyleForRowAt indexPath: IndexPath) -> UITableViewCellEditingStyle {
        return UITableViewCellEditingStyle.delete
    }
    
    func tableView(_ tableView: UITableView, editActionsForRowAt indexPath: IndexPath) -> [UITableViewRowAction]? {
        let editAction:UITableViewRowAction
        if isEditing==false{ //changed on action-event of edit button
            if let function=self.editActionClosure{
                editAction = UITableViewRowAction(style: .normal, title: "Edit") { action,index in
                    function(indexPath.row)
                }
                editAction.backgroundColor = UIColor.gray
                return [editAction]
            }
        }else{
            
            if let function=self.deleteActionClosure{
                editAction = UITableViewRowAction(style: .normal, title: "Delete", handler: {action,index in
                    function(indexPath.row)
                    tableView.reloadData()
                })
                editAction.backgroundColor = UIColor.red
                return [editAction]
            }
            
        }
        return[]
    }
    
}
