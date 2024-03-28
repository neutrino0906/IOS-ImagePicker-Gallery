//
//  ImageDataEntity+CoreDataProperties.swift
//  Gallery
//
//  Created by Ground 2 on 12/03/24.
//
//

import Foundation
import CoreData


extension ImageDataEntity {

    @nonobjc public class func fetchRequest() -> NSFetchRequest<ImageDataEntity> {
        return NSFetchRequest<ImageDataEntity>(entityName: "ImageDataEntity")
    }

    @NSManaged public var uid: UUID?
    @NSManaged public var image: Data?

}

extension ImageDataEntity : Identifiable {

}
