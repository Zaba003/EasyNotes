//
//  String+Extensions.swift
//  MarkupEditor
//
//  Created by Steven Harris on 2/27/21.
//  Copyright © 2021 Steven Harris. All rights reserved.
//

import Foundation

extension String {
    
    /// A string with the ' characters in it escaped.
    /// Used when passing a string into JavaScript, so the string is not completed too soon
    public var escaped: String {
        let unicode = self.unicodeScalars
        var newString = ""
        for char in unicode {
            if char.value == 39 || // 39 == ' in ASCII
                char.value < 9 ||  // 9 == horizontal tab in ASCII
                (char.value > 9 && char.value < 32) // < 32 == special characters in ASCII
            {
                let escaped = char.escaped(asASCII: true)
                newString.append(escaped)
            } else {
                newString.append(String(char))
            }
        }
        return newString
    }
    
    /// Return true if self is a valid URL
    public var isValidURL: Bool {
        let detector = try! NSDataDetector(types: NSTextCheckingResult.CheckingType.link.rawValue)
        let matches = detector.matches(in: self, options: [], range: NSRange(location: 0, length: utf16.count))
        return matches.count == 1 && matches[0].range.length == utf16.count
    }
    
    /// Return a string with newlines inserted at the beginning of style, table, and div elements so it's minimally more readable.
    public var prettyHTML: String {
        var newString = replacingOccurrences(of: "<p", with: "\n<p")
        newString = newString.replacingOccurrences(of: "<h", with: "\n<h")
        newString = newString.replacingOccurrences(of: "<div", with: "\n<div")
        newString = newString.replacingOccurrences(of: "<table", with: "\n<table")
        return newString.trimmingCharacters(in: .whitespaces)
    }
    
}
