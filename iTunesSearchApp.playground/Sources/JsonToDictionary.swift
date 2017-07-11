import Foundation

// Code Utilities for Testing Purpose

func convertJsonStringToDictionary() -> Void {
    
    let jsonText = ""
    
    _ = NSDictionary().count
    
    var dictionary: [String:AnyObject]?
    
    if let data = jsonText.data(using: String.Encoding.utf8) {
        
        do {
            
            dictionary = try JSONSerialization.jsonObject(with: data, options: []) as? [String:AnyObject]
            
            
            if let myDictionary = dictionary {
                print(" Json is in Dictionary Form: \(myDictionary)")
            }
            
            
            
        } catch let error as NSError {
            
            print("Error is : \(error)")
            
        }
        

        
    }
    
    
}

func appleSwiftBlogWorkingWithJsonAndSwift3() -> Void {
    
    
    let data: Data = Data()
    
    let json = try? JSONSerialization.jsonObject(with: data, options: [])
    
    if let dictionary = json as? [String: Any] {
        
        print("Dictionary is : \(dictionary)")
        
    }
}

/* Example Json
 
 {
	"name": "Caffè Macs",
	"coordinates":  {
    "lat": 37.330576,
    "lng": -122.029739
                    },
	"meals": ["breakfast", "lunch", "dinner"]
 }

 */

struct Restaurant {
    enum Meal: String {
        case breakfast, lunch, dinner
    }
    
    let name: String
    let location: (latitude: Double, longitude: Double)
    let meals: Set<Meal>
}


