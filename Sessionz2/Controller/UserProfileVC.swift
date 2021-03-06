//
//  UserProfileVC.swift
//  Sessionz2
//
//  Created by C4Q on 5/6/20.
//  Copyright © 2020 Iram Fattah. All rights reserved.
//

import UIKit
import Firebase
import JGProgressHUD

private let reuseIdentifier = "Cell"
private let headerIdentifier = "UserProfileHeader"


class UserProfileVC: UICollectionViewController, UICollectionViewDelegateFlowLayout {
    
    
    //MARK: Properties
    var user: AppUser?
    
    
    private let challengePlayerView = ChallengePlayerView()
    private let challengePlayerViewHeight: CGFloat = 300 
    
     let hud = JGProgressHUD(style: .dark)
    public var currentMatchSet: MatchSet?
    
    //MARK: Lifecycle
    
    override func viewDidLoad() {
        super.viewDidLoad()
        collectionView.backgroundColor = .white 
        self.view.isUserInteractionEnabled = true
        self.collectionView.register(UICollectionViewCell.self, forCellWithReuseIdentifier: reuseIdentifier)
        self.collectionView.register(UserProfileHeader.self, forSupplementaryViewOfKind: UICollectionView.elementKindSectionHeader, withReuseIdentifier: headerIdentifier)
        
        if self.user == nil {
        setCurrentUser()
        }
        configureChallengePlayerView()
    }
    
    private func configureChallengePlayerView() {
        view.addSubview(challengePlayerView)
        challengePlayerView.delegate = self
        challengePlayerView.frame = CGRect(x: 0, y: view.frame.height, width: view.frame.width, height: challengePlayerViewHeight)

    }
    
    private func showHUDNotification(text: String, isError: Bool) {
        if isError {
            self.hud.indicatorView = JGProgressHUDErrorIndicatorView()
        } else {
            self.hud.indicatorView = JGProgressHUDSuccessIndicatorView()
            
        }
        
        self.hud.textLabel.text = text
        self.hud.show(in: self.view)
        self.hud.dismiss(afterDelay: 2.0)
    }
    
    
    
    private func animateChalengePlayerView(shouldShow: Bool, player: AppUser?) {
        if let player = player {
            self.challengePlayerView.user = player
        }
        let yOrigin = shouldShow ? self.view.frame.height - self.challengePlayerViewHeight : self.view.frame.height
        
        UIView.animate(withDuration: 0.3) {
            self.challengePlayerView.frame.origin.y = yOrigin
        }
    }
    
    
    //MARK: UICollectionViewFlowLayout
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumInteritemSpacingForSectionAt section: Int) -> CGFloat {
        return 1
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumLineSpacingForSectionAt section: Int) -> CGFloat {
        return 1
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        let width = (view.frame.width - 2) / 3
        return CGSize(width: width, height: width)
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, referenceSizeForHeaderInSection section: Int) -> CGSize {
        return CGSize(width: view.frame.width, height: 200)
    }
    
    //MARK: UICollectionView Data
    
    override func collectionView(_ collectionView: UICollectionView, viewForSupplementaryElementOfKind kind: String, at indexPath: IndexPath) -> UICollectionReusableView {
        
        // declare header
        let header = collectionView.dequeueReusableSupplementaryView(ofKind: kind, withReuseIdentifier: headerIdentifier, for: indexPath) as! UserProfileHeader
        
        // set delegate
        header.delegate = self
        
        // set the user in header
        header.user = self.user
        
        
        // return header
        return header
    }

    
    //TODO: Configure This with Match History
    override func numberOfSections(in collectionView: UICollectionView) -> Int {
           return 1
       }
    
    override func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
           return 6
       }
    
    override func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: reuseIdentifier, for: indexPath)
    
        return cell
    }

   
    
    //MARK: Firebase API
    
    private func setCurrentUser() {
        guard let currentUserId = FirebaseAuthService.manager.currentUser?.uid else {return}
        FirebaseDatabaseHelper.manager.fetchUserData(uid: currentUserId) { (result) in
            switch result {
            case .success(let user):
                self.user = user
                print("\(user.gamerTag)")
                
            case .failure(let error):
                print(error)
            }
        }
        
    }
    
    
    
}

extension UserProfileVC: UserProfileHeaderDelegate {
    func challengeButtonPressed() {
        animateChalengePlayerView(shouldShow: true, player: self.user)
    }
    
    func setUserStats(for header: UserProfileHeader) {
        //TODO
    print("Header stats to be displayed")
    }
    
    
}

extension UserProfileVC: MatchSetSelectionDelegate {
    func didPressDismissButton() {
        animateChalengePlayerView(shouldShow: false, player: nil)
    }
    
    func didSelectMatchSet(set: MatchSet) {
        print("current selected set is \(set)")
        self.currentMatchSet = set
        
    }
    func didPressConfirmButton() {
        //TODO handle confirm and upload challenge to database
        
        guard let selectedMatchSet = self.currentMatchSet else {return}
        let rawValue = selectedMatchSet.rawValue
        let properties = [matchSetKey: rawValue as Any] as [String:AnyObject]
        
        ChallengeService.shared.uploadNewChallange(user: self.user, with: properties as [String : AnyObject]) { (result) in
            switch result {
            case .success(()):
                print("success")
                self.showHUDNotification(text: "You have challenged \(self.user!.gamerTag)", isError: false)
                self.animateChalengePlayerView(shouldShow: false, player: self.user)
            case .failure(let error):
                self.showHUDNotification(text: "Error challenging", isError: true)
                print(error)
            }
        }
        
        
    }
    
}
