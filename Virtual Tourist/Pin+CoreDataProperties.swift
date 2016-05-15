//
//  Pin+CoreDataProperties.swift
//  Virtual Tourist
//
//  Created by Alp Eren Can on 17/04/16.
//  Copyright © 2016 Alp Eren Can. All rights reserved.
//
//  Choose "Create NSManagedObject Subclass…" from the Core Data editor menu
//  to delete and recreate this implementation file for your updated model.
//

import Foundation
import CoreData

extension Pin {

    @NSManaged var latitude: Double
    @NSManaged var longitude: Double
    @NSManaged var numberOfPhotoPages: Int
    @NSManaged var photos: [Photo]?

}
