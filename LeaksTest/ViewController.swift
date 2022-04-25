//
//  ViewController.swift
//  LeaksTest
//
//  Created by Shevshelev Lev on 25.04.2022.
//

import UIKit

class ViewController: UIViewController {

    override func viewDidLoad() {
        super.viewDidLoad()
        let user = User(name: "Leo")
        let iPhone = Phone(model: "iPhone 13Pro Max")
        
        user.add(phone: iPhone)
        /* Создан цикл сильных ссылок - объект user имеет сильную ссылку на объект iPhone,
         и объект iPhone имеет сильную ссылку на объект user, для решения проблемы свойство
         owner класса Phone необходимо обозничить как weak
         */
        
        let subscription = CarrierSubscription(
            name: "Megafon",
            countryCode: "+7",
            number: "(982)485-56-23",
            user: user
        )
        /*
         Cитуация подобна предидущей, но между объектами user и subscription,
         для решения этой проблемы свойство user класса CarrierSubscription
         необходимо обозначить как unowned
         */
        print(subscription.completePhoneNumber())
        /*
         создан цикл сильных ссылок между объектом subscription и замыканием в свойстве
         completePhoneNumber, для решения проблемы в замыкании completePhoneNumber
         нужно определить список захвата конструкцией [unowned self] in в начале замыкания
         */
        iPhone.provision(carrierSubscription: subscription)
        /*
         Создание цикла сильных ссылок при назанчении делегата,
         для решения прблемы свойство delegate в классе CarrierSubscription
         необходимо обозначить как weak
         */
        let friend = User(name: "Artyom")
        user.friends.append(friend)
        friend.friends.append(user)
        /*
         Cоздан цикл сильных ссылок так как два объекта имеют ссылки друг на друга,
         но так как они содержаться в массивах стандартными средствами тут не решить проблему,
         для решения необходиом создать специальный класс дженерик и тип обектов
         содержащихся в массиве необходимо указать при помощи этого класса
         */
//        user.friends.append(Unowned(friend))
//        friend.friends.append(Unowned(user))
    }


}

class User {
    let name: String
    var friends: [User] = []
//    var friends: [Unowned<User>] = []
    var subscriptions: [CarrierSubscription] = []
    private(set) var phones: [Phone] = []
    init(name: String) {
        self.name = name
        print("User \(name) was initialized")
    }
    deinit {
        print("Deallocating user named: \(name)")
    }
    func add(phone: Phone) {
        phone.owner = self
        phones.append(phone)
    }
}

class Phone: CarrierSubscriptionProtocol {
    let model: String
    var owner: User?
//    weak var owner: User?
    var carrierSubscription: CarrierSubscription?
    init(model: String) {
        self.model = model
        print("Phone \(model) was initialized")
    }
    
    deinit {
        print("Deallocating phone named: \(model)")
    }
    
    func provision(carrierSubscription: CarrierSubscription) {
        self.carrierSubscription = carrierSubscription
        self.carrierSubscription?.delegate = self
    }
}

protocol CarrierSubscriptionProtocol: AnyObject {
    func provision(carrierSubscription: CarrierSubscription)
}

class CarrierSubscription {
    let name: String
    let countryCode: String
    let number: String
    let user: User
//    unowned let user: User
    var delegate: CarrierSubscriptionProtocol?
//    weak var delegate: CarrierSubscriptionProtocol?
    lazy var completePhoneNumber: () -> String = {
        [unowned self] in
        self.countryCode + " " + self.number
    }
    
    init(name: String, countryCode: String, number: String, user: User) {
        self.name = name
        self.countryCode = countryCode
        self.number = number
        self.user = user
        user.subscriptions.append(self)
        
        print("CarrierSubscription \(name) is initialized")
    }
    
    deinit {
        print("Deallocating CarrierSubscription named: \(name)")
    }
}

class Unowned<T: AnyObject> {
    unowned var value: T
    init(_ value: T) {
        self.value = value
    }
}
