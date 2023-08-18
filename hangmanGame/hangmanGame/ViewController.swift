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
    
    func startGame(){
        chosenWord = allWords.randomElement()!
        print(chosenWord)
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
        guard let answer = textField.text?.lowercased() else { return }
        if answer.count != 1 {
            print("unknown")
        }else if !usedLetters.contains(answer){
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
            
        }
    }
    
    


}

