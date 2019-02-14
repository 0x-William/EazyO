//
//  CardManager.swift
//  Eazyo
//
//  Created by SoftDev0420 on 5/24/16.
//  Copyright © 2016 SoftDev0420. All rights reserved.
//

class CardManager {
    static let instance = CardManager()
    
    var clientToken: String?
    var cards = [[String : Any]]()
    var selectedCardIndex: Int = -1
    
    init() {
        let userDefaults = UserDefaults.standard
        selectedCardIndex = userDefaults.integer(forKey: "selectedPaymentIndex")
        cards = [[String : Any]]()
    }
    
    func setClientToken(_ token: String?) {
        clientToken = token
    }
    
    func getCardCount() -> Int {
        return cards.count
    }
    
    func addCard(_ card: [String : Any]) {
        cards.append(card)
    }
    
    func getSelectedCard() -> [String : Any] {
        return cards[selectedCardIndex]
    }
    
    func removeCardWithIndex(_ index: Int) {
        if (selectedCardIndex == index) {
            setSelectedCardIndex(-1)
        }
        else if (selectedCardIndex > index) {
            setSelectedCardIndex(selectedCardIndex - 1)
        }
        
        cards.remove(at: index)
    }
    
    func removeCard(_ deletedCard: [String : Any]) {
        for (index, card) in cards.enumerated() {
            if (card["uuid"] as! String == deletedCard["uuid"] as! String) {
                removeCardWithIndex(index)
                break
            }
        }
    }
    
    func updateCard(_ cardIndex: Int, newCard: [String : Any]) {
        cards[cardIndex] = newCard
    }
    
    func setSelectedCardIndex(_ index: Int) {
        selectedCardIndex = index
        let userDefaults = UserDefaults.standard
        userDefaults.set(index, forKey: "selectedPaymentIndex")
    }
    
    func getSelectedCardIndex() -> Int {
        return selectedCardIndex
    }
    
    func clearCardData() {
        cards.removeAll()
        clientToken = ""
        setSelectedCardIndex(-1)
    }
}
