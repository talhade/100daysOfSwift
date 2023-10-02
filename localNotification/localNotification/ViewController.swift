//
//  ViewController.swift
//  localNotification
//
//  Created by Talha Demirkan on 3.10.2023.
//

import UIKit
import UserNotifications

class ViewController: UIViewController, UNUserNotificationCenterDelegate {

    override func viewDidLoad() {
        super.viewDidLoad()
        
        navigationItem.leftBarButtonItem = UIBarButtonItem(title: "Register", style: .plain, target: self, action: #selector(registerLocal))
        navigationItem.rightBarButtonItem = UIBarButtonItem(title: "Schedule", style: .plain, target: self, action: #selector(scheduleLocal))
    }
    
    @objc func registerLocal(){
        let center = UNUserNotificationCenter.current()
        
        center.requestAuthorization(options: [.alert, .badge, .sound]){
            granted, error in
            if granted{
                print("yes")
            }else{
                print("no")
            }
        }
    }
    
    @objc func scheduleLocal(){
        registerCategories()
        
        let center = UNUserNotificationCenter.current()
        center.removeAllPendingNotificationRequests()
        
        let content = UNMutableNotificationContent()
        content.title = "Günaydın"
        content.body = "Uyanman gereken saati geçmek üzeresin hadi kalk!"
        content.categoryIdentifier = "alarm"
        content.sound = .default
        
        var dateComponent = DateComponents()
        dateComponent.hour = 10
        dateComponent.minute = 30
        //let trigger = UNCalendarNotificationTrigger(dateMatching: dateComponent, repeats: true)
        //test amaçlı
        let trigger = UNTimeIntervalNotificationTrigger(timeInterval: 5, repeats: false)
        
        let request = UNNotificationRequest(identifier: UUID().uuidString, content: content, trigger: trigger)
        center.add(request)
    }
    
    func registerCategories(){
        let center = UNUserNotificationCenter.current()
        center.delegate = self
        
        let show = UNNotificationAction(identifier: "more", title: "Uyku Bildirimi Hakkında Daha Fazla", options: .foreground)
        let category = UNNotificationCategory(identifier: "alarm", actions: [show], intentIdentifiers: [],options: [])
        center.setNotificationCategories([category])
    }


}

