//
//  UIFont.swift
//  AcademicML
//
//  Created by Colbyn Wadman on 8/10/22.
//

#if os(iOS)
import UIKit

extension UIFont {
    static func monospacedFont(size: CGFloat) -> UIFont{
        let descriptor = UIFontDescriptor.preferredFontDescriptor(withTextStyle: .body)
            .withDesign(.monospaced)
        return UIFont(descriptor: descriptor!, size: size)
    }
}

#endif
