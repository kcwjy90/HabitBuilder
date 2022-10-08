//
//  RMO_Rate.swift
//  HabitBuilder
//
//  Created by ppc90 on 10/4/22.
//  Copyright © 2022 CW. All rights reserved.
//

import Foundation
import RealmSwift

class RMO_Rate: Object {
    @Persisted var id = UUID().uuidString
    @Persisted var habitID: String = ""
    @Persisted var createdDate: Date = Date()
    @Persisted var rate: Double
    
    //designating id as the primary key to prevent duplicate ones based on createdDate
    override static func primaryKey() -> String? {
        return "id"
    }
}
