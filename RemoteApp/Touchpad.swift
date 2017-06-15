//
//  Touchpad.swift
//  RemoteApp
//
//  Created by Robert Gstöttner on 03/02/2017.
//  Copyright © 2017 FH. All rights reserved.
//

import UIKit

class Touchpad:UIView {
    
    private var touchArea:UIView!
    private weak var superView:UIView!
    private var slider:UIView!
    private var animator: UIDynamicAnimator!
    
    var label:UILabel!
    
    var _editMode=false
    var editMode:Bool{
        set{
            _editMode=newValue
            if newValue==true{
                label.isHidden=false
            }else{
                label.isHidden=true
            }
        }
        get{
            return _editMode
        }
    }
    
    var upClosure:(()->())?
    var downClosure:(()->())?
    var middleClosure:(()->())?
    var leftClosure:(()->())?
    var rightClosure:(()->())?
    
    override init(frame: CGRect) {
        
        super.init(frame: frame)
        
    }

    convenience init(superview:UIView) {
        
        let height=superview.bounds.height/2
        let width=superview.bounds.width
        self.init(frame: CGRect(x: superview.bounds.origin.x, y: superview.bounds.origin.y+superview.bounds.height-height, width: width, height: height))
        
        superView=superview
        
        let originX=bounds.origin.x
        let originY=bounds.origin.y
        
        let sliderHeight:CGFloat=30
        slider=UIView(frame: CGRect(x:originX,y: originY,width:width,height:sliderHeight))
        slider.backgroundColor=UIColor(colorLiteralRed: 42/255.0, green: 126/255.0, blue: 201/255.0, alpha: 1.0)
        let dragIcon=UILabel(frame:slider.frame)
        dragIcon.text="o o o"
        dragIcon.textColor=UIColor.white
        dragIcon.textAlignment = .center
        slider.addSubview(dragIcon)
        addSubview(slider)
        
        touchArea=UIView(frame: CGRect(x:originX,y: originY+sliderHeight,width:width,height:height-sliderHeight))
        touchArea.backgroundColor=UIColor.gray
        addSubview(touchArea)
        
        label = UILabel(frame: CGRect(x:originX,y: originY+sliderHeight,width:width,height:height-sliderHeight))
        label.text="Tap to change the touchpad configuration!"
        label.textColor=UIColor.white
        label.textAlignment = .center
        label.isHidden=true
        addSubview(label)
        
        setupGestureRecognizers()
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    
    func setupGestureRecognizers(){
        let drag=UIPanGestureRecognizer(target: self, action: #selector(touchPadDragged(_:)))
        slider.addGestureRecognizer(drag)
        
        let left=UISwipeGestureRecognizer(target: self, action: #selector(touchPadSwiped(_:)))
        left.direction=UISwipeGestureRecognizerDirection.left
        touchArea.addGestureRecognizer(left)
        
        let right=UISwipeGestureRecognizer(target: self, action: #selector(touchPadSwiped(_:)))
        right.direction=UISwipeGestureRecognizerDirection.right
        touchArea.addGestureRecognizer(right)
        
        let up=UISwipeGestureRecognizer(target: self, action: #selector(touchPadSwiped(_:)))
        up.direction=UISwipeGestureRecognizerDirection.up
        touchArea.addGestureRecognizer(up)
        
        let down=UISwipeGestureRecognizer(target: self, action: #selector(touchPadSwiped(_:)))
        down.direction=UISwipeGestureRecognizerDirection.down
        touchArea.addGestureRecognizer(down)
        
        let press=UITapGestureRecognizer(target: self, action: #selector(touchPadTapped))
        touchArea.addGestureRecognizer(press)

    }
    
    func touchPadDragged(_ gestureRecognizer: UIPanGestureRecognizer){
        if gestureRecognizer.state == UIGestureRecognizerState.began || gestureRecognizer.state == UIGestureRecognizerState.changed {
            let translation = gestureRecognizer.translation(in: superView)
            let speed = gestureRecognizer.velocity(in: superView)
            let location = gestureRecognizer.location(in: superView)
            
            
            if location.y > superView.frame.height/2+slider.frame.height && location.y < superView.frame.height-slider.frame.height{
                center = CGPoint(x:center.x, y:center.y + translation.y)
                gestureRecognizer.setTranslation(CGPoint(x:0,y:0), in: superView)
                if speed.y > 500 {
                    animateDown()
                }
                if speed.y < -500{
                    animateUp()
                }
            }
        }
    }
    
    func touchPadSwiped(_ gestureRecognizer: UISwipeGestureRecognizer){
        let direction = gestureRecognizer.direction
        
        switch direction {
        case UISwipeGestureRecognizerDirection.down where downClosure != nil:
            downClosure!()
        case UISwipeGestureRecognizerDirection.up where upClosure != nil:
            upClosure!()
        case UISwipeGestureRecognizerDirection.left where leftClosure != nil:
            leftClosure!()
        case UISwipeGestureRecognizerDirection.right where rightClosure != nil:
            rightClosure!()
        default:
            break
        }
        
    }
    
    func touchPadTapped(_ gestureRecognizer: UITapGestureRecognizer){
        if let function=middleClosure{
            function()
        }
    }
    
    private func animateUp(){
        let leftPoint = CGPoint(x:0, y:superView.frame.height/2)
        let rightPoint = CGPoint(x:frame.width, y:superView.frame.height/2)
        
        let gravity = UIGravityBehavior(items: [self])
        let collision = UICollisionBehavior(items: [self])
        
        gravity.gravityDirection=CGVector(dx:0.0,dy: -5.0)
        let id:NSString="top"
        collision.addBoundary(withIdentifier: id, from: leftPoint, to: rightPoint)
        
        animator = UIDynamicAnimator(referenceView: superView)
        animator.addBehavior(collision)
        animator.addBehavior(gravity)
    }
    
    private func animateDown(){
        let leftPoint = CGPoint(x:0, y:superView.frame.height+frame.height-slider.frame.height)
        let rightPoint = CGPoint(x:frame.width, y:superView.frame.height+frame.height-slider.frame.height)
   
        
        let gravity = UIGravityBehavior(items: [self])
        gravity.gravityDirection=CGVector(dx:0.0, dy:5.0)
        let collision = UICollisionBehavior(items: [self])
        let id:NSString="bottom"
        collision.addBoundary(withIdentifier: id, from: leftPoint, to: rightPoint)
        
        animator=UIDynamicAnimator(referenceView: superView)
        animator.addBehavior(collision)
        animator.addBehavior(gravity)
    }

    
}
