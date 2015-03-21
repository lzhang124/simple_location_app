//
//  ViewController.swift
//  Location
//
//  Created by Larry Zhang on 3/19/15.
//  Copyright (c) 2015 Larry Zhang. All rights reserved.
//

import UIKit
import CoreLocation
import MapKit

class ViewController: UIViewController, CLLocationManagerDelegate, MKMapViewDelegate {

    @IBOutlet weak var map: MKMapView!
    @IBOutlet weak var locationLabel: UILabel!
    @IBOutlet weak var button: UIButton!
    @IBAction func buttonPressed(sender: AnyObject) {

        if button.titleLabel?.text == "Start" {
            map.removeOverlays(map.overlays)
            allLocations = []
            button.setTitle("Stop", forState: UIControlState.Normal)
            locationManager.startUpdatingLocation()
        } else {
            locationLabel.text = "Location Information"
            button.setTitle("Start", forState: UIControlState.Normal)
            locationManager.stopUpdatingLocation()
        }
    }
    
    var locationManager = CLLocationManager()
    var allLocations: [CLLocation] = []
    var allCoordinates: [CLLocationCoordinate2D] = []
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Setup the location manager
        locationManager.delegate = self
        locationManager.desiredAccuracy = kCLLocationAccuracyBest
        locationManager.requestAlwaysAuthorization()

        // Setup the map view
        map.delegate = self
        map.mapType = MKMapType.Standard
        map.showsUserLocation = true
    }
    
    func locationManager(manager: CLLocationManager!, didUpdateLocations locations: [AnyObject]!) {
        locationLabel.text = "\(locations[0])"
        allLocations.append(locations[0] as CLLocation)
        
        let spanX = 0.007
        let spanY = 0.007
        var newRegion = MKCoordinateRegion(center: map.userLocation.coordinate, span: MKCoordinateSpanMake(spanX, spanY))
        map.setRegion(newRegion, animated: true)
        
        if (allLocations.count > 1){
            var sourceIndex = allLocations.count - 1
            var destinationIndex = allLocations.count - 2
            
            let p1 = allLocations[sourceIndex].coordinate
            let p2 = allLocations[destinationIndex].coordinate
            var line = [p1, p2]
            
            var polyline = MKPolyline(coordinates: &line, count: line.count)
            map.addOverlay(polyline)
        }
    }
    
    func mapView(mapView: MKMapView!, rendererForOverlay overlay: MKOverlay!) -> MKOverlayRenderer! {
        if overlay is MKPolyline {
            var lineColor = UIColor(red: 0.016, green: 0.478, blue: 0.984, alpha: 1.000)
            var polylineRenderer = MKPolylineRenderer(overlay: overlay)
            polylineRenderer.strokeColor = lineColor
            polylineRenderer.lineWidth = 4
            return polylineRenderer
        }
        return nil
    }
}

