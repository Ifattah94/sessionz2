//
//  ChallengesViewController.swift
//  Sessionz2
//
//  Created by C4Q on 12/4/20.
//  Copyright © 2020 Iram Fattah. All rights reserved.
//

import UIKit

class ChallengesViewController: UIViewController {
    
    
    private lazy var matchesCollectionView: UICollectionView = {
       let layout = UICollectionViewFlowLayout()
        layout.scrollDirection = .vertical
        let cv = UICollectionView(frame: CGRect.zero, collectionViewLayout: layout)
        
        return cv
    }()
    
    let challengeSortingVC = ChallengeSortingVC()

    override func viewDidLoad() {
        super.viewDidLoad()
        
        

        
    }
    

    

}
