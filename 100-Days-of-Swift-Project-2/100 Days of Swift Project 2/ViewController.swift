//
//  ViewController.swift
//  100 Days of Swift Project 2
//
//  Created by Seb Vidal on 11/11/2021.
//

import UIKit
import UserNotifications

class ViewController: UIViewController {
    
    @IBOutlet var button1: UIButton!
    @IBOutlet var button2: UIButton!
    @IBOutlet var button3: UIButton!
    @IBOutlet var label1: UILabel!
    
    var countries: [String] = []
    var score = 0
    var correctAnswer = 0
    var askedQuestions = 0
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Do any additional setup after loading the view.
        countries = ["estonia", "france", "germany", "ireland", "italy", "monaco", "nigeria", "poland", "russia", "spain", "uk", "us"]
        
        applyCornerRadius(to: [button1, button2, button3])
        applyStroke(to: [button1, button2, button3])
        askQuestion()
        setScoreLabel()
        registerNotifications()
        scheduleNotifications()
    }
    
    @IBAction func buttonTapped(_ button: UIButton) {
        var title: String
        var message: String
        
        if button.tag == correctAnswer {
            score += 1
            title = "Correct"
            message = "Your score is \(score)."
        } else {
            score -= 1
            title = "Wrong"
            message = "That's the flag of \(countries[button.tag].countryCase()). Your score is \(score)."
        }
        
        setScoreLabel()
        
        let ac = UIAlertController(title: title, message: message, preferredStyle: .alert)
        ac.addAction(UIAlertAction(title: "Continue", style: .default, handler: askQuestion))
        present(ac, animated: true)
    }
    
    func setScoreLabel() {
        let label = UILabel()
        label.text = "Score: \(score)"
        label.textColor = .secondaryLabel
        navigationItem.rightBarButtonItem = UIBarButtonItem(customView: label)
    }
    
    func applyStroke(to buttons: [UIButton]) {
        for button in buttons {
            button.layer.borderWidth = 1
            button.layer.borderColor = UIColor.lightGray.cgColor
        }
    }
    
    func applyCornerRadius(to buttons: [UIButton]) {
        for button in buttons {
            button.layer.cornerCurve = .continuous
            button.layer.cornerRadius = 10
            button.clipsToBounds = true
        }
    }
    
    func askQuestion(action: UIAlertAction! = nil) {
        if askedQuestions == 10 {
            endGame()
            return
        }
        
        countries.shuffle()
        askedQuestions += 1
        
        button1.setImage(UIImage(named: countries[0]), for: .normal)
        button2.setImage(UIImage(named: countries[1]), for: .normal)
        button3.setImage(UIImage(named: countries[2]), for: .normal)
        
        correctAnswer = Int.random(in: 0...2)
        
        setTitle()
    }
    
    func setTitle() {
        title = countries[correctAnswer].countryCase()
    }
    
    func endGame() {
        button1.isHidden = true
        button2.isHidden = true
        button3.isHidden = true
        label1.isHidden = false
        title = ""
    }
    
    func registerNotifications() {
        let center = UNUserNotificationCenter.current()
        center.requestAuthorization(options: [.alert, .badge, .sound]) { allowed, error in
            if allowed {
                print("Allowed")
            } else {
                print("Denied")
            }
        }
    }
    
    func scheduleNotifications() {
        let center = UNUserNotificationCenter.current()
        center.removeAllPendingNotificationRequests()
        
        let content = UNMutableNotificationContent()
        content.title = "Flags Game"
        content.body = "Come back and play for good this time..."
        content.categoryIdentifier = "reminder"
        
        var dateComponents = DateComponents()
        dateComponents.hour = 8
        dateComponents.minute = 0
        
        let trigger = UNCalendarNotificationTrigger(dateMatching: dateComponents, repeats: true)
        let request = UNNotificationRequest(identifier: "reminder", content: content, trigger: trigger)
        
        center.add(request)
    }
    
}

extension ViewController: UNUserNotificationCenterDelegate {
    func userNotificationCenter(_ center: UNUserNotificationCenter, didReceive response: UNNotificationResponse, withCompletionHandler completionHandler: @escaping () -> Void) {
        let identifier = response.notification.request.content.categoryIdentifier
        if identifier == "reminder" {
            let center = UNUserNotificationCenter.current()
            center.removeAllPendingNotificationRequests()
        }
    }
}

extension String {
    func countryCase() -> String {
        if self.count <= 2 {
            return self.uppercased(with: .current)
        } else{
            return self.capitalized
        }
    }
}
