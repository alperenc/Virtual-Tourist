//
//  Pin.swift
//  Virtual Tourist
//
//  Created by Alp Eren Can on 17/04/16.
//  Copyright © 2016 Alp Eren Can. All rights reserved.
//

import Foundation
import CoreData


class Pin: NSManagedObject {
    
    // Standard Core Data init method
    
    override init(entity: NSEntityDescription, insertIntoManagedObjectContext context: NSManagedObjectContext?) {
        super.init(entity: entity, insertIntoManagedObjectContext: context)
    }
    
    init(latitude: Double, longitude: Double, context: NSManagedObjectContext) {
        
        // Core Data
        let entity = NSEntityDescription.entityForName("Pin", inManagedObjectContext: context)!
        super.init(entity: entity, insertIntoManagedObjectContext: context)
        
        // Property initialization
        self.latitude = latitude
        self.longitude = longitude
        
    }

}
