import Foundation

// iTunes Json Data is returned in a particulat Format which is inculded in commented out text below
public struct iTunesArtistSearchResult {
    
//    artistId = 78500;
//    artistName = U2;
//    artistViewUrl = "https://itunes.apple.com/us/artist/u2/id78500?uo=4";
//    artworkUrl100 = "http://is4.mzstatic.com/image/thumb/Music/v4/f3/57/8e/f3578e0f-59c2-25c6-76d8-d05e11ecb48e/source/100x100bb.jpg";
//    artworkUrl30 = "http://is4.mzstatic.com/image/thumb/Music/v4/f3/57/8e/f3578e0f-59c2-25c6-76d8-d05e11ecb48e/source/30x30bb.jpg";
//    artworkUrl60 = "http://is4.mzstatic.com/image/thumb/Music/v4/f3/57/8e/f3578e0f-59c2-25c6-76d8-d05e11ecb48e/source/60x60bb.jpg";
//    collectionCensoredName = "U218 Singles (Deluxe Version)";
//    collectionExplicitness = notExplicit;
//    collectionId = 205155692;
//    collectionName = "U218 Singles (Deluxe Version)";
//    collectionPrice = "16.99";
//    collectionViewUrl = "https://itunes.apple.com/us/album/stuck-in-moment-you-cant-get/id205155692?i=205155743&uo=4";
//    country = USA;
//    currency = USD;
//    discCount = 2;
//    discNumber = 1;
//    isStreamable = 1;
//    kind = song;
//    previewUrl = "http://a1062.phobos.apple.com/us/r1000/016/Music4/v4/e6/0e/4a/e60e4aa3-e36f-92de-7d53-f0cd088fe271/mzaf_30404621107467148.plus.aac.p.m4a";
//    primaryGenreName = Rock;
//    releaseDate = "2006-11-20T08:00:00Z";
//    trackCensoredName = "Stuck In a Moment You Can't Get Out Of";
//    trackCount = 19;
//    trackExplicitness = notExplicit;
//    trackId = 205155743;
//    trackName = "Stuck In a Moment You Can't Get Out Of";
//    trackNumber = 8;
//    trackPrice = "1.29";
//    trackTimeMillis = 272347;
//    trackViewUrl = "https://itunes.apple.com/us/album/stuck-in-moment-you-cant-get/id205155692?i=205155743&uo=4";
//    wrapperType = track;

    
    
    
// Properties of lightweight Class below
    let trackType: String
    let trackKind: String
    let artistName: String
    let trackName: String
    
    let artworkUrl100: String
    let collectionName: String
    let collectionPrice: String
    let currency: String
    let trackPrice: String
    let previewUrl: String
    
    
}

// Extend the struct to include a lightweight failable initializer which receives it data direct from a json Dictionary.
public extension iTunesArtistSearchResult {
    
    init?(json: [String: Any]) {
        
		
        self.trackType = json["wrapperType"] as? String ?? ""
        self.trackKind = json["kind"] as? String ?? ""
        self.artistName = json["artistName"] as? String ?? ""
        self.trackName = json["trackName"] as? String ?? ""
        self.artworkUrl100 = json["artworkUrl100"] as? String ?? ""
        self.collectionName = json["collectionName"] as? String ?? ""
        self.collectionPrice = json["collectionPrice"] as? String ?? ""
        self.currency = json["currency"] as? String ?? ""
        self.trackPrice = json["trackPrice"] as? String ?? ""
        self.previewUrl = json["previewUrl"] as? String ?? ""
        
        print("called init")
        
    }
    
    
}


// Networking Code Below put into a Struct - same Code as put into Second Page of Playground for testing purposes
public struct letsSearchiTunes {
    
    
    
    public init() {
        
    }
    
    // Build togther a query URL based on text that has been escaped
    public func iTunesURL(searchText: String) -> URL {
        
        let escapedSearchText = searchText.addingPercentEncoding(withAllowedCharacters: CharacterSet.urlQueryAllowed)!
        
        let urlString = String(format: "https://itunes.apple.com/search?term=%@&limit=25", escapedSearchText)
        let url = URL(string: urlString)
        
        return url!
    }
	
	// Simple way of getting Json text but will block main Thread unless used with Dispatch Async -- better to use URLSession Code further down
    public func performStoreRequest(with url: URL) -> String {
        
        do {
            
            return try String(contentsOf: url, encoding: .utf8)
            
        } catch let error {
            
            print("Download error of : \(error)")
            
            return ""
        }
    }
    
    
    
    
    // Parse Json String by converting to NSData then use JSONSerialization Foundation call
    public func parse(json : String) -> [String: Any]? {
        
        guard let data = json.data(using: .utf8, allowLossyConversion: false) else {
            return nil
        }
        
        
        do {
            
            return try JSONSerialization.jsonObject(with: data, options: []) as? [String: Any]
            
        } catch let theError {
            
            print("Json Error received is: \(theError)")
            
            return nil
            
        }
        
    }
	
	// URLSession Code with Completion Handler Closure to fetch Json from iTunes
    public func searchiTunesForMusic(itemToFind: String, completionHandlerForFoundItems: @escaping ([String: Any]?) -> ()) {
        
        let callLayer = letsSearchiTunes()
        
        let theURL = callLayer.iTunesURL(searchText: itemToFind)
        
        
        URLSession.shared.dataTask(with: theURL , completionHandler: { (theOptionalData, theOptionalResponse, theOptionalError) in
            
            
            guard let data = theOptionalData else {
                
                return
            }
            
            if let result = try? JSONSerialization.jsonObject(with: data, options: []) as? [String:Any] {
                
                
                completionHandlerForFoundItems(result)
                
            }
            
        }).resume()
        
    }
    
    
    
    
    
}
