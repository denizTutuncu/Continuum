//
//  DateHelper.swift
//  ContinuumDeniz
//
//  Created by Deniz Tutuncu on 2/28/19.
//  Copyright © 2019 Deniz Tutuncu. All rights reserved.
//

import Foundation

extension Date {
    func stringWith(dateStyle: DateFormatter.Style, timeStyle: DateFormatter.Style) -> String {
        let formatter = DateFormatter()
        formatter.dateStyle = dateStyle
        formatter.timeStyle = timeStyle
        return formatter.string(from: self)
    }
}
