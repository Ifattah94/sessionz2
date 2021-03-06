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
            self.hoursOfOperationView.hoursOfOperation = self.venue?.hoursOfOperation
        }
    }
    
    private var venueNameLabel: UILabel = {
        let label = UILabel()
        label.font = UIFont.systemFont(ofSize: 18)
        label.textAlignment = .center
        return label
    }()
    
    private var addressLabel: UILabel = {
        let label = UILabel()
        label.textColor = .lightGray
        label.font = UIFont.systemFont(ofSize: 16)
        label.textAlignment = .center
        
        return label
    }()
    
    private var hoursOfOperationView: HoursOfOperationView = {
        let view = HoursOfOperationView()
        
        return view
    }()
    
    
    private let locationButton: UIButton = {
        let button = UIButton(type: .system)
        button.backgroundColor = .secondaryBlueTint
        button.setTitle("Location", for: .normal)
        button.setTitleColor(.white, for: .normal)
        button.titleLabel?.font = UIFont.boldSystemFont(ofSize: 20)
        button.addTarget(self, action: #selector(handleLocationButtonClicked), for: .touchUpInside)
        return button
    }()
    
    override init(frame: CGRect) {
        super.init(frame: frame)
         self.backgroundColor = .white
        
         addShadow()
        let stack = UIStackView(arrangedSubviews: [venueNameLabel, addressLabel])
        stack.axis = .vertical
        stack.spacing = 4
        stack.distribution = .fillEqually
        
        //configure stack view with gamer tag and full name labels
        addSubview(stack)
        stack.centerX(inView: self)
        stack.anchor(top: topAnchor, paddingTop: 12)
        
        addSubview(hoursOfOperationView)
        
        hoursOfOperationView.centerX(inView: self)
        hoursOfOperationView.anchor(top: stack.bottomAnchor, paddingTop: 16)
        hoursOfOperationView.setDimensions(height: 180, width: 180)
        
        addSubview(locationButton)
        locationButton.anchor(left: leftAnchor, bottom: safeAreaLayoutGuide.bottomAnchor, right: rightAnchor, paddingLeft: 12, paddingBottom: 12, paddingRight: 12, height: 45)
        
        
        
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    public func configureLabelInfo() {
        guard let venue = self.venue else {
            print("NO Venue in View")
            return}
        self.venueNameLabel.text = venue.name
        self.hoursOfOperationView.hoursOfOperation = venue.hoursOfOperation
        self.addressLabel.text = venue.streetAddress
    }
    
    
    
    
    @objc func handleLocationButtonClicked() {
        guard let venue = venue else {return}
        delegate?.locationButtonClicked(venue: venue)
    }
}
