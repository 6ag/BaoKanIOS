//
//  LLFlowLayer.swift
//
//  Created by LL on 15/11/1.
//  Copyright © 2015 LL. All rights reserved.
//

import UIKit
import QuartzCore

public class LLFlowLayer:CALayer
{
    @NSManaged var reveal : CGFloat
    @NSManaged var control : CGFloat
    @NSManaged var start : CGFloat
    
    static public var KEY_REVEAL :String = "reveal"
    static public var KEY_CONTROL :String = "control"
    static public var KEY_START :String = "start"
    
    override init() {
        super.init()
    }
    
    override init(layer: AnyObject) {
        super.init(layer: layer)
        if(layer.isKindOfClass(LLFlowLayer.classForCoder()))
        {
            let l:LLFlowLayer = layer as! LLFlowLayer
            self.reveal = l.reveal
            self.start = l.start
            self.control = l.control
        }
    }
    
    required public init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }
    
    public override class func needsDisplayForKey(key: String) -> Bool
    {
        if( key == "reveal" || key == "control" || key == "start")
        {
            return true
        }
        return super.needsDisplayForKey(key)
    }
    
    public override func actionForKey(key: String) -> CAAction?
    {
        if ( key == "reveal" || key == "control" || key == "start")
        {
            let theAnimation : CABasicAnimation = CABasicAnimation(keyPath:key)
            
            theAnimation.fromValue = self.presentationLayer()?.contents
            
            return theAnimation;
        }
        
        return super.actionForKey(key);
    }
}
