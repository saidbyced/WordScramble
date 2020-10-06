//
//  Extensions.swift
//  WordScramble-UIKit
//
//  Created by Chris Eadie on 06/10/2020.
//

import Foundation

extension String {
    func isValid(for givenWord: String) -> Bool {
        if self.count < 4 || self == givenWord {
            return false
        }
        
        return true
    }
    
    func isOriginal(in usedWords: [String]) -> Bool {
        return !usedWords.contains(self)
    }
    
    func isPossible(for givenWord: String) -> Bool {
        var tempWord = givenWord.lowercased()
        
        for letter in tempWord {
            if let position = tempWord.firstIndex(of: letter) {
                tempWord.remove(at: position)
            } else {
                return false
            }
        }
        
        return true
    }
    
    func isReal() -> Bool {
        let checker = UITextChecker()
        let range = NSRange(location: 0, length: self.utf16.count)
        let misspelledRange = checker.rangeOfMisspelledWord(in: self, range: range, startingAt: 0, wrap: false, language: "en")
        
        return misspelledRange.location == NSNotFound
    }
}
