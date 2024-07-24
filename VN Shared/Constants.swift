//
//  Constants.swift
//  VN
//
//  Created by Maarten Engels on 21/10/2020.
//

import Foundation

let INK_FILE_NAME = "test.ink"


import SwiftUI

func registerFonts() {
    let fontNames = ["AmericanTypewriter.ttf"]
    fontNames.forEach { fontName in
        guard let url = Bundle.main.url(forResource: fontName, withExtension: nil),
              let dataProvider = CGDataProvider(url: url as CFURL),
              let font = CGFont(dataProvider) else {
            print("Failed to load font: \(fontName)")
            return
        }
        
        var error: Unmanaged<CFError>?
        if !CTFontManagerRegisterGraphicsFont(font, &error) {
            print("Error registering font: \(error.debugDescription)")
        }
    }
}
extension Font {
    static func storyFont(size: CGFloat) -> Font {
        return Font.system(size: size, weight: .regular, design: .serif)
    }
    
    static func buttonFont(size: CGFloat) -> Font {
        return Font.system(size: size, weight: .medium, design: .default)
    }
    
    static let storyText = storyFont(size: 22)
    static let storyTextLarge = storyFont(size: 26)
    static let buttonText = buttonFont(size: 18)
}
