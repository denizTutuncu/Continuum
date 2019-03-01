//
//  SearchableRecord.swift
//  ContinuumDeniz
//
//  Created by Deniz Tutuncu on 2/27/19.
//  Copyright © 2019 Deniz Tutuncu. All rights reserved.
//

import Foundation

protocol SearchableRecord {
    
    func matches(searchTerm: String) -> Bool
}
