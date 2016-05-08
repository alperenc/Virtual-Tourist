//
//  PhotoAlbumViewController.swift
//  Virtual Tourist
//
//  Created by Alp Eren Can on 07/03/16.
//  Copyright © 2016 Alp Eren Can. All rights reserved.
//

import UIKit
import CoreData
import MapKit

private let reuseIdentifier = "photoCell"

class PhotoAlbumViewController: UIViewController, UICollectionViewDataSource, UICollectionViewDelegate, UICollectionViewDelegateFlowLayout, NSFetchedResultsControllerDelegate {
    
    // MARK: Properties
    
    @IBOutlet weak var mapView: MKMapView!
    @IBOutlet weak var collectionView: UICollectionView!
    @IBOutlet weak var bottomButton: UIButton!
    
    var pin: Pin!
    
    // The selected indexes array keeps all of the indexPaths for cells that are "selected".
    var selectedIndexes = [NSIndexPath]()
    
    // Keep the changes. We will keep track of insertions, deletions, and updates.
    var insertedIndexPaths: [NSIndexPath]!
    var deletedIndexPaths: [NSIndexPath]!
    var updatedIndexPaths: [NSIndexPath]!
    
    // MARK: Life Cycle

    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Add annotation
        mapView.addAnnotation(pin)
        mapView.setRegion(MKCoordinateRegion(center: pin.coordinate, span: MKCoordinateSpanMake(5.0, 5.0)), animated: true)
        
        // Start the fetched results controller
        
        do {
            try fetchedResultsController.performFetch()
        } catch let error as NSError {
            print("Error performing initial fetch: \(error)")
        }
        
    }
    
    //MARK: Actions and Helpers
    
    @IBAction func bottomButtonPressed() {
        
        if selectedIndexes.isEmpty {
            deleteAllPhotos()
        } else {
            deleteSelectedPhotos()
        }
        
    }
    
    func deleteAllPhotos() {
        
        for photo in fetchedResultsController.fetchedObjects as! [Photo] {
            sharedContext.deleteObject(photo)
        }
        
        CoreDataStackManager.sharedInstance().saveContext()
        
        FlickrClient.sharedInstance().getPhotosForPin(pin) { (success, error) in
        }
    }
    
    func deleteSelectedPhotos() {
        var photosToDelete = [Photo]()
        
        for indexPath in selectedIndexes {
            photosToDelete.append(fetchedResultsController.objectAtIndexPath(indexPath) as! Photo)
        }
        
        for photo in photosToDelete {
            sharedContext.deleteObject(photo)
        }
        
        selectedIndexes = [NSIndexPath]()
    }
    
    func updateBottomButton() {
        
        if selectedIndexes.count > 0 {
            bottomButton.setTitle("Remove Selected Photos", forState: .Normal)
        } else {
            bottomButton.setTitle("New Collection", forState: .Normal)
        }
        
    }

    // MARK: - UICollectionViewDataSource
    
    func numberOfSectionsInCollectionView(collectionView: UICollectionView) -> Int {
        return self.fetchedResultsController.sections?.count ?? 0
    }

    func collectionView(collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        let sectionInfo = fetchedResultsController.sections![section]
        return sectionInfo.numberOfObjects
    }

    func collectionView(collectionView: UICollectionView, cellForItemAtIndexPath indexPath: NSIndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCellWithReuseIdentifier(reuseIdentifier, forIndexPath: indexPath) as! PhotoCollectionViewCell
        cell.activityIndicator.hidesWhenStopped = true
        cell.activityIndicator.startAnimating()
    
        // Configure the cell
        configureCell(cell, atIndexPath: indexPath)
    
        return cell
    }

    // MARK: UICollectionViewDelegate

    func collectionView(collectionView: UICollectionView, didSelectItemAtIndexPath indexPath: NSIndexPath) {
        
        let cell = collectionView.cellForItemAtIndexPath(indexPath) as! PhotoCollectionViewCell
        
        // Whenever a cell is tapped we will toggle its presence in the selectedIndexes array
        if let index = selectedIndexes.indexOf(indexPath) {
            selectedIndexes.removeAtIndex(index)
            cell.photoImageView.alpha = 1.0
        } else {
            selectedIndexes.append(indexPath)
            cell.photoImageView.alpha = 0.5
        }
        
        // And update the buttom button
        updateBottomButton()
        
    }
    
    // MARK: UICollectionViewDelegateFlowLayout
    
    func collectionView(collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAtIndexPath indexPath: NSIndexPath) -> CGSize {
        return CGSizeMake((collectionView.bounds.width - 32) / 3, (collectionView.bounds.width - 32) / 3)
    }
    
    // MARK: - Core Data Convenience
    
    var sharedContext: NSManagedObjectContext {
        return CoreDataStackManager.sharedInstance().managedObjectContext
    }
    
    // MARK: - NSFetchedResultsController
    
    lazy var fetchedResultsController: NSFetchedResultsController = {
        
        let fetchRequest = NSFetchRequest(entityName: "Photo")
        fetchRequest.predicate = NSPredicate(format: "location == %@", self.pin)
        fetchRequest.sortDescriptors = [NSSortDescriptor(key: "id", ascending: true)]
        
        let fetchedResultsController = NSFetchedResultsController(fetchRequest: fetchRequest, managedObjectContext: self.sharedContext, sectionNameKeyPath: nil, cacheName: nil)
        fetchedResultsController.delegate = self
        
        return fetchedResultsController
    }()
    
    // MARK: Fetched Results Controller Delegate
    
    // Whenever changes are made to Core Data the following three methods are invoked. This first method is used to create
    // three fresh arrays to record the index paths that will be changed.
    func controllerWillChangeContent(controller: NSFetchedResultsController) {
        
        // We are about to handle some new changes. Start out with empty arrays for each change type
        insertedIndexPaths = [NSIndexPath]()
        deletedIndexPaths = [NSIndexPath]()
        updatedIndexPaths = [NSIndexPath]()
        
        print("in controllerWillChangeContent")
        
    }
    
    // The second method may be called multiple times, once for each Photo object that is added, deleted, or changed.
    // We store the index paths into the three arrays.
    func controller(controller: NSFetchedResultsController, didChangeObject anObject: AnyObject, atIndexPath indexPath: NSIndexPath?, forChangeType type: NSFetchedResultsChangeType, newIndexPath: NSIndexPath?) {
        
        switch type{
            
        case .Insert:
            print("Insert an item")
            // We don't expect Photo instances to be inserted. But Core Data would notify us of insertions if any occured.
            // Here we are noting that a new Photo instance has been added to Core Data. We remember its index path
            // so that we can add a cell in "controllerDidChangeContent". Note that the "newIndexPath" parameter has
            // the index path that we want in this case
            insertedIndexPaths.append(newIndexPath!)
            break
        case .Delete:
            print("Delete an item")
            // Here we are noting that a Photo instance has been deleted from Core Data. We keep remember its index path
            // so that we can remove the corresponding cell in "controllerDidChangeContent". The "indexPath" parameter has
            // value that we want in this case.
            deletedIndexPaths.append(indexPath!)
            break
        case .Update:
            print("Update an item.")
            // This can be useful if you want to respond to changes
            // that come about after data is downloaded. For example, when an images is downloaded from
            // Flickr in the Virtual Tourist app
            updatedIndexPaths.append(indexPath!)
            break
        case .Move:
            print("Move an item. We don't expect to see this in this app.")
            break
        }
        
    }
    
    // This method is invoked after all of the changed in the current batch have been collected
    // into the three index path arrays (insert, delete, and upate). We now need to loop through the
    // arrays and perform the changes.
    //
    // The most interesting thing about the method is the collection view's "performBatchUpdates" method.
    // Notice that all of the changes are performed inside a closure that is handed to the collection view.
    func controllerDidChangeContent(controller: NSFetchedResultsController) {
        
        print("in controllerDidChangeContent. changes.count: \(insertedIndexPaths.count + deletedIndexPaths.count)")
        
        collectionView?.performBatchUpdates({() -> Void in
            
            for indexPath in self.insertedIndexPaths {
                self.collectionView?.insertItemsAtIndexPaths([indexPath])
            }
            
            for indexPath in self.deletedIndexPaths {
                self.collectionView?.deleteItemsAtIndexPaths([indexPath])
            }
            
            for indexPath in self.updatedIndexPaths {
                self.collectionView?.reloadItemsAtIndexPaths([indexPath])
            }
            
            }, completion: nil)
        
    }
    
    // MARK: Configure Cell
    
    func configureCell(cell: PhotoCollectionViewCell, atIndexPath indexPath: NSIndexPath) {
        
        let photo = fetchedResultsController.objectAtIndexPath(indexPath) as! Photo
        
        if photo.image != nil {
            cell.photoImageView.image = photo.image
            cell.activityIndicator.stopAnimating()
        } else {
            cell.taskToCancel = FlickrClient.sharedInstance().getImage(photo.imagePath) { (imageData, error) in
                if let imageData = imageData as? NSData {
                    dispatch_async(dispatch_get_main_queue()) {
                        cell.photoImageView.image = UIImage(data: imageData)
                        cell.activityIndicator.stopAnimating()
                    }
                }
            }
        }
        
    }

}
