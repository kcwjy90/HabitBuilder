//
//  Count_Object.swift
//  HabitBuilder
//
//  Created by ppc90 on 5/18/22.
//  Copyright © 2022 CW. All rights reserved.
//

import Foundation
import RealmSwift

//Temporary Local Database created

class RMO_Count: Object {
    @Persisted var date: String
    @Persisted var total: Int
    @Persisted var remove: Int
    @Persisted var success: Int
    @Persisted var fail: Int
    @Persisted var finalPercent: Float
    
    convenience init(title: Int) {
        self.init()
        self.success = success
    }
}
