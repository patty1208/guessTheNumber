//
//  ViewController.swift
//  guessTheNumber
//
//  Created by 林佩柔 on 2021/3/3.
//

import UIKit
import AVFoundation

class ViewController: UIViewController {
    
    var chances: Int = 5
    var smallNumber: Int = 0
    var bigNumber: Int = 100
    var answer = Int.random(in: 1 ... 99)
    var guessNumberForText = ""
    var guessNumber = 0
    
    var timer: Timer?
    
    var countDown: Int = 60
    
    var playerCountDown: AVPlayer?
    var playerGuess: AVPlayer?
    
    @IBOutlet weak var explosionBackground: UIView! // 遮蓋爆炸圖下的其他畫面,只剩reset按鍵
    @IBOutlet weak var explosionImage: UIImageView!
    @IBOutlet weak var guessStateImage: UIImageView!
    @IBOutlet weak var guessNumberLabel: UILabel!
    @IBOutlet weak var descriptionLabel: UILabel!
    @IBOutlet weak var alertLabel: UILabel!
    
    @IBOutlet weak var countdownLabel: UILabel!
    
    @IBOutlet var numberButtons: [UIButton]! // 數字鍵 1...9,0
    @IBOutlet var otherButtons: [UIButton]! // del, enter, reset鍵
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // 按鍵樣式(不含reset按鍵)
        for i in numberButtons + otherButtons[0...1]{
            i.layer.borderWidth = 2
            i.layer.borderColor = UIColor.darkGray.cgColor
            //            i.layer.shadowOpacity = 0.3
            i.layer.cornerRadius = 5
            
            //            i.layer.shadowColor = UIColor.darkGray.cgColor
            //            i.layer.shadowPath = UIBezierPath(rect: i.bounds).cgPath
            //            i.layer.shadowRadius = 10
            //            i.layer.shadowOffset = .zero
            //            i.layer.shadowOpacity = 1
            
        }
        initialValue()
        resetCountDown()
    }
    
    //    override func viewDidDisappear(_ animated: Bool) {
    //        stopCountDown()
    //    }
    
    func labelTextStyle(label: UILabel) {
        let attributedString = NSMutableAttributedString(string: label.text!)
        
        if label == descriptionLabel {
            attributedString.setAttributes([.font: UIFont(name: "Chalkduster", size: 18.0)!, .foregroundColor: UIColor.red], range: NSMakeRange(9, 1))
            attributedString.setAttributes([.font: UIFont(name: "Chalkduster", size: 18.0)!, .foregroundColor: UIColor.red], range: NSMakeRange(label.text!.count - 4 - String(smallNumber).count - String(bigNumber).count, String(smallNumber).count))
            attributedString.setAttributes([.font: UIFont(name: "Chalkduster", size: 18.0)!, .foregroundColor: UIColor.red], range: NSMakeRange(label.text!.count - String(bigNumber).count, String(bigNumber).count))
        } else if label == alertLabel && label.text!.contains("Del") {
            if label.text != ""{
                attributedString.setAttributes([.font: UIFont(name: "Chalkduster", size: 18.0)!, .foregroundColor: UIColor.red], range: NSMakeRange(11, 1))
                attributedString.setAttributes([.font: UIFont(name: "Chalkduster", size: 18.0)!, .foregroundColor: UIColor.red], range: NSMakeRange(label.text!.count - 5, 3))
            }
        } else if label == alertLabel && (label.text!.contains("\(smallNumber)") || label.text!.contains("\(bigNumber)")) {
            var tempNumber = guessNumber
            if guessNumber <= smallNumber {
                tempNumber = smallNumber
            } else if guessNumber >= smallNumber {
                tempNumber = bigNumber
            }
            attributedString.setAttributes([.font: UIFont(name: "Chalkduster", size: 18.0)!, .foregroundColor: UIColor.red], range: NSMakeRange(label.text!.count - 14 - String(tempNumber).count, String(tempNumber).count + 14))
        }
        label.attributedText = attributedString
    }
    
    func explosionAnimationImage() {
        explosionBackground.alpha = 1
        UIViewPropertyAnimator.runningPropertyAnimator(withDuration: 1, delay: 0, animations: {
            self.explosionImage.alpha  = 0.8
        }, completion: nil)
        UIViewPropertyAnimator.runningPropertyAnimator(withDuration: 0.5, delay: 1, animations: {
            self.explosionImage.alpha  = 0.4
        }, completion: nil)
    }
    
    func playSoundEffect(state: String){
        
        // 猜錯猜對狀態
        if state == "wrong" {
            if let url = Bundle.main.url(forResource: "wrongSoundEffect", withExtension: "mp3"){
                self.playerGuess = AVPlayer(url: url)
                self.playerGuess?.volume = 0.05
                self.playerGuess?.play()
            }
        } else if state == "correct" {
            if let url = Bundle.main.url(forResource: "correctSoundEffect", withExtension: "mp3"){
                self.playerGuess = AVPlayer(url: url)
                self.playerGuess?.volume = 0.05
                self.playerGuess?.play()
            }
        }
        
        // 倒數計時器狀態
        if state == "countDown"{
            if let url = Bundle.main.url(forResource: "countDownForOneSecond", withExtension: "mp3"){
                self.playerCountDown = AVPlayer(url: url)
                self.playerCountDown?.volume = 0.05
                self.playerCountDown?.play()
            }
        } else if state == "bomb" {
            if let url = Bundle.main.url(forResource: "bombSoundEffect", withExtension: "mp3"){
                self.playerCountDown = AVPlayer(url: url)
                self.playerCountDown?.volume = 0.1
                self.playerCountDown?.play()
            }
        }
    }
    
    func countDownNumber(){ // 倒數計時炸彈 顯示時間文字和倒數聲音, 爆炸畫面和聲音
        // 倒數計時炸彈 顯示時間文字
        if self.countDown >= 10 {
            self.countdownLabel.text = String("00 : \(self.countDown)")}
        else if self.countDown >= 0{
            self.countdownLabel.text = String("00 : 0\(self.countDown)")
        }
        
        // 倒數計時炸彈 倒數聲和爆炸聲 和爆炸後停止倒數
        if self.countDown >= 0 {
            playSoundEffect(state: "countDown")
        } else if self.countDown == -1 {
            stopCountDown()
            playSoundEffect(state: "bomb")
            explosionAnimationImage()
        }
        self.countDown = self.countDown - 1
    }
    
    
    func stopCountDown(){
        timer?.invalidate()
    }
    
    func resetCountDown(){
        stopCountDown()
        timer = Timer.scheduledTimer(withTimeInterval: 1, repeats: true) { (_) in
            self.countDownNumber()
        }
    }
    
    func initialValue(){
        chances = 5
        smallNumber = 0
        bigNumber = 100
        answer = Int.random(in: smallNumber + 1 ... bigNumber - 1)
        
        guessNumberForText = ""
        guessNumber = 0
        
        countDown = 60
        
        alertLabel.text = ""
        descriptionLabel.text = "You have \(chances)  chances.\n\(smallNumber) to \(bigNumber)"
        labelTextStyle(label:descriptionLabel)
        guessNumberLabel.text = ""
        guessStateImage.isHidden = false
        guessStateImage.image = UIImage(named: "question")
        countdownLabel.text = "00 : \(countDown)"
        explosionImage.alpha = 0
        explosionBackground.alpha = 0
        
    }
    
    @IBAction func saveGuessNumber(_ sender: UIButton) {
        let pressNumber = sender.titleLabel?.text ?? ""
        
        if chances >= 1 {
            
            if guessNumberForText.count < 2 {
                alertLabel.text = ""
                // 改變猜的數值
                if guessNumberForText == "" {
                    guessNumberForText = pressNumber
                } else {
                    guessNumberForText = guessNumberForText + pressNumber
                }
                // 改變畫面呈現
                guessStateImage.isHidden = true
                guessNumberLabel.text = guessNumberForText
            } else if guessNumberForText.count == 2 {
                alertLabel.text = "Allow only 2 numbers.\nIn order to modify your numbers,\nyou can press 'Del'."
                labelTextStyle(label: alertLabel)
            }
        }
    }
    
    @IBAction func deleteGuessNumber(_ sender: UIButton) {
        if guessNumberForText != "" {
            guessNumberForText =
                String(guessNumberForText.prefix(guessNumberForText.count - 1))
            alertLabel.text = ""
            guessNumberLabel.text = guessNumberForText
        }
    }
    
    @IBAction func enterGuessNumber(_ sender: UIButton) {
        guessNumber = Int(guessNumberForText) ?? 0
        
        if chances >= 1 {
            if guessNumber != answer && guessNumberForText != "" {
                chances = chances - 1
                
                if chances == 0 {
                    playSoundEffect(state: "bomb")
                    explosionAnimationImage()
                    stopCountDown()
                } else {
                    playSoundEffect(state: "wrong")
                    if guessNumber <= smallNumber {
                        alertLabel.text = "You lose a chance.\nPlease input a number greater than \(smallNumber)."
                        labelTextStyle(label: alertLabel)
                    } else if guessNumber >= bigNumber {
                        alertLabel.text = "You lose a chance.\nPlease input a number smaller than \(bigNumber)."
                        labelTextStyle(label: alertLabel)
                    } else if guessNumber < answer {
                        alertLabel.text = ""
                        smallNumber = guessNumber
                    } else if guessNumber > answer {
                        alertLabel.text = ""
                        bigNumber = guessNumber
                    }
                }
                guessStateImage.isHidden = false
                guessStateImage.image = UIImage(named: "cancel")
                
                if chances > 1 {
                    descriptionLabel.text = "You have \(chances)  chances.\n\(smallNumber) to \(bigNumber)"
                } else {
                    descriptionLabel.text = "You have \(chances)  chance.\n\(smallNumber) to \(bigNumber)"
                }
                
                labelTextStyle(label: descriptionLabel)
                
            } else if guessNumber == answer{
                alertLabel.text = ""
                guessStateImage.isHidden = false
                guessStateImage.image = UIImage(named: "checked")
                stopCountDown()
                playSoundEffect(state: "correct")
            } else if guessNumberForText == "" { }
        }
        guessNumberForText = ""
    }
    @IBAction func resetBomb(_ sender: UIButton) {
        initialValue()
        resetCountDown()
    }
}

