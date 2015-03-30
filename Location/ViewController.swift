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

class ViewController: UIViewController, CLLocationManagerDelegate, MKMapViewDelegate, UIDocumentInteractionControllerDelegate {

    @IBOutlet weak var map: MKMapView!
    @IBOutlet weak var picker: UIPickerView!
    @IBOutlet weak var button: UIButton!
    @IBAction func buttonPressed(sender: AnyObject) {
        if button.titleLabel?.text == "Start" {
            map.removeOverlays(map.overlays)
            allCoordinates = []
            allData = []
            button.setTitle("Stop", forState: UIControlState.Normal)
            locationManager.startUpdatingLocation()
        } else {
            button.setTitle("Start", forState: UIControlState.Normal)
            locationManager.stopUpdatingLocation()
            map.setUserTrackingMode(MKUserTrackingMode.Follow, animated: true)
            exportToCSV(self)
        }
    }
    
    var locationManager = CLLocationManager()
    var allCoordinates: [CLLocationCoordinate2D] = []
    var allData: [(CLLocationDegrees, CLLocationDegrees, CLLocationAccuracy)] = []
    var types = ["Cell ID", "WiFi", "GPS"]
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        locationManager.delegate = self
        locationManager.requestWhenInUseAuthorization()
        
        map.delegate = self
        map.mapType = MKMapType.Standard
        map.showsUserLocation = true
        map.setUserTrackingMode(MKUserTrackingMode.Follow, animated: true)
    }
    
    func locationManager(manager: CLLocationManager!, didUpdateLocations locations: [AnyObject]!) {
        let newLocation = locations[0] as CLLocation
        allCoordinates.append(newLocation.coordinate)
        
        let newData = (newLocation.coordinate.latitude, newLocation.coordinate.longitude, newLocation.horizontalAccuracy)
        allData.append(newData)
        
        map.setUserTrackingMode(MKUserTrackingMode.None, animated: true)
        let spanX = 0.005
        let spanY = 0.005
        var newRegion = MKCoordinateRegion(center: map.userLocation.coordinate, span: MKCoordinateSpanMake(spanX, spanY))
        map.setRegion(newRegion, animated: true)
        
        var circle = MKCircle(centerCoordinate: newLocation.coordinate, radius: newData.2)
        map.addOverlay(circle)

        if (allCoordinates.count > 1){
            var start = allCoordinates.count - 1
            var end = allCoordinates.count - 2
            
            let p1 = allCoordinates[start]
            let p2 = allCoordinates[end]
            var line = [p1, p2]
            
            var polyline = MKPolyline(coordinates: &line, count: line.count)
            map.addOverlay(polyline, level: MKOverlayLevel.AboveLabels)
        }
    }
    
    func mapView(mapView: MKMapView!, rendererForOverlay overlay: MKOverlay!) -> MKOverlayRenderer! {
        if overlay is MKCircle {
            var fillColor = UIColor(red: 0.016, green: 0.478, blue: 0.984, alpha: 0.010)
            var circleRenderer = MKCircleRenderer(overlay: overlay)
            circleRenderer.fillColor = fillColor
            return circleRenderer
        }
        
        if overlay is MKPolyline {
            var lineColor = UIColor(red: 0.016, green: 0.478, blue: 0.984, alpha: 1.000)
            var polylineRenderer = MKPolylineRenderer(overlay: overlay)
            polylineRenderer.strokeColor = lineColor
            polylineRenderer.lineWidth = 4
            return polylineRenderer
        }
        
        return nil
    }
    
    func numberOfComponentsInPickerView(pickerView: UIPickerView) -> Int {
        return 1
    }
    
    func pickerView(pickerView: UIPickerView, numberOfRowsInComponent component: Int) -> Int {
        return types.count
    }
    
    func pickerView(pickerView: UIPickerView, titleForRow row:Int, forComponent component:Int) -> String! {
        return types[row]
    }
    
    func pickerView(pickerView: UIPickerView, didSelectRow row:Int, inComponent component:Int){
        switch(row) {
            case 0:
                locationManager.desiredAccuracy = kCLLocationAccuracyKilometer
                break
            case 1:
                locationManager.desiredAccuracy = kCLLocationAccuracyHundredMeters
                break
            case 2:
                locationManager.desiredAccuracy = kCLLocationAccuracyNearestTenMeters
                break
            default:
                locationManager.desiredAccuracy = kCLLocationAccuracyBest
        }
    }
    
    func documentInteractionControllerViewControllerForPreview(controller: UIDocumentInteractionController) -> UIViewController! {
        return self
    }
    
    func exportToCSV(delegate: UIDocumentInteractionControllerDelegate) {
        let fileName = NSTemporaryDirectory().stringByAppendingPathComponent("location.csv")
        let url: NSURL! = NSURL(fileURLWithPath: fileName)
        
        var data = ",\n".join(allData.map { "\($0.0),\($0.1),\($0.2)" })
        
        data.writeToURL(url, atomically: true, encoding: NSUTF8StringEncoding, error: nil)
        if url != nil {
            let documentController = UIDocumentInteractionController(URL: url)
            documentController.UTI = "public.comma-separated-values-text"
            documentController.delegate = delegate
            documentController.presentPreviewAnimated(true)
        }
    }
}

