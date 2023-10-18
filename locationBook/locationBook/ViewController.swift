//
//  ViewController.swift
//  locationBook
//
//  Created by Talha Demirkan on 15.10.2023.
//

import UIKit
import MapKit
import CoreLocation
import CoreData

class ViewController: UIViewController, MKMapViewDelegate, CLLocationManagerDelegate{
    
    @IBOutlet var nameText: UITextField!
    @IBOutlet var DescriptionText: UITextField!
    
    @IBOutlet var mapView: MKMapView!
    var locationManager = CLLocationManager()
    
    var chosenLatitude = Double()
    var chosenLongitude = Double()
    
    var selectedTitle = ""
    var selectedTitleID : UUID?
    
    var anotationTitle = ""
    var anotationSubTitle = ""
    var anotationLatitude = Double()
    var anotationLongitude = Double()
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        mapView.delegate = self
        locationManager.delegate = self
        
        locationManager.desiredAccuracy = kCLLocationAccuracyBest
        locationManager.requestWhenInUseAuthorization()
        locationManager.startUpdatingLocation()
        
        let gestureRecognizer = UILongPressGestureRecognizer(target: self, action: #selector(chooseLocation(gestureRecognizer: )))
        
        gestureRecognizer.minimumPressDuration = 2
        mapView.addGestureRecognizer(gestureRecognizer)
        
        if selectedTitle != ""{
            //fetch from core data
            let idString = selectedTitleID!.uuidString
            
            let appDelegate = UIApplication.shared.delegate as! AppDelegate
            let context = appDelegate.persistentContainer.viewContext
            
            let fetchRequest = NSFetchRequest<NSFetchRequestResult>(entityName: "Places")
            fetchRequest.predicate = NSPredicate(format: "id = %@", idString)
            fetchRequest.returnsObjectsAsFaults = false
            
            do{
                let results = try context.fetch(fetchRequest)
                if results.count > 0{
                    for result in results as! [NSManagedObject]{
                        if let title = result.value(forKey: "title") as? String{
                            anotationTitle = title
                            if let subTitle = result.value(forKey: "subtitle") as? String{
                                anotationSubTitle = subTitle
                                if let latitude = result.value(forKey: "latitude") as? Double{
                                    anotationLatitude = latitude
                                    if let longitude = result.value(forKey: "longitude") as? Double{
                                        anotationLongitude = longitude
                                        
                                        let anotation = MKPointAnnotation()
                                        anotation.title = anotationTitle
                                        anotation.subtitle = anotationSubTitle
                                        let coordinate = CLLocationCoordinate2D(latitude: anotationLatitude, longitude: anotationLongitude)
                                        anotation.coordinate = coordinate
                                        mapView.addAnnotation(anotation)
                                        nameText.text = anotationTitle
                                        DescriptionText.text = anotationSubTitle
                                        
                                        locationManager.stopUpdatingLocation()
                                        
                                        let span = MKCoordinateSpan(latitudeDelta: 0.05, longitudeDelta: 0.05)
                                        let region = MKCoordinateRegion(center: coordinate, span: span)
                                        mapView.setRegion(region, animated: true)
                                    }
                                    
                                }
                            }
                        }
                    }
                }
                
            }catch{
                print("Error while fetching in ViewController")
            }
            
        } else{
            //add new data
        }
        
    }
    
    @objc func chooseLocation(gestureRecognizer : UILongPressGestureRecognizer){
        
        if gestureRecognizer.state == .began {
            let touchedPoint = gestureRecognizer.location(in: self.mapView)
            let touchedCoordinates = self.mapView.convert(touchedPoint, toCoordinateFrom: self.mapView)
            
            chosenLatitude = touchedCoordinates.latitude
            chosenLongitude = touchedCoordinates.longitude
            
            let annotation = MKPointAnnotation()
            annotation.coordinate = touchedCoordinates
            annotation.title = nameText.text
            annotation.subtitle = DescriptionText.text
            self.mapView.addAnnotation(annotation)
        }
        
    }
    
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        //if içine aldık ki kaydettiğimiz bi yerin konumuna bakarken bo konumu açsın bizim mevcut bulundupumuz konumu değil
        if selectedTitle == "" {
            let location = CLLocationCoordinate2D(latitude: locations[0].coordinate.latitude,
                                                  longitude: locations[0].coordinate.longitude)
            let span = MKCoordinateSpan(latitudeDelta: 0.1, longitudeDelta: 0.1)
            let region = MKCoordinateRegion(center: location, span: span)
            mapView.setRegion(region, animated: true)
        }
    }
    
    func mapView(_ mapView: MKMapView, viewFor annotation: MKAnnotation) -> MKAnnotationView? {
        if annotation is MKUserLocation {
            return nil
        }
        
        let reuseId = "myAnnotation"
        var pinView = mapView.dequeueReusableAnnotationView(withIdentifier: reuseId) as? MKMarkerAnnotationView
        
        if pinView == nil {
            pinView = MKMarkerAnnotationView(annotation: annotation, reuseIdentifier: reuseId)
            pinView?.canShowCallout = true
            pinView?.tintColor = UIColor.black
            
            let button = UIButton(type: UIButton.ButtonType.detailDisclosure)
            pinView?.rightCalloutAccessoryView = button
        } else {
            pinView?.annotation = annotation
        }
        
        return pinView
    }
    
    func mapView(_ mapView: MKMapView, annotationView view: MKAnnotationView, calloutAccessoryControlTapped control: UIControl) {
        if selectedTitle != ""{
            let requestLocation = CLLocation(latitude: anotationLatitude, longitude: anotationLongitude)
            
            CLGeocoder().reverseGeocodeLocation(requestLocation) { placemarks, error in
                if let placemark = placemarks{
                    if placemark.count > 0 {
                        let newPlaceMark = MKPlacemark(placemark: placemark[0])
                        let item = MKMapItem(placemark: newPlaceMark)
                        item.name = self.anotationTitle
                        let launchOptions = [MKLaunchOptionsDirectionsModeKey:MKLaunchOptionsDirectionsModeDriving]
                        item.openInMaps(launchOptions: launchOptions)
                    }
                }
                
                
            }
        }
    }
    

    @IBAction func saveButtonTapped(_ sender: Any) {
        let appDelegate = UIApplication.shared.delegate as! AppDelegate
        let context = appDelegate.persistentContainer.viewContext
        
        let newPlace = NSEntityDescription.insertNewObject(forEntityName: "Places", into: context)
        
        newPlace.setValue(nameText.text, forKey: "title")
        newPlace.setValue(DescriptionText.text, forKey: "subtitle")
        newPlace.setValue(chosenLatitude, forKey: "latitude")
        newPlace.setValue(chosenLongitude, forKey: "longitude")
        newPlace.setValue(UUID(), forKey: "id")
        
        do{
            try context.save()
            print("success")
        }catch{
            print("error")
        }
        
        NotificationCenter.default.post(name: NSNotification.Name(rawValue: "newPlace"), object: nil)
        navigationController?.popViewController(animated: true)
        
    }
    
}

