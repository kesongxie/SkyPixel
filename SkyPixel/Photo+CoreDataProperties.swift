//
//  Photo+CoreDataProperties.swift
//  SkyPixel
//
//  Created by Xie kesong on 12/9/16.
//  Copyright © 2016 ___KesongXie___. All rights reserved.
//

import Foundation
import CoreData


extension Photo {

    @nonobjc public class func fetchRequest() -> NSFetchRequest<Photo> {
        return NSFetchRequest<Photo>(entityName: "Photo");
    }

    @NSManaged public var latitude: Double
    @NSManaged public var longitude: Double
    @NSManaged public var time: NSDate?
    @NSManaged public var title: String?
    @NSManaged public var thumbnailUrl: String?
    @NSManaged public var whoTook: User?

}
