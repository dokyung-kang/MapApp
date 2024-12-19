//
//  ViewController.swift
//  MyMapTest
//
//  Created by CSMAC013 on 10/4/24.
//

import UIKit
import MapKit

class ViewController: UIViewController, CLLocationManagerDelegate {

    @IBOutlet var myMap: MKMapView!
    @IBOutlet var locText: UITextField!
    @IBOutlet var lblLocationInfo1: UILabel!
    @IBOutlet var lblLocationInfo2: UILabel!
    
    let locationManager = CLLocationManager()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
        lblLocationInfo1.text = ""
        lblLocationInfo2.text = ""
        locationManager.delegate = self
        locationManager.desiredAccuracy = kCLLocationAccuracyBest
        locationManager.requestWhenInUseAuthorization()
        locationManager.startUpdatingLocation()
        myMap.showsUserLocation = true
        
        // 터치 시 이동
        let mapGesture = UITapGestureRecognizer(target: self, action: #selector(mapTouch(_:)))
        myMap.addGestureRecognizer(mapGesture)
    }

    func goLocation(latitudeValue: CLLocationDegrees, longitudeValue : CLLocationDegrees, delta span: Double) -> CLLocationCoordinate2D {
        let pLocation = CLLocationCoordinate2DMake(latitudeValue, longitudeValue)
        let spanValue = MKCoordinateSpan(latitudeDelta: span, longitudeDelta: span)
        let pRegion = MKCoordinateRegion(center: pLocation, span: spanValue)
        myMap.setRegion(pRegion, animated: true)
        return pLocation
    }
    
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        let pLocation = locations.last
        _ = goLocation(latitudeValue: (pLocation?.coordinate.latitude)!, longitudeValue: (pLocation?.coordinate.longitude)!, delta: 0.01)
        CLGeocoder().reverseGeocodeLocation(pLocation!, completionHandler: {
            (placemarks, error) -> Void in
            let pm = placemarks!.first
            let country = pm!.country
            var address:String = country!
            if pm!.locality != nil {
                address += " "
                address += pm!.locality!
            }
            if pm?.thoroughfare != nil {
                address += " "
                address += pm!.thoroughfare!
            }
            
            self.lblLocationInfo1.text = "위도/경도 : " + String((pLocation?.coordinate.latitude)!) + " / " + String((pLocation?.coordinate.longitude)!)
            self.lblLocationInfo2.text = "주소 : " + address
        })
        locationManager.stopUpdatingLocation()
    }

    func setAnnotation(latitudeValue: CLLocationDegrees, longditudeValue: CLLocationDegrees, delta span: Double, title strTitle: String, subtitle strSubtitle : String){
        let annotation = MKPointAnnotation()
        annotation.coordinate = goLocation(latitudeValue: latitudeValue, longitudeValue: longditudeValue, delta: span)
        annotation.title = strTitle
        annotation.subtitle = strSubtitle
        myMap.addAnnotation(annotation)
    }
    
    // 현재 위치 버튼
    @IBAction func currentLocBtn(_ sender: UIButton) {
        locationManager.startUpdatingLocation()
    }
    
    // 확인 버튼
    @IBAction func selectLocBtn(_ sender: UIButton) {
        if locText != nil {
            CLGeocoder().geocodeAddressString(self.locText.text!, completionHandler: {
                (placemarks, error) -> Void in
                let pm = placemarks!.first?.location
                let selectedLatitude = pm!.coordinate.latitude
                let selectedLongitude = pm!.coordinate.longitude
                
                let pm2 = placemarks!.first
                let country = pm2!.country
                var address:String = country!
                if pm2!.locality != nil {
                    address += " "
                    address += pm2!.locality!
                }
                if pm2?.thoroughfare != nil {
                    address += " "
                    address += pm2!.thoroughfare!
                }
                
                let locTitle = String(address)
                let locSubtitle = String(address)
                
                self.myMap.removeAnnotations(self.myMap.annotations)
                self.setAnnotation(latitudeValue: selectedLatitude, longditudeValue: selectedLongitude, delta: 0.1, title: locTitle, subtitle: locSubtitle)
                self.lblLocationInfo1.text = "위도/경도 : " + String(selectedLatitude) + " / " + String(selectedLongitude)
                self.lblLocationInfo2.text = "주소 : " + String(self.locText.text!)
            })
        
        }
    }
    
    // 맵 터치 시 함수
    @objc func mapTouch(_ gestureRecognizer: UITapGestureRecognizer){
        let touchLoc = gestureRecognizer.location(in: myMap)
        let mapLoc = myMap.convert(touchLoc, toCoordinateFrom: myMap)
        
        let newTouchLocation = CLLocation(latitude: mapLoc.latitude, longitude: mapLoc.longitude)
        
        CLGeocoder().reverseGeocodeLocation(newTouchLocation, completionHandler: {
            (placemarks, error) -> Void in
            let pm = placemarks!.first
            let country = pm!.country
            var address:String = country!
            if pm!.locality != nil {
                address += " "
                address += pm!.locality!
            }
            if pm?.thoroughfare != nil {
                address += " "
                address += pm!.thoroughfare!
            }
            
            let locTitle = String(address)
            let locSubtitle = String(address)
            
            self.myMap.removeAnnotations(self.myMap.annotations)
            
            self.setAnnotation(latitudeValue: newTouchLocation.coordinate.latitude, longditudeValue: newTouchLocation.coordinate.longitude, delta: 0.1, title: locTitle, subtitle: locSubtitle)
            self.lblLocationInfo1.text = "위도/경도 : " + String(format: "%.6f", (newTouchLocation.coordinate.latitude)) + " / " + String(format: "%.6f", (newTouchLocation.coordinate.longitude))
            self.lblLocationInfo2.text = "주소 : " + address
            
        })
    }
}

