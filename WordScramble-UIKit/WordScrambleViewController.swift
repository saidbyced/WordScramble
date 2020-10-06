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
        navigationItem.leftBarButtonItem = UIBarButtonItem(barButtonSystemItem: .refresh, target: self, action: #selector(freshWord))
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
        title = allWords.randomElement()?.lowercased()
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
    
    @objc func freshWord() {
        startGame()
    }
    
    func submit(_ answer: String) {
        let answer = answer.lowercased()
        var error: SubmissionError?
        
        if answer.isValid(for: title!) {
            if answer.isOriginal(in: usedWords) {
                if answer.isPossible(for: title!) {
                    if answer.isReal() {
                        addWord(answer)
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
        
        guard let alert = error?.alert else { return }
        present(alert, animated: true)
    }
    
    func addWord(_ word: String) {
        usedWords.insert(word, at: 0)
        
        let indexPath = IndexPath(row: 0, section: 0)
        tableView.insertRows(at: [indexPath], with: .top)
    }
    
    enum SubmissionError {
        case notValid, notOriginal, notPossible, notReal
        
        var alert: UIAlertController {
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
                    return "Word must be longer than 3 letters\nand not the given word!"
                case .notOriginal:
                    return "Be more original!"
                case .notPossible:
                    return "You can't spell that word from \(title)"
                case .notReal:
                    return "You can't just make them up, you know!"
                }
            }
            
            let alert = UIAlertController(title: title, message: message, preferredStyle: .alert)
            let action = UIAlertAction(title: "OK", style: .default)
            alert.addAction(action)
            
            return alert
        }
    }
}

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
