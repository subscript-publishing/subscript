//
//  UITextView.swift
//  AcademicML
//
//  Created by Colbyn Wadman on 8/10/22.
//

import UIKit

extension UITextView {
    func getLineString() -> String {
        guard let text = text else { return "" }
        return (text as NSString).substring(with: (text as NSString).lineRange(for: self.selectedRange))
    }
    
    func characterBeforeCursor() -> String? {
        // get the cursor position
        if let cursorRange = self.selectedTextRange {

            // get the position one character before the cursor start position
            if let newPosition = self.position(from: cursorRange.start, offset: -1) {

                let range = self.textRange(from: newPosition, to: cursorRange.start)
                return self.text(in: range!)
            }
        }
        return nil
    }
    
    func characterAfterCursor() -> String? {
        if let cursorRange = self.selectedTextRange {
            if let newPosition = self.position(from: cursorRange.start, offset: 1) {
                let range = self.textRange(from: newPosition, to: cursorRange.start)
                return self.text(in: range!)
            }
        }
        return nil
    }
}


