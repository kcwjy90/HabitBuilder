//
//  PrefManager.swift
//  HabitBuilder
//
//  Created by CW on 1/25/22.
//  Copyright © 2022 CW. All rights reserved.
//

import Foundation
import RealmSwift

class DBManager: NSObject {
    static let SI = DBManager()
    var realm: Realm!
    
    override init() {
        super.init()
    }
    
    func initialize() {
        let realmConfig = Realm.Configuration(schemaVersion: 10,
            migrationBlock: { (migration, oldSchemaVersion) in
                switch oldSchemaVersion {
                case 0 :
                    break
                default :
                    break
                }
        }, deleteRealmIfMigrationNeeded: false) // true = new schemaversion = deletes realm
        Realm.Configuration.defaultConfiguration = realmConfig
        realm = try! Realm(configuration: realmConfig)
    }
}

//Q. line 30 이 꼭 필요? 없어도 돌아가기는 하는데..
//-> 지우고 RMO_Habit 안에서 값 추가하고 빌드하고 실행 해보슈

//Q. 왜 항상 DB model 이나 DB manager 를 Initialize해야하죠? 예를 들어 VC는 안하지 않나?
//-> VC 도 initialize 하고 있는데? let mainVC = MainVC() <--- 이게 initialize 한건데

//Q. line 14에 realm:Realm!을 해놓고 어떨때는 code에 Realm을 쓰고 어떨때는 realm을 쓰는이유?
//-> realm 이 optional 이라 그런거고, 이미 initialize 하면서 realm object 를 init 했으니까 ! 로 항상 init 되어있다고 정의 해 둔것.

//Q. 왜 switch에 case 0 나 default나 다 break인데 case 0 를 하면 죽는가? 그리고 line 22에서 migration 이 하는 역할은?
//-> https://www.mongodb.com/docs/realm/sdk/swift/fundamentals/schema-versions-and-migrations/ 링크로 대체. 이번주 토요일에 나한테 설명 해줄것.

//NSObject
//The root class of most Objective-C class hierarchies, from which subclasses inherit a basic interface to the runtime system and the ability to behave as Objective-C objects


