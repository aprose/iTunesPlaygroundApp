//: Playground App - Basically a Full App built with multiple ViewControllers & Core Data & REST call to iTunes API.
//: Uses NSLayoutConstraints in Code with UIStackview.
//: Uses  UICollection View and Networking Code.
//: Added Code NSLayoutConstraints to set the UICollectionView height and width properly for Simulator of Playground.
//: Note : This Code executes on an iPad with Swift Playgrounds & XCode 8 or above in Playground Mode.
//: Moreover : Coding Modifications were needed for the Playground when compared to normal iOS App - There are differences.

import UIKit
import PlaygroundSupport
import CoreData
import AVFoundation

//import NotificationCenter
//import MapKit

PlaygroundPage.current.needsIndefiniteExecution = true

/*
 Code below sets Up Core Data for a Playground
 Note : Core Data in Playground doesn't really work ( only in memory ) but it can be made to work
 by including an already compiled Managed Object Model and then using iOS 10 new Core Data calls with the exact
 name of the ".momd" ( compiled mom directory ) which results in the creation of a sqlLite Persistent Store.
 So Core Data can be tricked to work.
 */

// For some reason Playground Apps need global variables on the iPad in order to run properly ..

var imageGlobalCache = NSMutableDictionary()
var coreDataStack = coreDataStackSetup()

var context: NSManagedObjectContext!

if let theContext = coreDataStack.contextMain {
    
    print("Not nil context ")
    context = theContext
    
} else {
    
    context = coreDataStackSetup().createMainContext()
    
}



// Detail View Controller to show detail about found iTunes Song which we can also play and view progress
class iTunesInfoViewController: UIViewController {
    
    var progress = UIProgressView(progressViewStyle: .bar)
    var player: AVPlayer?
    var playerItem: AVPlayerItem?
    var playButton: UIButton?
    var iTunesSongOrItem : NSManagedObject?
    var activityIndicator : UIActivityIndicatorView?
    var playbackTimer : Timer?
    
    @objc func playButtonTapped(_ sender: UIButton) {
        
        if self.player?.rate == 0 {
            
            self.player?.play()
            
            // We use a Timer to repeat 0.5 seconds updating the Progress Bar graphically - then at end invalidate to stop closure
            
            print("The track length is : \(CMTimeGetSeconds((self.player?.currentItem?.duration)!))")
            if  CMTimeGetSeconds((self.player?.currentItem?.duration)!) > 0.0 {
                
                self.playbackTimer = Timer.scheduledTimer(withTimeInterval: 0.5, repeats: true, block: { (theTimer) in
                    
                    let seconds = self.player?.currentTime().seconds ?? 0.0
                    let duration = self.player?.currentItem?.duration.seconds ?? 0.0
                    
                    let anotherTest = seconds / duration
                    
                    print("Another testPercent is :\(Float(anotherTest))")
                    
                    self.progress.progress = Float(anotherTest)
                    
                    print("0.0 to 1.0 elapsed is : \( self.progress.progress)")
                    
                    if duration == seconds {
                        
                        self.progress.progress = 1
                        self.playButton?.setTitle("Play", for: .normal)
                        
                        theTimer.invalidate()
                    }
                    
                    
                })
                
            }
            
            
            self.playButton?.setTitle("Pause", for: .normal)
            
        } else {
            
            self.player?.pause()
            
            self.playButton?.setTitle("Play", for: .normal)
            
            
        }
        
        
    }
    
    // Only used for development
    func availableDuration() -> CMTime {
        
        
        if let range = self.player?.currentItem?.loadedTimeRanges.first {
            
            return CMTimeRangeGetEnd(range.timeRangeValue)
        }
        return kCMTimeZero
        
    }
    
    // Only used for development
    func createLayoutConstraints(theView : UIView) {
        
        //let leading = NSLayoutConstraint(item: theView, attribute: .leading, relatedBy: .equal, toItem: self.view, attribute: .leading, multiplier: 0, constant: 40)
        
        //let trailing = NSLayoutConstraint(item: theView, attribute: .trailing, relatedBy: .equal, toItem: self.view, attribute: .trailing, multiplier: 0, constant: 40)
        
        let top = NSLayoutConstraint(item: theView, attribute: .top, relatedBy: .equal, toItem: self.view, attribute: .top, multiplier: 1.0, constant: 100.00)
        
        let height = NSLayoutConstraint(item: theView, attribute: .height, relatedBy: .equal, toItem: nil, attribute: .notAnAttribute, multiplier: 1.0, constant: 50.0)
        
        let width = NSLayoutConstraint(item: theView, attribute: .width, relatedBy: .equal, toItem: nil, attribute: .notAnAttribute, multiplier: 1.0, constant: 200)
        
        let center = NSLayoutConstraint(item: theView, attribute: .centerX, relatedBy: .equal, toItem: self.view, attribute: .centerX, multiplier: 1.0, constant: 38.0)
        
        
        NSLayoutConstraint.activate([top,height,width,center])
        
        
        
    }
    
    // Normal lifeCycle event for ViewController
    override func viewDidDisappear(_ animated: Bool) {
        super.viewDidDisappear(animated)
        
    }
    
    
    // Once we leave Playground we must clean Up
    deinit {
        
        if let time = self.playbackTimer {
            
            time.invalidate()
            
        }
        
    }
    
    // SetUp the ViewController for action - We use a UIStackView created in Code with NSLayoutConstraints to lay out
    override func viewDidLoad() {
        super.viewDidLoad()
        
        let stackView = UIStackView()
        
        self.view.backgroundColor = #colorLiteral(red: 0.8039215803, green: 0.8039215803, blue: 0.8039215803, alpha: 1)
        self.title = ""
        
        if let ent = iTunesSongOrItem {
            
            // Get Core Data Entity Data for Display in Stack View
            
            let artistName = ent.value(forKey: "artistName") as?  String ?? ""
            let trackName = ent.value(forKey: "trackName") as? String ?? ""
            let artWork = ent.value(forKey: "artworkUrl100") as? String ?? ""
            let collectionName = ent.value(forKey: "collectionName") as? String ?? ""
            let collectionPrice = ent.value(forKey: "collectionPrice") as? String ?? ""
            let previewUrl = ent.value(forKey: "previewUrl") as? String ?? ""
            
            
            print("Artist info is: \(artistName) \(trackName) \(artWork) \(collectionName) \(collectionPrice) \(previewUrl)")
            
            self.title = trackName
            
            // Stack View Setup with Code Constraints using Visual Format Language to layout StackView
            
            stackView.translatesAutoresizingMaskIntoConstraints = false
            self.view.addSubview(stackView)
            
            self.view.addConstraints(NSLayoutConstraint.constraints(withVisualFormat: "V:|-70-[stackView]-80-|", options: NSLayoutFormatOptions.alignAllLeading, metrics: nil, views: ["stackView":stackView]))
            
            self.view.addConstraints(NSLayoutConstraint.constraints(withVisualFormat: "H:|-10-[stackView]-10-|", options: NSLayoutFormatOptions.alignAllLeading, metrics: nil, views: ["stackView":stackView]))
            
            
            stackView.axis = .vertical
            stackView.alignment = .fill
            stackView.spacing = 25
            stackView.distribution = .fillEqually
            
            let lbl = UILabel()
            lbl.text = "Artist Name : \(artistName)"
            lbl.textAlignment = .center
            lbl.backgroundColor = UIColor.lightGray
            stackView.addArrangedSubview(lbl)
            
            let lbl2 = UILabel()
            lbl2.text = "Track Name : \(trackName)"
            lbl2.backgroundColor = UIColor.lightGray
            lbl2.numberOfLines = 0
            lbl2.textAlignment = .center
            stackView.addArrangedSubview(lbl2)
            
            let lbl3 = UILabel()
            lbl3.text = "CollectionName : \(collectionName)"
            lbl3.backgroundColor = UIColor.lightGray
            lbl3.numberOfLines = 0
            lbl3.textAlignment = .center
            stackView.addArrangedSubview(lbl3)
            
            
            self.progress.layer.cornerRadius = 9
            self.progress.layer.masksToBounds = true
            self.progress.tintColor = #colorLiteral(red: 0.1960784346, green: 0.3411764801, blue: 0.1019607857, alpha: 1)
            self.progress.backgroundColor = UIColor.lightGray
            
            stackView.addArrangedSubview(self.progress)
            
            
            
            // AV Player items so we can play Preview of Song from iTunes
            
            if previewUrl != "" {
                
                if let url = URL(string: previewUrl) {
                    
                    let playerItem: AVPlayerItem = AVPlayerItem(url: url)
                    
                    self.player = AVPlayer(playerItem: playerItem)
                    
                    let playerLayer = AVPlayerLayer(player: self.player)
                    
                    playerLayer.frame = CGRect(x: 0, y: 0, width: 10, height: 50)
                    
                    
                    self.view.layer.addSublayer(playerLayer)
                    
                    self.playButton = UIButton(type: UIButtonType.system) as UIButton
                    
                    playButton?.backgroundColor = UIColor.lightGray
                    playButton?.setTitle("Play", for: .normal)
                    playButton?.tintColor = UIColor.blue
                    playButton?.addTarget(self, action: #selector(iTunesInfoViewController.playButtonTapped(_:)), for: .touchUpInside)
                    
                    playButton?.frame = CGRect(x: 0, y: 0, width: 200, height: 50)
                    
                    var center = self.view.center
                    center.x = center.x / 2
                    center.y = center.y / 4
                    
                    
                    
                    self.playButton?.translatesAutoresizingMaskIntoConstraints = false
                    
                    
                    stackView.addArrangedSubview(self.playButton!)
                    
                    
                }
                
                
                
                
            }
            
            
            
            // Image Download Items
            
            if artWork != "" {
                
                // get artwork from Apple and Show Spinner to User to show Activity
                
                self.activityIndicator = UIActivityIndicatorView(activityIndicatorStyle: .whiteLarge)
                
                
                var center = self.view.center
                center.x = center.x / 2
                center.y = center.y / 2
                self.activityIndicator?.hidesWhenStopped = true
                self.activityIndicator?.startAnimating()
                
                self.view.addSubview(self.activityIndicator!)
                
                self.activityIndicator?.translatesAutoresizingMaskIntoConstraints = false
                
                // Position activity indicator with Constraints in Code
                
                let centerX = NSLayoutConstraint(item: self.activityIndicator!, attribute: .centerX, relatedBy: .equal, toItem: self.view, attribute: .centerX, multiplier: 1.0, constant: 0)
                
                
                let centerY = NSLayoutConstraint(item: self.activityIndicator!, attribute: .centerY, relatedBy: .equal, toItem: self.view, attribute: .centerY, multiplier: 1.0, constant: 0)
                
                NSLayoutConstraint.activate([centerX,centerY])
                
                
                
                if let imageUrl = URL(string: artWork) {
                    
                    let imageView = UIImageView(frame: CGRect(x: 0, y: 0, width: 200, height: 200))
                    
                    
                    imageView.center = center
                    
                    
                    DispatchQueue.global().async {
                        
                        if let imageData: NSData = try? NSData(contentsOf: imageUrl) {
                            
                            
                            DispatchQueue.main.async {
                                
                                let image = UIImage(data: imageData as Data)
                                imageView.image = image
                                imageView.contentMode = UIViewContentMode.scaleAspectFit
                                
                                stackView.addArrangedSubview(imageView)
                                
                                
                                self.activityIndicator?.stopAnimating()
                                
                                
                            }
                            
                        }
                        
                        
                    }
                    
                    
                    
                }
                
                
                
                
            }
            
        }
        
        
    }
    
    
    
}

// Note : Not used UICollectionViewCell
class MyCollectionViewCell: UICollectionViewCell {
    
    override init(frame: CGRect) {
        super.init(frame: frame)
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}


// Note : Not used UICollectionViewController
class TabZeroViewController: UICollectionViewController {
    
    
    var items = ["1","2","3"]
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.view.backgroundColor = #colorLiteral(red: 0.2392156869, green: 0.6745098233, blue: 0.9686274529, alpha: 1)
        self.title = "Tab 0"
        
        self.view.bounds
        
        self.collectionView?.register(MyCollectionViewCell.self, forCellWithReuseIdentifier:  "collectionCell")
        
        print("Up to here")
        
    }
    
    override func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        
        return 1
    }
    
    override func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "collectionCell", for: indexPath)
        
        //let cell = UICollectionViewCell()
        
        cell.backgroundColor = #colorLiteral(red: 0.4666666687, green: 0.7647058964, blue: 0.2666666806, alpha: 1)
        
        return cell
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        return CGSize(width: 100, height: 100)
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, insetForSectionAt section: Int) -> UIEdgeInsets {
        return UIEdgeInsets(top: 20, left: 10, bottom: 20, right: 10)
    }
    
    
    
    
    
    
    
    
}


// Method that works for UICollectionView with Playgrounds is below : Setup a ViewController with UICollectionView as a SubView and necessary Delegates

class TabOneViewController: UIViewController, UICollectionViewDataSource, UICollectionViewDelegateFlowLayout, UICollectionViewDelegate {
    
    var fetchedResultsController: NSFetchedResultsController<NSManagedObject>?
    
    var activityIndicator : UIActivityIndicatorView?
    
    var items = ["1","2","3"]
    
    var theCollectionView : UICollectionView?
    
    var theCurrentArtist = ""
    
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        // self.theCollectionView?.reloadData()
        
    }
    
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        
        self.title = "Album Covers"
        
        // Create UICollectionView and a flow Layout
        
        let flowlayout = UICollectionViewFlowLayout()
        let collectionView = UICollectionView(frame: self.view.bounds, collectionViewLayout: flowlayout)
        self.view.bounds
        collectionView.bounds
        self.view.frame
        collectionView.frame
        
        
        
        collectionView.register(UICollectionViewCell.self, forCellWithReuseIdentifier: "CellOne")
        
        collectionView.delegate = self
        collectionView.dataSource = self
        
        collectionView.backgroundColor = #colorLiteral(red: 0.8039215803, green: 0.8039215803, blue: 0.8039215803, alpha: 1)
        
        collectionView.bounces = true
        collectionView.alwaysBounceVertical = true
        collectionView.alwaysBounceHorizontal = false
        
        
        self.theCollectionView = collectionView
        
        self.view.addSubview(collectionView)
        
        self.theCollectionView?.translatesAutoresizingMaskIntoConstraints = false
        
        // Create Constraints for CollectionView for Playground : if this is not done properly then Collection View in Playground will be bigger than parent View - tricky setup because bounds of screen doesn't match self.view of main view and no documentation tells you this
        
        NSLayoutConstraint.activate([(self.theCollectionView?.leadingAnchor.constraint(equalTo: (self.view.leadingAnchor)))!,(self.theCollectionView?.trailingAnchor.constraint(equalTo: (self.view.trailingAnchor)))!,(self.theCollectionView?.topAnchor.constraint(equalTo: (self.view.topAnchor)))!,(self.theCollectionView?.bottomAnchor.constraint(equalTo: (self.view.bottomAnchor)))!])
        
        
        // Handle the rest of setup here : UIRefreshControl & Core Data Fetch Results Controller
        
        self.theCollectionView?.refreshControl = UIRefreshControl()
        self.theCollectionView?.refreshControl?.addTarget(self, action: #selector(handleCollectionViewRefresh(_:)), for: UIControlEvents.valueChanged)
        
        self.theCollectionView?.refreshControl?.tintColor = #colorLiteral(red: 0.2392156869, green: 0.6745098233, blue: 0.9686274529, alpha: 1)
        
        let fr = NSFetchRequest<NSManagedObject>(entityName: "ITunesSearchResult")
        
        fr.sortDescriptors = [NSSortDescriptor(key: "artistName", ascending: true)]
        
        fetchedResultsController = NSFetchedResultsController(fetchRequest: fr, managedObjectContext: context, sectionNameKeyPath: nil, cacheName: nil)
        
        do {
            
            try fetchedResultsController?.performFetch()
            
            if let count = fetchedResultsController?.fetchedObjects?.count {
                
                print("Objects received is : \(count)")
                
                
                if let artistName = fetchedResultsController?.fetchedObjects?.first?.value(forKey: "artistName") as? String {
                    
                    let result = self.theCurrentArtist.compare(artistName)
                    
                    if result == .orderedSame {
                        
                        print("Then dont reload images")
                    }
                    
                    // save current artist for KVC observing for future auto updates code to write - Notification don't work on Swift Playgrounds on iPad only on Mac XCode 8 equal to or greater
                    
                    self.theCurrentArtist = artistName
                    
                }
                
                
                
                
                // Fill the Image Cache
                
                // ViewDidLoad Only gets executes once for Playground App with UITabController
                
                // Show User we are updating
                
                let point = CGPoint(x: 0, y: -(self.theCollectionView?.refreshControl?.bounds.height)!)
                self.theCollectionView?.setContentOffset(point, animated: true)
                
                self.theCollectionView?.refreshControl?.beginRefreshing()
                
                // Dispatch to a backgound thread
                
                DispatchQueue.global().async {
                    
                    for oneObject in (self.fetchedResultsController?.fetchedObjects)!  {
                        
                        if let name = oneObject.value(forKey: "artworkUrl100") as? String
                        {
                            print("View Did Load Artwork url is \(name)")
                            self.loadArtWorkIntoCache(artWorkToLoad: name)
                        }
                        
                    }
                    
                    // Time to Update the UI for User
                    
                    DispatchQueue.main.async {
                        
                        self.theCollectionView?.reloadData()
                        self.theCollectionView?.refreshControl?.endRefreshing()
                        
                    }
                    
                }
                
            }
            
            
        } catch let error as NSError {
            
            print("Fetching error : \(error), \(error.userInfo)")
            
        }
        
    }
    
    
    // When User pulls down to refresh the UICollection View we Refresh Albums Pictures
    
    func refreshAlbums() {
        
        // The Core Data FetchResultsController has a good "Memory" so we only need to perform the old fetch to update
        
        try? self.fetchedResultsController?.performFetch()
        
        
        if let objects = self.fetchedResultsController?.fetchedObjects {
            
            imageGlobalCache.removeAllObjects()
            
            // All the rest on Other Thread
            
            DispatchQueue.global().async {
                
                for oneObject in objects  {
                    
                    if let name = oneObject.value(forKey: "artworkUrl100") as? String
                    {
                        print("refreshAlbums Artwork url is \(name)")
                        self.loadArtWorkIntoCache(artWorkToLoad: name)
                    }
                    
                }
                
                // Main Thread to update UI for User
                
                DispatchQueue.main.async {
                    
                    self.theCollectionView?.reloadData()
                    self.theCollectionView?.refreshControl?.endRefreshing()
                    
                }
                
                
                
            }
            
            
        }
        
        
        
        
        
    }
    
    // Target Action Call for Spinner which User has dragged down to refresh
    
    @objc func handleCollectionViewRefresh(_ sender: Any) {
        
        self.refreshAlbums()
        
    }
    
    // Standard Delegate Call for UICollectionView to Know what its doing
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        
        return self.fetchedResultsController?.fetchedObjects?.count ?? 0
    }
    
    // Standard Delegate Call for UICollectionView - Here we can use dequeueReuseablecell - on UITableView we could't and Playground would crash. We get Image from our image Cache which on iPad Pro Playground can only have 25 Items...
    
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "CellOne", for: indexPath)
        
        if  let iTunesInfo = fetchedResultsController?.object(at: indexPath), let name = iTunesInfo.value(forKey: "artworkUrl100") as? String
        {
            // Old Code commented out
            // self.loadArtWork(artWorkToLoad: name, collectionCell: cell)
            
            if let imageExists = imageGlobalCache.value(forKey: name) as? Data {
                
                let imageView = UIImageView(frame: cell.bounds)
                
                let image = UIImage(data: imageExists)
                imageView.image = image
                imageView.contentMode = UIViewContentMode.scaleAspectFit
                cell.addSubview(imageView)
                
                
            }
            
            
        }
        
        return cell
    }
    
    // Standard Delegate Call for UICollectionView to set Size of CollectionViewCell
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        return CGSize(width: 100, height: 100)
    }
    
    // Standard Delegate Call for UICollectionView to set insets for UICollectionView so looks better
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, insetForSectionAt section: Int) -> UIEdgeInsets {
        return UIEdgeInsets(top: 20, left: 10, bottom: 20, right: 10)
    }
    
    // Code to speed up the Image Scrolling Process by downloading all images into a Cache
    
    func loadArtWorkIntoCache(artWorkToLoad artWork: String) {
        
        if artWork != "" {
            
            if let imageUrl = URL(string: artWork), let imageData = try? Data(contentsOf: imageUrl) {
                
                imageGlobalCache.setValue(imageData, forKey: artWork)
                print("loading into Global Cache \(artWork)")
                
            }
        }
    }
    
    // Old Code to Download Images of Albums of Artists no Cache Used
    
    func loadArtWork(artWorkToLoad artWork: String, collectionCell cell: UICollectionViewCell) {
        
        if artWork != "" {
            
            
            if let imageUrl = URL(string: artWork) {
                
                let imageView = UIImageView(frame: cell.bounds)
                
                DispatchQueue.global().async {
                    
                    if let imageData: NSData = try? NSData(contentsOf: imageUrl) {
                        
                        
                        DispatchQueue.main.async {
                            
                            let image = UIImage(data: imageData as Data)
                            imageView.image = image
                            imageView.contentMode = UIViewContentMode.scaleAspectFit
                            cell.addSubview(imageView)
                            
                            
                        }
                        
                    }
                    
                    
                }
                
            }
            
        }
        
    }
    
}

// ViewController Not Used Yet

class TabTwoViewController: UIViewController /*, MKMapViewDelegate */ {
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.view.backgroundColor = #colorLiteral(red: 0.4666666687, green: 0.7647058964, blue: 0.2666666806, alpha: 1)
        self.title = "Tab 2"
        
    }
    
}



// Main UITableViewController to "Search iTunes for Music"

class TabThreeViewController : UITableViewController {
    
    var loginTextField: UITextField?
    
    let searchBar: UISearchBar? = nil
    
    var coreDataItems: [NSManagedObject] = []
    
    var fetchedResultsController: NSFetchedResultsController<NSManagedObject>?
    
    var currentArtistToSearchFor: String?
    
    init() {
        
        super.init(style: .plain)
        
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    // User can drag the UITableView Down to Refresh the Data
    
    @objc func handleTableRefresh(_ sender: Any) {
        
        print("Updated Data")
        
        if let textToFind = loginTextField?.text {
            
            self.searchiTunesForMusic(itemToFind: textToFind)
        } else {
            
            (sender as? UIRefreshControl)?.endRefreshing()
            
        }
        
        
        
    }
    
    // TO DO : Future Rewrite of function to minimize length and Use Networking Completion Closure
    
    func searchiTunesForMusicWithURLSessionAndCompletion(itemToFind: String) {
        
        DispatchQueue.global().async {
            
            let callLayer = letsSearchiTunes()
            
            let url = callLayer.iTunesURL(searchText: itemToFind)
            
            let textJson = callLayer.performStoreRequest(with: url)
            
            if let dictionary = callLayer.parse(json: textJson) {
                
                if let oneTest = dictionary["results"] {
                    
                    if let oneArray = oneTest as? Array<NSDictionary> {
                        
                        
                        // print("Dictionary is : \(oneArray.first)")
                        
                        // Delete all data from Core Data with BatchDelete before refilling with New Data
                        
                        do {
                            
                            try self.fetchedResultsController?.performFetch()
                            
                            if let count = self.fetchedResultsController?.fetchedObjects?.count {
                                
                                let fetch = NSFetchRequest<NSFetchRequestResult>(entityName: "ITunesSearchResult")
                                let request = NSBatchDeleteRequest(fetchRequest: fetch)
                                
                                try self.fetchedResultsController?.managedObjectContext.execute(request)
                                
                                print("Objects deleted is : \(count)")
                            }
                            
                            
                            
                        } catch let error as NSError {
                            
                            print("Fetching error : \(error), \(error.userInfo)")
                            
                            DispatchQueue.main.async {
                                self.refreshControl?.endRefreshing()
                            }
                            
                            
                            
                        }
                        
                        
                        for item in oneArray {
                            
                            if let testiTunesInit = iTunesArtistSearchResult(json: item as! [String : Any]) {
                                
                                // Add to Core Data and Output a String which we can view in Console
                                
                                print(" Item was : \(coreDataStack.addiTunesStoreresultToCoreData(iTunesStoreresultObject: testiTunesInit) ) ")
                                print("One itunes object is : \(testiTunesInit)")
                                
                                DispatchQueue.main.async {
                                    try? self.fetchedResultsController?.performFetch()
                                    self.tableView.reloadData()
                                }
                                
                                
                            }
                        }
                        
                    }
                    
                    
                }
                
            }
            
            // At end of Async call end Refreshing of Spinner so User know we are complete
            
            DispatchQueue.main.async {
                self.refreshControl?.endRefreshing()
            }
        }
        
        
    }
    
    // Current Standard Function to Search iTunes and fill Core Data - at moment same as above
    
    func searchiTunesForMusic(itemToFind: String) {
        
        DispatchQueue.global().async {
            
            let callLayer = letsSearchiTunes()
            
            let url = callLayer.iTunesURL(searchText: itemToFind)
            
            let textJson = callLayer.performStoreRequest(with: url)
            
            if let dictionary = callLayer.parse(json: textJson) {
                
                if let oneTest = dictionary["results"] {
                    
                    if let oneArray = oneTest as? Array<NSDictionary> {
                        
                        
                        //  print("Dictionary is : \(oneArray.first)")
                        
                        
                        do {
                            
                            try self.fetchedResultsController?.performFetch()
                            
                            if let count = self.fetchedResultsController?.fetchedObjects?.count {
                                
                                let fetch = NSFetchRequest<NSFetchRequestResult>(entityName: "ITunesSearchResult")
                                let request = NSBatchDeleteRequest(fetchRequest: fetch)
                                
                                try self.fetchedResultsController?.managedObjectContext.execute(request)
                                
                                print("Objects deleted is : \(count)")
                            }
                            
                            
                            
                        } catch let error as NSError {
                            
                            print("Fetching error : \(error), \(error.userInfo)")
                            
                            DispatchQueue.main.async {
                                self.refreshControl?.endRefreshing()
                            }
                            
                            
                            
                        }
                        
                        
                        for item in oneArray {
                            
                            if let testiTunesInit = iTunesArtistSearchResult(json: item as! [String : Any]) {
                                
                                print(" Item was : \(coreDataStack.addiTunesStoreresultToCoreData(iTunesStoreresultObject: testiTunesInit) ) ")
                                print("One itunes object is : \(testiTunesInit)")
                                
                                DispatchQueue.main.async {
                                    try? self.fetchedResultsController?.performFetch()
                                    self.tableView.reloadData()
                                }
                                
                                
                            }
                        }
                        
                    }
                    
                    
                }
                
            }
            
            
            DispatchQueue.main.async {
                self.refreshControl?.endRefreshing()
            }
        }
        
        
    }
    
    // SetUp the UITableViewController at start with everything it needs such as a refresher and a button to carry out searches
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.tableView?.refreshControl = UIRefreshControl()
        self.tableView?.refreshControl?.addTarget(self, action: #selector(handleTableRefresh(_:)), for: UIControlEvents.valueChanged)
        
        self.tableView?.refreshControl?.tintColor = UIColor.blue
        
        if self.navigationController != nil {
            
            title = "Search iTunes for Music"
            
            let showButton = UIBarButtonItem(barButtonSystemItem: .search, target: self, action: #selector(handleSearchPress(sender:)))
            
            navigationItem.rightBarButtonItem = showButton
            
        }
        
        self.tableView.dataSource = self
        self.tableView.delegate = self
        
        
        // SetUp Core Data FetchedResultsController
        
        
        let fr = NSFetchRequest<NSManagedObject>(entityName: "ITunesSearchResult")
        
        fr.sortDescriptors = [NSSortDescriptor(key: "artistName", ascending: true)]
        
        fetchedResultsController = NSFetchedResultsController(fetchRequest: fr, managedObjectContext: context, sectionNameKeyPath: nil, cacheName: nil)
        
        do {
            
            try fetchedResultsController?.performFetch()
            
            let count = fetchedResultsController?.fetchedObjects?.count
            // print("Objects received is : \(count)")
            
        } catch let error as NSError {
            
            print("Fetching error : \(error), \(error.userInfo)")
            
        }
        
        
    }
    
    
    // Show an UIAlertView so User can type in Search Text for Searching in iTunes - in closure we search and show Refresh Control
    
    @objc func handleSearchPress(sender: UIBarButtonItem) -> Void {
        
        print("UIBarButtonItem pressed")
        
        let alertController = UIAlertController(title: "Search iTunes", message: nil, preferredStyle: .alert)
        let cancelAction = UIAlertAction(title: "Cancel", style: .cancel, handler: nil)
        let okAction = UIAlertAction(title: "OK", style: .default, handler:{ (action) -> Void in
            
            if let itemToFind = self.loginTextField?.text {
                print("Artist is : \(itemToFind)")
                
                self.currentArtistToSearchFor = itemToFind
                
                let point = CGPoint(x: 0, y: -(self.refreshControl?.bounds.height)!)
                self.tableView.setContentOffset(point, animated: true)
                
                self.refreshControl?.beginRefreshing()
                
                self.searchiTunesForMusic(itemToFind: itemToFind)
            }
            
        })
        alertController.addAction(cancelAction)
        alertController.addAction(okAction)
        alertController.addTextField { (textField) in
            
            self.loginTextField = textField
            self.loginTextField?.placeholder = "Enter Artist to find .."
            
        }
        self.present(alertController, animated: true, completion: nil)
        
        
    }
    
    // Standard Lifecycle Events for UITableView
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        
        guard let sectionInfo = fetchedResultsController?.sections?[section] else {
            return 0
        }
        
        print("number of objects is : \(sectionInfo.numberOfObjects)")
        
        return Int(sectionInfo.numberOfObjects)
    }
    
    // Standard Lifecycle Events for UITableView - Must use in Playground UITableViewCell() Init because cannot use standard dequeueReuseableCell without crashing Playground ...
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        //let cell = tableView.dequeueReusableCell(withIdentifier: "cell", for: indexPath)
        
        let cell = UITableViewCell(style: UITableViewCellStyle.subtitle, reuseIdentifier: "test")
        
        print("Row is : \(indexPath.row)")
        
        if  let iTunesInfo = fetchedResultsController?.object(at: indexPath), let name = iTunesInfo.value(forKey: "artistName") as? String, let track = iTunesInfo.value(forKey: "trackName") as? String {
            
            cell.textLabel?.text = name
            cell.detailTextLabel?.text = track
            
        }
        
        
        return cell
    }
    
    
    // If User Selects a song in UITableView then we transition to Detail ViewController
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        
        let objectSelected = self.fetchedResultsController?.object(at: indexPath)
        
        if let object = objectSelected {
            
            print("Object found is: \(object.debugDescription)")
            
            let nextVC = iTunesInfoViewController()
            nextVC.iTunesSongOrItem = object
            //let navController = UINavigationController(rootViewController: nextVC)
            self.navigationController?.pushViewController(nextVC, animated: true)
            
            
        }
        
    }
    
    
    
}

// The Main Entry Point for the App is the TabBarController

class TabViewController: UITabBarController, UITabBarControllerDelegate {
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.delegate = self
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        
        let tabZero = TabZeroViewController(collectionViewLayout: UICollectionViewFlowLayout())
        let tabZeroBarItemImage = UIImage(named: "Photos@2x")
        
        let tabZeroBarItem = UITabBarItem(title: "Tab 0", image: tabZeroBarItemImage, tag: 0)
        
        tabZero.tabBarItem = tabZeroBarItem
        
        
        let tabOne = TabOneViewController()
        let nav2 = UINavigationController(rootViewController: tabOne)
        let tabOneBarItemImage = UIImage(named: "Groceries@2x")
        
        let tabOneBarItem = UITabBarItem(title: "Albums", image: tabOneBarItemImage, tag: 1)
        
        tabOne.tabBarItem = tabOneBarItem
        
        let tabTwo = TabTwoViewController()
        let tabTwoBarItemImage = UIImage(named: "Appointments@2x")
        
        let tabTwoBarItem = UITabBarItem(title: "Tab 2", image: tabTwoBarItemImage, tag: 2)
        
        
        tabTwo.tabBarItem = tabTwoBarItem
        
        
        let tabThree = TabThreeViewController()
        let nav1 = UINavigationController(rootViewController: tabThree)
        
        let tabThreeBarItemImage = UIImage(named: "Birthdays@2x")
        
        let tabThreeBarItem = UITabBarItem(title: "Search iTunes for Music", image: tabThreeBarItemImage, tag: 3)
        
        tabThree.tabBarItem = tabThreeBarItem
        
        
        // We are only showing two Tabs each with UINavigationControllers as below - two tabs unused for future features
        
        self.viewControllers = [nav1,nav2]
        
    }
    
    // Delegate Listener for when User selects a tab
    
    func tabBarController(_ tabBarController: UITabBarController, didSelect viewController: UIViewController) {
        
        // print("Selected the ViewController \(viewController.title)")
        
    }
    
    
}



// Make Sure LiveView of the Playground Page has the TabBarViewController so the Simulator on the right side of the Playground will show the App and allow for Touches and User Interaction

PlaygroundPage.current.liveView = TabViewController()
