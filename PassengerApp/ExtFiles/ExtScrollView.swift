//
//  ExtScrollView.swift
//  DriverApp
//
//  Created by ADMIN on 26/12/16.
//  Copyright © 2016 BBCS. All rights reserved.
//

import Foundation
import UIKit

extension UIScrollView{
    func setContentViewSize(offset:CGFloat = 0.0) {
        
        DispatchQueue.main.asyncAfter(deadline: .now() + 2) {
            self.showsHorizontalScrollIndicator = false
            self.showsVerticalScrollIndicator = false
            
            var maxHeight : CGFloat = 0
            for view in self.subviews {
                if view.isHidden {
                    continue
                }
                let newHeight = view.frame.origin.y + view.frame.height
                if newHeight > maxHeight {
                    maxHeight = newHeight
                }
            }
            
            // set content size
            self.contentSize = CGSize(width: self.contentSize.width, height: maxHeight + offset)
            
            // show scroll indicators
            self.showsHorizontalScrollIndicator = true
            self.showsVerticalScrollIndicator = true
        }
        
        
    }
    
    func setContentViewSize(offset:CGFloat = 0.0, currentHeight:CGFloat) {
        
        DispatchQueue.main.asyncAfter(deadline: .now() + 2) {
            self.showsHorizontalScrollIndicator = false
            self.showsVerticalScrollIndicator = false
            
            var maxHeight : CGFloat = 0
            for view in self.subviews {
                if view.isHidden {
                    continue
                }
                let newHeight = view.frame.origin.y + view.frame.height
                if newHeight > maxHeight {
                    maxHeight = newHeight
                }
            }
            
            if(maxHeight > currentHeight){
                // set content size
                self.contentSize = CGSize(width: self.contentSize.width, height: maxHeight + offset)
                
                // show scroll indicators
                self.showsHorizontalScrollIndicator = true
                self.showsVerticalScrollIndicator = true
            }
        }
        
    }
    
    func setContentViewSize(offset:CGFloat = 0.0, currentMaxHeight:CGFloat) {
        
        DispatchQueue.main.asyncAfter(deadline: .now() + 2) {
            self.showsHorizontalScrollIndicator = false
            self.showsVerticalScrollIndicator = false
            
            var maxHeight : CGFloat = 0
            for view in self.subviews {
                if view.isHidden {
                    continue
                }
                let newHeight = view.frame.origin.y + view.frame.height
                if newHeight > maxHeight {
                    maxHeight = newHeight
                }
            }
            
            if(maxHeight < currentMaxHeight){
                // set content size
                self.contentSize = CGSize(width: self.contentSize.width, height: maxHeight + offset)
                
                // show scroll indicators
                self.showsHorizontalScrollIndicator = true
                self.showsVerticalScrollIndicator = true
            }
        }
        
    }
    
    func scrollToTop() {
        let desiredOffset = CGPoint(x: 0, y: -contentInset.top)
        setContentOffset(desiredOffset, animated: false)
    }
    
    var isAtTop: Bool {
        return contentOffset.y <= verticalOffsetForTop
    }
    
    var isAtBottom: Bool {
        return contentOffset.y >= verticalOffsetForBottom
    }
    
    var verticalOffsetForTop: CGFloat {
        let topInset = contentInset.top
        return -topInset
    }
    
    var verticalOffsetForBottom: CGFloat {
        let scrollViewHeight = bounds.height
        let scrollContentSizeHeight = contentSize.height
        let bottomInset = contentInset.bottom
        let scrollViewBottomOffset = scrollContentSizeHeight + bottomInset - scrollViewHeight
        return scrollViewBottomOffset
    }
}
