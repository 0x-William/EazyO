//
//  TextFieldPattern.swift
//  Eazyo
//
//  Created by Michael Martinez on 8/2/16.
//  Copyright © 2016 SoftDev0420. All rights reserved.
//

import UIKit

class TextFieldPattern: UITextField {
    
    @IBInspectable var formattingPattern:String!
    
    var replacementChar: Character = "*"
    var maxLength = 0
    var secureTextReplacementChar: Character = "\u{25cf}"
    private var _formatedSecureTextEntry = false
    
    private var _textWithoutSecureBullets = ""


    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        registerForNotifications()
    }
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        registerForNotifications()
    }
    
    deinit {
        NotificationCenter.default.removeObserver(self)
    }
    
    private func registerForNotifications() {
        NotificationCenter.default.addObserver(self, selector: #selector(self.textDidChange), name: NSNotification.Name(rawValue: "UITextFieldTextDidChangeNotification"), object: self)
    }
    
    func setFormatting(formattingPattern: String, replacementChar: Character) {
        self.formattingPattern = formattingPattern
        self.replacementChar = replacementChar
    }
    
    override var text: String! {
        set {
            super.text = newValue
            textDidChange() // format string properly even when it's set programatically
        }
        
        get {
            return super.text
        }
    }
    
    func makeOnlyDigitsString(string: String) -> String {
        let stringArray = string.components(separatedBy: NSCharacterSet.decimalDigits.inverted)
        let allNumbers = stringArray.joined(separator: "")
        return allNumbers
    }
    
    func textDidChange() {
        
        // TODO: - Isn't there more elegant way how to do this?
        let currentTextForFormatting: String
        
        if (super.text?.characters.count)! > _textWithoutSecureBullets.characters.count {
            currentTextForFormatting = _textWithoutSecureBullets + super.text!.substring(from: super.text!.index(super.text!.startIndex, offsetBy: _textWithoutSecureBullets.characters.count))
        } else if super.text?.characters.count == 0 {
            _textWithoutSecureBullets = ""
            currentTextForFormatting = ""
        } else {
            currentTextForFormatting = _textWithoutSecureBullets.substring(to: _textWithoutSecureBullets.index(_textWithoutSecureBullets.startIndex, offsetBy: super.text!.characters.count))
        }
        
        if currentTextForFormatting.characters.count > 0 && formattingPattern.characters.count > 0 {
            let tempString = self.makeOnlyDigitsString(string: currentTextForFormatting)
            
            var finalText = ""
            var finalSecureText = ""
            
            var stop = false
            
            var formatterIndex = formattingPattern.startIndex
            var tempIndex = tempString.startIndex
            
            while !stop {
                let formattingPatternRange = formatterIndex ..< formattingPattern.index(formatterIndex, offsetBy: 1)
                if formattingPattern.substring(with: formattingPatternRange) != String(replacementChar) {
                    finalText = finalText.appending(formattingPattern.substring(with: formattingPatternRange))
                    finalSecureText = finalSecureText.appending(formattingPattern.substring(with: formattingPatternRange))
                } else if tempString.characters.count > 0 {
                    let pureStringRange = tempIndex ..< tempString.index(tempIndex, offsetBy: 1)
                    
                    finalText = finalText.appending(tempString.substring(with: pureStringRange))
                    
                    // we want the last number to be visible
                    if tempString.index(tempIndex, offsetBy: 1) == tempString.endIndex {
                        finalSecureText = finalSecureText.appending(tempString.substring(with: pureStringRange))
                    } else {
                        finalSecureText = finalSecureText.appending(String(secureTextReplacementChar))
                    }
                    
                    tempIndex = tempString.index(after: tempIndex)
                }
                
                formatterIndex = formattingPattern.index(after: formatterIndex)
                
                if formatterIndex >= formattingPattern.endIndex || tempIndex >= tempString.endIndex {
                    stop = true
                }
            }
            
            _textWithoutSecureBullets = finalText
            super.text = _formatedSecureTextEntry ? finalSecureText : finalText
        }
        
        // Let's check if we have additional max length restrictions
        if maxLength > 0 {
            if text.characters.count > maxLength {
                super.text =  text.substring(to: text.index(text.startIndex, offsetBy: maxLength))
                _textWithoutSecureBullets = _textWithoutSecureBullets.substring(to: _textWithoutSecureBullets.index(_textWithoutSecureBullets.startIndex, offsetBy: maxLength))
            }
        }
    }
}
