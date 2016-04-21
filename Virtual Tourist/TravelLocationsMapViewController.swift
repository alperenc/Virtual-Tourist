//
//  TravelLocationsMapViewController.swift
//  Virtual Tourist
//
//  Created by Alp Eren Can on 07/03/16.
//  Copyright © 2016 Alp Eren Can. All rights reserved.
//

import UIKit
import MapKit
import CoreData

class TravelLocationsMapViewController: UIViewController, MKMapViewDelegate, NSFetchedResultsControllerDelegate {
    
    // MARK: Properties

    @IBOutlet weak var mapView: MKMapView!
    @IBOutlet weak var deletePinsLabel: UILabel!
    @IBOutlet weak var addPinGestureRecognizer: UILongPressGestureRecognizer!
    
    var currentAnnotation = MKPointAnnotation()
    var editingMode: Bool = false
    
    // MARK: Life Cycle
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
    }
    
    // MARK: Actions

    @IBAction func editPins(sender: UIBarButtonItem) {
        
    }
    
    @IBAction func addPin(sender: UILongPressGestureRecognizer) {
        
        switch sender.state {
        case .Began:
            let location = sender.locationInView(mapView)
            let locationCoordinate = mapView.convertPoint(location, toCoordinateFromView: mapView)
            
            currentAnnotation.coordinate = locationCoordinate
            mapView.addAnnotation(currentAnnotation)
            
        case .Changed:
            let location = sender.locationInView(mapView)
            let locationCoordinate = mapView.convertPoint(location, toCoordinateFromView: mapView)
            
            currentAnnotation.coordinate = locationCoordinate
            
        case .Ended:
            let location = sender.locationInView(mapView)
            let locationCoordinate = mapView.convertPoint(location, toCoordinateFromView: mapView)
            
            currentAnnotation.coordinate = locationCoordinate
            currentAnnotation = MKPointAnnotation()
            
        default:
            return
            
        }
        
    }
    
    // MARK: - MKMapViewDelegate
    
    func mapView(mapView: MKMapView, viewForAnnotation annotation: MKAnnotation) -> MKAnnotationView? {
        let reuseId = "pin"
        
        var pinView = mapView.dequeueReusableAnnotationViewWithIdentifier(reuseId) as? MKPinAnnotationView
        
        if pinView == nil {
            pinView = MKPinAnnotationView(annotation: annotation, reuseIdentifier: reuseId)
            pinView?.canShowCallout = false
            pinView!.pinTintColor = UIColor.redColor()
        } else {
            pinView!.annotation = annotation
        }
        
        return pinView
    }
    
    func mapView(mapView: MKMapView, didSelectAnnotationView view: MKAnnotationView) {
        if editingMode {
            
        }
    }


}

