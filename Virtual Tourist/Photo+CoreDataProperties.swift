//
//  Photo+CoreDataProperties.swift
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

extension Photo {

    @NSManaged var id: String
    @NSManaged var title: String
    @NSManaged var imagePath: String
    @NSManaged var location: Pin

}
