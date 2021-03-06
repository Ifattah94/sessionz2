//
//  HomeController.swift
//  Sessionz2
//
//  Created by Iram Fattah on 3/11/20.
//  Copyright © 2020 Iram Fattah. All rights reserved.
//

import UIKit
import Firebase
import MapKit
import GeoFire


private enum ActionButtonConfiguration {
    case showMenu
    case dismissActionView
    
    init() {
        self = .showMenu
    }
}

private let annotationIdentifier = "PlayerAnnotation"
private let venueAnnoIdentifier = "venueAnnotation"
class HomeController: UIViewController {
    
    
    
    
    
    //MARK: Properties
    
    lazy var mapView: MKMapView = {
        let mv = MKMapView()
        mv.mapType = .standard
        mv.isUserInteractionEnabled = true
        return mv
    }()
    
    
    
    
    private var locationManager = LocationHandler.shared.locationManager 
       
    
    private var actionButtonConfig = ActionButtonConfiguration()
    
    weak var delegate: HomeControllerDelegate?
    
    private let actionButton: UIButton = {
        let button = UIButton(type: .system)
        button.setImage(#imageLiteral(resourceName: "baseline_menu_black_36dp").withRenderingMode(.alwaysOriginal), for: .normal)
        button.addTarget(self, action: #selector(actionButtonPressed), for: .touchUpInside)
        return button
    }()
    
    private let messageButton: UIButton = {
        let button = UIButton(type: .system)
        button.setImage(#imageLiteral(resourceName: "send2").withRenderingMode(.alwaysOriginal), for: .normal)
        button.addTarget(self, action: #selector(messageButtonPressed), for: .touchUpInside)
        return button
        
    }()
    
    private let playerActionView = PlayerActionView()
    private final let playerActionViewHeight: CGFloat = 300
    
    public var user: AppUser! {
        didSet {
            fetchPlayers()
            
        }
    }
    
    private let venueActionView = VenueActionView()
    private final let venueActionViewHeight: CGFloat = 360
    
    
    public var venues = [Venue]()
    
    
    
    
    
    //MARK: Lifecycle
    
    override func viewDidLoad() {
        super.viewDidLoad()
        configureUI()
        enableLocationServices()
        loadVenues()
        FirebaseDatabaseHelper.manager.setUserFCMToken()
    }
    
    
    
    //MARK: Helper Methods
    
    
    
    private func configureActionButton(config: ActionButtonConfiguration) {
        switch config {
        case .showMenu:
            self.actionButton.setImage(#imageLiteral(resourceName: "baseline_menu_black_36dp").withRenderingMode(.alwaysOriginal), for: .normal)
            self.actionButtonConfig = .showMenu
        case .dismissActionView:
            actionButton.setImage(#imageLiteral(resourceName: "baseline_arrow_back_black_36dp").withRenderingMode(.alwaysOriginal), for: .normal)
            actionButtonConfig = .dismissActionView
        }
    }
    
    
    
    private func fetchPlayers() {
        guard let location = locationManager?.location else {
            print("DEBUG NO LOCATION")
            return}
        
        PlayerService.shared.fetchPlayersFromLocation(location: location) { (player) in
            guard let coordinate = player.location?.coordinate else {print("DEBUG NO DRIVER COORDINATE");return}
            let annotation = PlayerAnnotation(player: player, coordinate: coordinate)
             self.zoomToCurrentUser(playerID: player.uid)
            var playerIsVisible: Bool {
                return self.mapView.annotations.contains { (annotation) -> Bool in
                    guard let playerAnno = annotation as? PlayerAnnotation else {return false}
                    if playerAnno.uid == player.uid {
                        playerAnno.updateAnnotationPosition(withCoordinate: coordinate)

                        return true 
                    }
                    return false
                }
            }
            if !playerIsVisible {
                self.mapView.addAnnotation(annotation)
            }
            
            
        }
    }
    
    private func loadVenues() {
        self.venues = JSONService.parsePodcastJSONFile()
        
        for venue in venues {
            
            mapView.addAnnotation(venue)
        }
    }
    
    
    private func animatePlayerActionView(shouldShow: Bool, user: AppUser?) {
        let yOrigin = shouldShow ? self.view.frame.height - self.playerActionViewHeight : self.view.frame.height
        
        UIView.animate(withDuration: 0.3) {
            self.playerActionView.frame.origin.y = yOrigin
        }
        
        //only configure user if view is being animated from player anno
        if let user = user {
            self.playerActionView.user = user
        }
        
        
    }
    
    private func animateVenueActionView(shouldShow: Bool, venue: Venue?) {
        if let venue = venue {
            self.venueActionView.venue = venue
        }
        let yOrigin = shouldShow ? self.view.frame.height - self.venueActionViewHeight : self.view.frame.height
        
        UIView.animate(withDuration: 0.3) {
            self.venueActionView.configureLabelInfo()
                   self.venueActionView.frame.origin.y = yOrigin
            
            
    }
        
    }
    
    
    
    private func zoomToCurrentUser(playerID: String) {
        var annotations = [MKAnnotation]()
        
        self.mapView.annotations.forEach { (annotation) in
            if let anno = annotation as? PlayerAnnotation {
                annotations.append(anno)
            }
            if let userAnno = annotation as? MKUserLocation {
                annotations.append(userAnno)
            }
            
            if let venueAnno = annotation as? Venue {
                annotations.append(venueAnno)
            }
        }
        
        self.mapView.zoomToFit(annotations: annotations)
    }
    
    
    
    //MARK: UI Configurations
    
    
    private func configureUI() {
        configureMapView()
        configurePlayerActionView()
        configureVenueActionView()
        configureActionButton()
    }
    
    private func configureMapView() {
        view.addSubview(mapView)
        mapView.frame = view.frame
        mapView.showsUserLocation = true
        mapView.userTrackingMode = .follow
        mapView.delegate = self
    }
    
    private func configureActionButton() {
        view.addSubview(actionButton)
        actionButton.anchor(top: view.safeAreaLayoutGuide.topAnchor, left: view.leftAnchor,
                            paddingTop: 16, paddingLeft: 20, width: 30, height: 30)
    }
    private func configureMessageButton() {
        view.addSubview(messageButton)
        messageButton.anchor(top: view.safeAreaLayoutGuide.topAnchor, right: view.rightAnchor, paddingTop: 16, paddingRight: 20, width: 30, height: 30)
    }
    
    private func configurePlayerActionView() {
        view.addSubview(playerActionView)
        //TODO: Configure player action view delegate
        playerActionView.delegate = self
        playerActionView.frame = CGRect(x: 0, y: view.frame.height, width: view.frame.width, height: playerActionViewHeight)
    }
    
    private func configureVenueActionView() {
        view.addSubview(venueActionView)
        venueActionView.delegate = self 
        venueActionView.frame = CGRect(x: 0, y: view.frame.height, width: view.frame.width, height: venueActionViewHeight)
    }
    
    
    //MARK: Selectors
    
    
    @objc func actionButtonPressed() {
        switch actionButtonConfig {
        case .showMenu:
            print("show menu")
            delegate?.handleMenuToggle()
        case .dismissActionView:
            //TODO: Dismiss action view
            print("dismiss action")
        }
        
    }
    
    @objc func messageButtonPressed() {
        
    }
    
    //MARK: TOUCH EVENTS
    
    
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        //makes sure player action view is visible 
        if self.playerActionView.frame.origin.y == self.view.frame.height - self.playerActionViewHeight {
            
            //make sure touch is not in the player action view
            guard touches.first?.view != playerActionView else {return}
            animatePlayerActionView(shouldShow: false, user: nil)
        } else if self.venueActionView.frame.origin.y == self.view.frame.height - self.venueActionViewHeight {
            //make sure touch is not in venue action view
            guard touches.first?.view != venueActionView else {return}
            animateVenueActionView(shouldShow: false, venue: nil)
        }
    }
    

    
    
}


//MARK: Location Services

extension HomeController: CLLocationManagerDelegate {
    private func enableLocationServices() {
        locationManager?.delegate = self
        
        switch CLLocationManager.authorizationStatus() {
        case .notDetermined:
            print("DEBUG: Not determined..")
            locationManager?.requestWhenInUseAuthorization()
        case .restricted, .denied:
            break
        case .authorizedAlways:
            print("DEBUG: Auth always..")
            locationManager?.startUpdatingLocation()
            locationManager?.desiredAccuracy = kCLLocationAccuracyBest
        
        case .authorizedWhenInUse:
            print("DEBUG: Auth when in use..")
            locationManager?.startUpdatingLocation()
            locationManager?.desiredAccuracy = kCLLocationAccuracyBest
            
        
        @unknown default:
            break
        }
    }
    
}

extension HomeController: MKMapViewDelegate {
    func mapView(_ mapView: MKMapView, viewFor annotation: MKAnnotation) -> MKAnnotationView? {
        if let annotation = annotation as? PlayerAnnotation {
            let annoView = MKAnnotationView(annotation: annotation, reuseIdentifier: annotationIdentifier)
            annoView.displayPriority = .required
            annoView.image = #imageLiteral(resourceName: "GameController2")
            annoView.canShowCallout = true
            annoView.isEnabled = true
            let btn = UIButton(type: .detailDisclosure)
            annoView.rightCalloutAccessoryView = btn
            
            return annoView
        } else if let venueAnnotation = annotation as? Venue {
            let venueAnnoView = MKAnnotationView(annotation: venueAnnotation, reuseIdentifier: venueAnnoIdentifier)
            venueAnnoView.image = #imageLiteral(resourceName: "icons8-arcade-cabinet-48")
            venueAnnoView.canShowCallout = true
            venueAnnoView.isEnabled = true
            let btn = UIButton(type: .detailDisclosure)
            venueAnnoView.rightCalloutAccessoryView = btn
            return venueAnnoView
        }
        return nil 
    }
    
    func mapView(_ mapView: MKMapView, annotationView view: MKAnnotationView, calloutAccessoryControlTapped control: UIControl) {
        if let playerAnno = view.annotation as? PlayerAnnotation {
            
            print("DEBUG: Control tapped for user \(playerAnno.player.gamerTag)")
            
            
            
            animatePlayerActionView(shouldShow: true, user: playerAnno.player)
            
        } else if let venueAnno = view.annotation as? Venue {
            animateVenueActionView(shouldShow: true, venue: venueAnno)
        }
       
        
    }
    
    
    
}

//MARK: Player Action View Delegate
extension HomeController: PlayerActionViewDelegate {
    func messageButtonClicked(user: AppUser) {
        //TODO NEW MESSAGE CONTROLLER
        let chatController = ChatController(collectionViewLayout: UICollectionViewFlowLayout())
        chatController.user = user
        let navController = UINavigationController(rootViewController: chatController)
        navController.modalPresentationStyle = .overCurrentContext
        present(navController, animated: true, completion: nil)
        print("message vc should be showed")
       
    }
    
    
}

extension HomeController: VenueActionViewDelegate {
    func locationButtonClicked(venue: Venue) {
        print("Venue is \(venue.name)")
        
        
        let launchOptions = [MKLaunchOptionsDirectionsModeKey: MKLaunchOptionsDirectionsModeDriving]
        venue.mapItem?.openInMaps(launchOptions: launchOptions)
    }
    
    
}
