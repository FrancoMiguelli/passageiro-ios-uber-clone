//
//  JosefinFont.swift
//  PassengerApp
//
//  Created by Marlon da Rocha on 28/01/2019.
//  Copyright © 2019 V3Cube. All rights reserved.
//

import UIKit
public struct JosefinFont: FontType {
    /// Size of font.
    public static var pointSize: CGFloat {
        return Font.pointSize
    }
    
    /// Thin font.
    public static var thin: UIFont {
        return thin(with: Font.pointSize)
    }
    
    /// Light font.
    public static var light: UIFont {
        return light(with: Font.pointSize)
    }
    
    /// Regular font.
    public static var regular: UIFont {
        return regular(with: Font.pointSize)
    }
    
    /// Medium font.
    public static var medium: UIFont {
        return medium(with: Font.pointSize)
    }
    
    /// Bold font.
    public static var bold: UIFont {
        return bold(with: Font.pointSize)
    }
    
    /**
     Thin with size font.
     - Parameter with size: A CGFLoat for the font size.
     - Returns: A UIFont.
     */
    public static func thin(with size: CGFloat) -> UIFont {
        Font.loadFontIfNeeded(name: "JosefinSans-Thin")
        
        if let f = UIFont(name: "JosefinSans-Thin", size: size) {
            return f
        }
        
        return Font.systemFont(ofSize: size)
    }
    
    /**
     Light with size font.
     - Parameter with size: A CGFLoat for the font size.
     - Returns: A UIFont.
     */
    public static func light(with size: CGFloat) -> UIFont {
        Font.loadFontIfNeeded(name: "JosefinSans-Light")
        
        if let f = UIFont(name: "JosefinSans-Light", size: size) {
            return f
        }
        
        return Font.systemFont(ofSize: size)
    }
    
    /**
     Regular with size font.
     - Parameter with size: A CGFLoat for the font size.
     - Returns: A UIFont.
     */
    public static func regular(with size: CGFloat) -> UIFont {
        Font.loadFontIfNeeded(name: "JosefinSans-Light")
        
        if let f = UIFont(name: "JosefinSans-Light", size: size) {
            return f
        }
        
        return Font.systemFont(ofSize: size)
    }
    
    /**
     Medium with size font.
     - Parameter with size: A CGFLoat for the font size.
     - Returns: A UIFont.
     */
    public static func medium(with size: CGFloat) -> UIFont {
        Font.loadFontIfNeeded(name: "JosefinSans-SemiBold")
        
        if let f = UIFont(name: "JosefinSans-SemiBold", size: size) {
            return f
        }
        
        return Font.boldSystemFont(ofSize: size)
    }
    
    /**
     Bold with size font.
     - Parameter with size: A CGFLoat for the font size.
     - Returns: A UIFont.
     */
    public static func bold(with size: CGFloat) -> UIFont {
        Font.loadFontIfNeeded(name: "JosefinSans-Bold")
        
        if let f = UIFont(name: "JosefinSans-Bold", size: size) {
            return f
        }
        
        return Font.boldSystemFont(ofSize: size)
    }
}

