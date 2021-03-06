//
//  ContainerController.swift
//  Sessionz2
//
//  Created by Iram Fattah on 3/11/20.
//  Copyright © 2020 Iram Fattah. All rights reserved.
//

import UIKit

class ContainerController: UIViewController {
    
    //MARK: Properties
    private let homeController = HomeController()
    private var menuController: MenuController!
    private var isExpanded = false
    private lazy var xOrigin = self.view.frame.width - 80
    private let blackView = UIView()
    
    private let user: AppUser
    
    override var prefersStatusBarHidden: Bool {
        return isExpanded
    }
    
    override var preferredStatusBarUpdateAnimation: UIStatusBarAnimation {
        return .slide
    }
    
    //MARK: Lifecycle
    
    override func viewDidLoad() {
        super.viewDidLoad()
        configure()
        
    }
    
    //MARK: Init
    
    init(user: AppUser) {
        self.user = user
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    
    
    
    //MARK: Helper Methods
    
    private func configure() {
        view.backgroundColor = .backgroundColor
        configureHomeController()
        configureMenuController(with: user)
        
    }
    
    private func configureHomeController() {
        addChild(homeController)
        homeController.didMove(toParent: self)
        view.addSubview(homeController.view)
        homeController.user = self.user
        homeController.delegate = self 
        
    }
    
    private func configureBlackView() {
        self.blackView.frame = CGRect(x: xOrigin,
                                      y: 0,
                                      width: 80,
                                      height: self.view.frame.height)
        blackView.backgroundColor = UIColor(white: 0, alpha: 0.5)
        blackView.alpha = 0
        view.addSubview(blackView)
        
        let tap = UITapGestureRecognizer(target: self, action: #selector(dismissMenu))
        blackView.addGestureRecognizer(tap)
    }
    
    
    private func configureMenuController(with user: AppUser) {
        menuController = MenuController(user: user)
        addChild(menuController)
        menuController.didMove(toParent: self)
        view.insertSubview(menuController.view, at: 0)
        menuController.delegate = self
        configureBlackView()
        
    }
    
    private func animateStatusBar() {
        UIView.animate(withDuration: 0.5, delay: 0, usingSpringWithDamping: 0.8, initialSpringVelocity: 0, options: .curveEaseInOut, animations: {
            self.setNeedsStatusBarAppearanceUpdate()
        }, completion: nil)
    }
    
    private func animateMenu(shouldExpand: Bool, completion: ((Bool) -> Void)? = nil) {
        if shouldExpand {
            UIView.animate(withDuration: 0.5, delay: 0, usingSpringWithDamping: 0.8, initialSpringVelocity: 0, options: .curveEaseInOut, animations: {
                self.homeController.view.frame.origin.x = self.xOrigin
                self.blackView.alpha = 1
            }, completion: nil)
        } else {
            self.blackView.alpha = 0
            UIView.animate(withDuration: 0.5, delay: 0, usingSpringWithDamping: 0.8, initialSpringVelocity: 0, options: .curveEaseInOut, animations: {
                self.homeController.view.frame.origin.x = 0
            }, completion: completion)
        }
        
        animateStatusBar()
    }
    
    
    //MARK: Selectors
    
    @objc func dismissMenu() {
        isExpanded = false
        animateMenu(shouldExpand: isExpanded)
    }
    
}


//MARK: HomeController Delegate

extension ContainerController: HomeControllerDelegate {
    func handleMenuToggle() {
        isExpanded.toggle()
        animateMenu(shouldExpand: isExpanded)
    }
    
    
}
extension ContainerController: MenuControllerDelegate {
    func didSelect(option: MenuOptions) {
        isExpanded.toggle()
        
        animateMenu(shouldExpand: isExpanded) { (_) in
            //TODO: Handle when different menu options are clicked
            
            switch option {
                
            case .messages:
                print("Messages")
                let messagesController = MessagesController()
                let navController = UINavigationController(rootViewController: messagesController)
                self.present(navController, animated: true, completion: nil)
            case .settings:
                print("Settings")
            case .logout:
                FirebaseAuthService.manager.logOutUser { (result) in
                    switch result {
                    case .success(()):
                        guard let windowScene = UIApplication.shared.connectedScenes.first as? UIWindowScene, let sceneDelegate = windowScene.delegate as?  SceneDelegate, let window = sceneDelegate.window else {
                            return
                        }
                        
                        window.rootViewController = UINavigationController(rootViewController: LoginVC())
                    case .failure(let error):
                        print("Could not sign out user \(error.localizedDescription)")
                        
                    }
                }
                
            }
        }
    }
    
    
}
