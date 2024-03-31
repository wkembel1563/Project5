//
//  ViewController.swift
//  Project5
//
//  Created by Will Kembel on 3/26/24.
//

import UIKit

class ViewController: UITableViewController {
    
    var allWords = [String]()
    var usedWords = [String]()

    override func viewDidLoad() {
        super.viewDidLoad()
        
        // button to add anagrams
        //
        navigationItem.rightBarButtonItem = 
            UIBarButtonItem(barButtonSystemItem: .add, target: self, action: #selector(addWordTapped))
        navigationItem.leftBarButtonItem =
            UIBarButtonItem(title: "Clear", style: .plain, target: self, action: #selector(clearTapped))
        
        // load words
        //
        if let fileURL = Bundle.main.url(forResource: "start", withExtension: "txt") {
            if let fileContents = try? String(contentsOf: fileURL) {
                allWords = fileContents.components(separatedBy: "\n")
            }
        }
        
        // words not loaded
        //
        if allWords.isEmpty {
            allWords = ["silkworm"]
            
            let ac = 
            UIAlertController(title: "Error", message: "Word bank unable to load. Try again later.", preferredStyle: .alert)
            ac.addAction(UIAlertAction(title: "OK", style: .default))
            
            present(ac, animated: true)
            return
        }
        
        startGame()
    }
    
    func startGame() {
        title = allWords.randomElement()
        usedWords.removeAll(keepingCapacity: true)
        tableView.reloadData()
    }
    
    // setup tableview
    //
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return usedWords.count
    }
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "Word", for: indexPath)
        cell.textLabel?.text = usedWords[indexPath.row]
        return cell
    }
    
    // add anagrams to list
    //
    @objc func addWordTapped() {
        let ac = UIAlertController(title: "Enter Word", message: nil, preferredStyle: .alert)
        ac.addTextField()
        
        let submitFunction = {
            [weak self, weak ac] (_: UIAlertAction) in
            guard let word = ac?.textFields?[0].text else { return }
            self?.submit(word.lowercased())
        }
        
        ac.addAction(UIAlertAction(title: "Submit", style: .default, handler: submitFunction))
        
        present(ac, animated: true)
    }
    func submit(_ word: String) {
        var validationFailed = false
        var errorTitle = ""
        var errorMsg = ""
        
        if !isReal(word) {
            validationFailed = true
            errorTitle = "Not Real Word"
            errorMsg = "You can't just make shit up you know."
        }
        else if !isOriginal(word) {
            validationFailed = true
            errorTitle = "Word Reused"
            errorMsg = "Can only use a word once. You thought it would be that easy?"
        }
        else if !isAnagram(word) {
            validationFailed = true
            errorTitle = "Not An Anagram"
            errorMsg = "Word must be constructed using only the letters given in the prompt."
        }
        
        if validationFailed {
            let ac = UIAlertController(title: errorTitle, message: errorMsg, preferredStyle: .alert)
            ac.addAction(UIAlertAction(title: "OK", style: .default))
            present(ac, animated: true)
            return
        }
        
        usedWords.insert(word, at: 0)
        let indexPath = IndexPath(row: 0, section: 0)
        tableView.insertRows(at: [indexPath], with: .automatic)
    }
    
    // word must be real english, used only once, and a valid anagram
    //
    func isReal(_ word: String) -> Bool {
        let textChecker = UITextChecker()
        let wordRange = NSRange(location: 0, length: word.utf16.count)
        let mispelledRange =
            textChecker.rangeOfMisspelledWord(in: word, range: wordRange, startingAt: 0, wrap: false, language: "en")
        
        return mispelledRange.location == NSNotFound
    }
    func isOriginal(_ word: String) -> Bool  {
        return !usedWords.contains(word)
    }
    func isAnagram(_ word: String) -> Bool  {
        guard var tempPrompt = title else { return false }
        
        // check each letter is in prompt
        // remove letters from prompt as you go to account for letter reuse
        for letter in word {
            if let letterLocation = tempPrompt.firstIndex(of: letter) {
                tempPrompt.remove(at: letterLocation)
            }
            else {
                return false
            }
        }
        return true
    }
    
    // clear words from table
    //
    @objc func clearTapped() {
        usedWords.removeAll(keepingCapacity: true)
        tableView.reloadData()
    }
    
}

