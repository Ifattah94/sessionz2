//
//  VenueActionView.swift
//  Sessionz2
//
//  Created by C4Q on 8/24/20.
//  Copyright © 2020 Iram Fattah. All rights reserved.
//

import UIKit

protocol VenueActionViewDelegate: class {
    func locationButtonClicked(venue: Venue)
}


class VenueActionView: UIView {
    //MARK: Properties
    
    weak var delegate: VenueActionViewDelegate?
    
    
    var venue: Venue? {
        didSet {
            
        }
    }
    
    private lazy var venueNameLabel: UILabel = {
        let label = UILabel()
        label.font = UIFont.systemFont(ofSize: 18)
        label.textAlignment = .center
        return label
    }()
    
    private lazy var addressLabel: UILabel = {
        let label = UILabel()
               label.textColor = .lightGray
               label.font = UIFont.systemFont(ofSize: 16)
               label.textAlignment = .center
           
               return label
    }()
    
    
    
    
    
}