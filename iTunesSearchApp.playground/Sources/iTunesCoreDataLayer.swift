import Foundation
import CoreData

public struct coreDataStackSetup {
    
    public var contextMain : NSManagedObjectContext? = nil
    
    public init() {
        
            if contextMain == nil {
            // Old in memory context
           // contextMain = createMainContext()
        
          // new SqlLiteContext
            contextMain = persistentContainer.viewContext
        }
        
    }
    
    // Core Data Stack Setup for In-Memory Store -- Pre iOS 10 Calls to Setup Core data
    public func createMainContext() -> NSManagedObjectContext {
        
        if let context = contextMain {
            
            return context
            
        } else {
            
            // Replace "Model" with the name of your model
            let modelUrl = Bundle.main.url(forResource: "iTunesCoreDataShadowProject", withExtension: "momd")
            guard let model = NSManagedObjectModel.init(contentsOf: modelUrl!) else { fatalError("model not found") }
            
            let psc = NSPersistentStoreCoordinator(managedObjectModel: model)
            try! psc.addPersistentStore(ofType: NSInMemoryStoreType, configurationName: nil, at: nil, options: nil)
            
            let context = NSManagedObjectContext(concurrencyType: .mainQueueConcurrencyType)
            context.persistentStoreCoordinator = psc
            
            return context

            
        }
        
    }
	
    // Core Data Setup for sqlLite Persistent Store -- New iOS 10 Calls to Setup Core Data - Need a shadow IOS XCode Project to work
    public var persistentContainer: NSPersistentContainer = {
        
        let container = NSPersistentContainer(name: "iTunesCoreDataShadowProject")
        
        container.loadPersistentStores(completionHandler: { (StoreDescription, posssibleError) in
            
            if let error = posssibleError as NSError? {
                
                print("Error occurred in loadPersistentStore callback")
                
            } else {
                
                // We created a persistent Store
                
                if let url = StoreDescription.url {
                    
                    print("location is : \(url.path)")

                    
                }
                
                let type = StoreDescription.type
                print("type is : \(type)")
                
                
            }
            
            
        })
        
        return container
        
    }()
	
	// Core Data Entity Created using Key value Coding -- Playgrounds don't yet Support NSManagedObject Subclass coding
    public func addiTunesStoreresultToCoreData(iTunesStoreresultObject: iTunesArtistSearchResult) -> String {
        
 
        if let context = self.contextMain {
            
            let ent = NSEntityDescription.insertNewObject(forEntityName: "ITunesSearchResult", into: context)
            
            ent.setValue(iTunesStoreresultObject.artistName, forKey: "artistName")
            ent.setValue(iTunesStoreresultObject.trackName, forKey: "trackName")
            ent.setValue(iTunesStoreresultObject.artworkUrl100, forKey: "artworkUrl100")
            ent.setValue(iTunesStoreresultObject.collectionName, forKey: "collectionName")
            ent.setValue(iTunesStoreresultObject.collectionPrice, forKey: "collectionPrice")
            ent.setValue(iTunesStoreresultObject.previewUrl , forKey: "previewUrl")
            
            
            print("Added to Core Data")
            _ = try? context.save()

            return "Added Item"
            
        }
        
        return "Did not Add Item"
        
    }
    
}



