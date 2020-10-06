//
//  Words.swift
//  WordScramble-UIKit
//
//  Created by Chris Eadie on 06/10/2020.
//

import Foundation

struct Words {
    var all: [String]
    var used: [String]
    
    init() {
        self.used = [String]()
        
        if let startWordsURL = Bundle.main.url(forResource: "start", withExtension: "txt") {
            if let startWords = try? String(contentsOf: startWordsURL) {
                self.all = startWords.components(separatedBy: "\n")
                return
            }
        }
        
        self.all = ["silkworm"]
    }
}
