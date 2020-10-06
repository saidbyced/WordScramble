//
//  Words.swift
//  WordScramble-UIKit
//
//  Created by Chris Eadie on 06/10/2020.
//

import Foundation

class Words {
    var all: [String] = ["silkworm"]
    var current: String = "silkworm"
    var used = [String]()
    
    init() {
        if let startWordsURL = Bundle.main.url(forResource: "start", withExtension: "txt") {
            if let startWords = try? String(contentsOf: startWordsURL) {
                let allWords = startWords.components(separatedBy: "\n")
                
                self.all = allWords
                self.current = allWords.randomElement()!.lowercased()
            }
        }
    }
    
    func refresh() {
        if let new = all.randomElement()?.lowercased() {
            current = new
        }
        
        used.removeAll(keepingCapacity: true)
    }
}
