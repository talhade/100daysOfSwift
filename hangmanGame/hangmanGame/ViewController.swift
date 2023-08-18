//
//  ViewController.swift
//  hangmanGame
//
//  Created by Talha Demirkan on 18.08.2023.
//

import UIKit

class ViewController: UIViewController {
    
    var allWords = [String]()
    var chosenWord = ""
    var life = 7
    var usedLetters = [String]()

    var prompt = "" {
        didSet{
            wordLabel.text = prompt
            
        }
    }

    @IBOutlet var textField: UITextField!
    @IBOutlet var wordLabel: UILabel!
    @IBOutlet var submitButton: UIButton!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        navigationItem.rightBarButtonItem = UIBarButtonItem(barButtonSystemItem: .refresh, target: self, action: #selector(startGame))
        
        if let startWordsUrl = Bundle.main.url(forResource: "start", withExtension: "txt"){
            if let startWords = try? String(contentsOf: startWordsUrl){
                allWords = startWords.components(separatedBy: "\n")
            }
        }
        
        if allWords.isEmpty{
            allWords = ["silkworm"]
        }
        
        startGame()
    }
    
    @objc func startGame(){
        chosenWord = allWords.randomElement()!
        life = 7
        print(chosenWord)
        usedLetters = []
        prompt = ""
        for letter in chosenWord {
            let strLetter = String(letter)

            if usedLetters.contains(strLetter) {
                prompt += strLetter
            } else {
                prompt += "? "
            }
        }
        
        
    }
    
    @IBAction func submitTapped(_ sender: Any) {
        if prompt.contains("?"){
            guard let answer = textField.text?.lowercased() else { return }
            if answer.count != 1 {
                showAC(title: "OOPS", message: "Enter a valid answer")
            }
            
            if !usedLetters.contains(answer){
                usedLetters.append(answer)
                prompt = ""

                for letter in chosenWord {
                    let strLetter = String(letter)

                    if usedLetters.contains(strLetter) {
                        prompt += strLetter
                    } else {
                        prompt += "? "
                    }
                    
                }
                
            }else{
                life -= 1
                print(life)
                if life == 0{
                    let ac = UIAlertController(title: "Try Again", message: "You are out of your life. The word was \(chosenWord)", preferredStyle: .alert)
                    let action = UIAlertAction(title: "OK", style: .default) { alertAction in
                        self.startGame()
                    }
                    ac.addAction(action)
                    present(ac, animated: true)
                
                }
            }
            textField.text = ""
        }else{
            let ac = UIAlertController(title: "You Won", message: "You succesfully found \(chosenWord).", preferredStyle: .alert)
            let action = UIAlertAction(title: "OK", style: .default) { alertAction in
                self.startGame()
            }
            ac.addAction(action)
            present(ac, animated: true)
        }
        
    }
    
    func showAC(title: String, message: String){
        let ac = UIAlertController(title: title, message: message, preferredStyle: .alert)
        let action = UIAlertAction(title: "OK", style: .default)
        ac.addAction(action)
        present(ac, animated: true)
    }
    
    


}

