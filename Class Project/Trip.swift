//
//  Trip.swift
//  Class Project
//
//  Created by Archit Singh on 10/22/23.
//

import Foundation

struct Trip: Identifiable {
    var id = UUID()
    var destination: String
    var startDate: Date
    var endDate: Date
}
