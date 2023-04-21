//
//  DigimonImage+CoreDataProperties.swift
//  DigimonPedia
//
//  Created by Jesus Sanchez on 21/04/23.
//
//

import Foundation
import CoreData


extension DigimonImage {

    @nonobjc public class func fetchRequest() -> NSFetchRequest<DigimonImage> {
        return NSFetchRequest<DigimonImage>(entityName: "DigimonImage")
    }

    @NSManaged public var imageData: Data?
    @NSManaged public var imageName: String?

}

extension DigimonImage : Identifiable {

}
