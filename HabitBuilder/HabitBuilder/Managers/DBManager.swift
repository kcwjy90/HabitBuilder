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
        let realmConfig = Realm.Configuration(schemaVersion: 20,
            migrationBlock: { (migration, oldSchemaVersion) in
                switch oldSchemaVersion {
                case 0 :
                    break
                default :
                    break
                }
        }, deleteRealmIfMigrationNeeded: true) // true = new schemaversion = deletes realm
        Realm.Configuration.defaultConfiguration = realmConfig
        realm = try! Realm(configuration: realmConfig)
    }
}

//NSObject
//The root class of most Objective-C class hierarchies, from which subclasses inherit a basic interface to the runtime system and the ability to behave as Objective-C objects

// DB model 안에 있는것들을 array안으로 넣어주기 위해
extension Results {
    func toArray() -> [Element] {
        return compactMap {
            $0
        }
    }
}
