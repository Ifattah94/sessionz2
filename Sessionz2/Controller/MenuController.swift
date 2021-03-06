//
//  MenuController.swift
//  Sessionz2
//
//  Created by Iram Fattah on 3/10/20.
//  Copyright © 2020 Iram Fattah. All rights reserved.
//

import UIKit

fileprivate let reuseIdentifier = "menuCell"

enum MenuOptions: Int, CaseIterable, CustomStringConvertible {
    case messages
    case settings
    case logout
    
    var description: String {
        switch self {
        case .messages : return "Messages"
        case .settings: return "Settings"
        case .logout: return "Log Out"
        }
    }
}



class MenuController: UITableViewController {
    
    //MARK: Properties
    
    private let user: AppUser
    weak var delegate: MenuControllerDelegate?
    
    
    private lazy var menuHeader: MenuHeader = {
        let frame = CGRect(x: 0,
                           y: 0,
                           width: self.view.frame.width - 80,
                           height: 140)
        let view = MenuHeader(user: user, frame: frame)
        view.delegate = self 
        return view
    }()
    
    init(user: AppUser) {
        self.user = user
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    //MARK: Lifecycle
    
    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .white
        configureTableView()
    }
    
    
    //MARK: Helper Functions 
    func configureTableView() {
        tableView.backgroundColor = .white
        tableView.separatorStyle = .none
        tableView.isScrollEnabled = false
        tableView.rowHeight = 60
        tableView.register(UITableViewCell.self, forCellReuseIdentifier: reuseIdentifier)
        tableView.tableHeaderView = menuHeader
    }
    
    
}


//MARK: UITableViewDataSource/Delegate

extension MenuController {
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return MenuOptions.allCases.count
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: reuseIdentifier, for: indexPath)
        
        guard let option = MenuOptions(rawValue: indexPath.row) else { return UITableViewCell() }
        cell.textLabel?.text = option.description
        
        return cell
    }
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        guard let option = MenuOptions(rawValue: indexPath.row) else { return }
        tableView.deselectRow(at: indexPath, animated: true)
        delegate?.didSelect(option: option)
    }
}

extension MenuController: MenuHeaderDelegate {
    func didSelectHeader(user: AppUser) {
       //Present Edit Profile VC
        let editProfileVC = EditProfileViewController(user: user)
        
        let navController = UINavigationController(rootViewController: editProfileVC)
        
        present(navController, animated: true, completion: nil)
    }
    
    
}
