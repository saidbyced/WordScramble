//
//  WordScrambleViewController.swift
//  WordScramble-UIKit
//
//  Created by Chris Eadie on 30/09/2020.
//

import UIKit

class WordScrambleViewController: UITableViewController {
    
    var allWords = [String]()
    var usedWords = [String]()

    override func viewDidLoad() {
        super.viewDidLoad()
        navigationItem.rightBarButtonItem = UIBarButtonItem(barButtonSystemItem: .add, target: self, action: #selector(promptForAnswer))
        loadWords()
        startGame()
    }
    
    func loadWords() {
        if let startWordsURL = Bundle.main.url(forResource: "start", withExtension: "txt") {
            if let startWords = try? String(contentsOf: startWordsURL) {
                allWords = startWords.components(separatedBy: "\n")
            }
        }
        
        if allWords.isEmpty {
            allWords = ["silkworm"]
        }
    }
    
    func startGame() {
        title = allWords.randomElement()
        usedWords.removeAll(keepingCapacity: true)
        tableView.reloadData()
    }
    
    override func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return usedWords.count
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "usedWord", for: indexPath)
        cell.textLabel?.text = usedWords[indexPath.row]
        
        return cell
    }
    
    @objc func promptForAnswer() {
        let ac = UIAlertController(title: "Enter anagram", message: nil, preferredStyle: .alert)
        ac.addTextField()
        
        let submitAction = UIAlertAction(title: "Submit", style: .default) { [weak self, weak ac] action in
            guard let answer = ac?.textFields?[0].text else { return }
            self?.submit(answer)
        }
        
        ac.addAction(submitAction)
        present(ac, animated: true)
    }
    
    func submit(_ answer: String) {
        let lowerAnswer = answer.lowercased()
        var error: SubmissionError?
        
        enum SubmissionError {
            case notValid, notOriginal, notPossible, notReal
            
            var title: String {
                switch self {
                case .notValid:
                    return "Word not valid"
                case .notOriginal:
                    return "Word used already"
                case .notPossible:
                    return "Word not possible"
                case .notReal:
                    return "Word not recognised"
                }
            }
            var message: String {
                switch self {
                case .notValid:
                    return "Must be longer than 3 letters\nand not the given word!"
                case .notOriginal:
                    return "Be more original!"
                case .notPossible:
                    return "You can't spell that word from \(title)"
                case .notReal:
                    return "You can't just make them up, you know!"
                }
            }
        }
        
        if isValid(word: answer) {
            if isOriginal(word: answer) {
                if isPossible(word: answer) {
                    if isReal(word: answer) {
                        error = nil
                        usedWords.insert(lowerAnswer, at: 0)
                        
                        let indexPath = IndexPath(row: 0, section: 0)
                        tableView.insertRows(at: [indexPath], with: .top)
                        
                        return
                    } else {
                        error = .notReal
                    }
                } else {
                    error = .notPossible
                }
            } else {
                error = .notOriginal
            }
        } else {
            error = .notValid
        }
        
        let ac = UIAlertController(title: error?.title, message: error?.message, preferredStyle: .alert)
        let action = UIAlertAction(title: "OK", style: .default)
        ac.addAction(action)
        present(ac, animated: true)
    }
    
    func isValid(word: String) -> Bool {
        if word.count < 4 || word == title {
            return false
        }
        
        return true
    }
    
    func isOriginal(word: String) -> Bool {
        return !usedWords.contains(word)
    }
    
    func isPossible(word: String) -> Bool {
        guard var tempWord = title?.lowercased() else { return false }
        
        for letter in tempWord {
            if let position = tempWord.firstIndex(of: letter) {
                tempWord.remove(at: position)
            } else {
                return false
            }
        }
        
        return true
    }
    
    func isReal(word: String) -> Bool {
        let checker = UITextChecker()
        let range = NSRange(location: 0, length: word.utf16.count)
        let misspelledRange = checker.rangeOfMisspelledWord(in: word, range: range, startingAt: 0, wrap: false, language: "en")
        
        return misspelledRange.location == NSNotFound
    }
}
