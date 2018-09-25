import UIKit
import CoreLocation //allows us to tap into the GPS functionaloty of our iPhone.
import Alamofire
import SwiftyJSON

class WeatherViewController: UIViewController, CLLocationManagerDelegate, ChangeCityDelegate {
    
    //Constants
    let WEATHER_URL = "http://api.openweathermap.org/data/2.5/weather" //URL we use to get our weather info.
    let APP_ID = "e72ca729af228beabd5d20e3b7749713" //let's openweathermap know who is using their resources.

    //TODO: Declare instance variables here
    let locationManager = CLLocationManager() // OBJECT
    let weatherDataModel = WeatherDataModel()
    

    
    //Pre-linked IBOutlets
    @IBOutlet weak var weatherIcon: UIImageView!
    @IBOutlet weak var cityLabel: UILabel!
    @IBOutlet weak var temperatureLabel: UILabel!

    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        
        //TODO:Set up the location manager here.
        
        locationManager.delegate = self //we are setting the WeatherViewController(self) as the delegate(.delegate) of the locationManager(it can deal with all the location functionality). We set up ourselves as the delegate so the location manager knows who to report once they find the location date we are looking for.
        
        locationManager.desiredAccuracy = kCLLocationAccuracyHundredMeters //this sets the accuracy of the location data.
        
        locationManager.requestWhenInUseAuthorization()//this will ask the user for location permission.
        
        locationManager.startUpdatingLocation()//this starts with the process where the location manager starts looking for the GPS coordinates of the current iPhone.
        
    }
    
    
    
    //MARK: - Networking
    /***************************************************************/
    
    //Write the getWeatherData method here:
    func getWeatherData(url: String, parameters: [String : String]){ //this method will be in charge of retrieving the data from the weather website.
        
        Alamofire.request(url, method: .get, parameters: parameters).responseJSON {
            response in
            if response.result.isSuccess {
                print("Success! Got the weather data")
                
                let weatherJSON : JSON = JSON(response.result.value!)
                
                self.updateWeatherData(json: weatherJSON)//writing .self we let the software know that it needs to look inside this class.
            }
                
            else {
                print("Error \(response.result.error)")
                self.cityLabel.text = "Connection Issues"
            }
        }
        
    }
    
    
    
    //MARK: - JSON Parsing
    /***************************************************************/
   
    
    //Write the updateWeatherData method here:
    func updateWeatherData(json: JSON){
        
        if let tempResult = json["main"]["temp"].double {//we grab the info from the library "main" and we specify the data we want("temp")
        
        weatherDataModel.temperature = Int(tempResult - 273.15)
        
        weatherDataModel.city = json["name"].stringValue
       
        weatherDataModel.condition = json["weather"][0]["id"].intValue
        
        weatherDataModel.weatherIconName = weatherDataModel.updateWeatherIcon(condition: weatherDataModel.condition)
            
        updateUIWithWeatherData()
        
        }
        
        else {
            cityLabel.text = "Weather Unavailable"
        }
        
    }

    
    
    
    //MARK: - UI Updates
    /***************************************************************/
    
    
    //Write the updateUIWithWeatherData method here:
    
    func updateUIWithWeatherData() {
        
        cityLabel.text = weatherDataModel.city
        
        temperatureLabel.text = "\(weatherDataModel.temperature)°"
        
        weatherIcon.image = UIImage(named: weatherDataModel.weatherIconName)
        
    }
    
    
    
    
    //MARK: - Location Manager Delegate Methods
    /***************************************************************/
    
    
    //Write the didUpdateLocations method here:
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) { //notify us when the location has been found.
        let location = locations[locations.count - 1] //.count: how many values are in total
        if location.horizontalAccuracy > 0 { //makes sure our value is not negative/invalid
            locationManager.stopUpdatingLocation()//this stops updating the location as soon as it gets a valid result.
            
            print("longitude = \(location.coordinate.longitude), latitude = \(location.coordinate.latitude)")
            
            let latitude = String(location.coordinate.latitude)
            let longitude = String(location.coordinate.longitude)
            
            let params : [String : String] = ["lat" : latitude, "lon" : longitude, "appid" : APP_ID]
            
            getWeatherData(url: WEATHER_URL, parameters: params)
        }
    }
    
    
    
    //Write the didFailWithError method here:
    func locationManager(_ manager: CLLocationManager, didFailWithError error: Error) { //tells the delegate that the location manager was unable to retrieve a location value.
        print(error)
        cityLabel.text = "Location Unavailable" //this will print in the cityLabel the written string.

    }
    
    

    
    //MARK: - Change City Delegate methods
    /***************************************************************/
    
    
    
    //Write the userEnteredANewCityName Delegate method here:
    func userEnteredANewCityName(city: String) {
        
        let params : [String : String] = ["q" : city, "appid" : APP_ID] //"q" is a parameter set up in the openweathermap website.
        
        getWeatherData(url: WEATHER_URL, parameters: params)
        
    }

    
    //Write the PrepareForSegue Method here
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
       
        if segue.identifier == "changeCityName" {
        
            let destinationVC = segue.destination as! ChangeCityViewController
            
            destinationVC.delegate = self
        
        }
    }
    
    
    
    
    
}


