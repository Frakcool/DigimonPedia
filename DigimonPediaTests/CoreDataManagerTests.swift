//
//  CoreDataManagerTests.swift
//  DigimonPedia
//
//  Created by Jesus Sanchez on 21/04/23.
//

import UIKit
import XCTest
import CoreData
@testable import DigimonPedia

final class CoreDataManagerTests: XCTestCase {
    var coreDataManager: CoreDataManager!
    var persistentContainer: NSPersistentContainer!

    override func setUp() {
        coreDataManager = CoreDataManager.shared
        persistentContainer = NSPersistentContainer(name: "DigimonCoreDataModel")
    }

    override func tearDown() {
        coreDataManager.purgeCache()
    }

    func testCoreDataManagerSharedInstanceIsNotNil() {
        XCTAssertNotNil(coreDataManager)
    }

    func testPersistentContainerShouldNotBeNil() {
        XCTAssertNotNil(coreDataManager.persistentContainer)
    }

    func testSaveNewImage() {
        let imageName = "new-image"
        let imageData = NSData(base64Encoded: "R0lGODlhAQABAIAAAAUEBAAAACwAAAAAAQABAAACAkQBADs=")!

        let expectation = XCTestExpectation(description: "Image saved to Core Data")

        coreDataManager.saveImage(imageData, name: imageName)

        DispatchQueue.main.asyncAfter(deadline: .now() + 2) {
            let savedImageData = CoreDataManager.shared.readImage(named: imageName)
            XCTAssertNotNil(savedImageData)
            expectation.fulfill()
        }

        wait(for: [expectation], timeout: 3)
    }

    func testSkipSaveExistingImage() {
        let imageName = "new-image"
        let imageData = NSData(base64Encoded: "R0lGODlhAQABAIAAAAUEBAAAACwAAAAAAQABAAACAkQBADs=")!

        let expectation1 = XCTestExpectation(description: "Image saved to Core Data")
        let expectation2 = XCTestExpectation(description: "Image saved to Core Data")

        coreDataManager.saveImage(imageData, name: imageName)

        DispatchQueue.main.asyncAfter(deadline: .now() + 2) {
            let savedImageData = CoreDataManager.shared.readImage(named: imageName)
            XCTAssertNotNil(savedImageData)

            self.coreDataManager.saveImage(imageData, name: imageName)
            expectation1.fulfill()
        }

        DispatchQueue.main.asyncAfter(deadline: .now() + 2) {
            let savedImageData = CoreDataManager.shared.readImage(named: imageName)
            XCTAssertNotNil(savedImageData)
            expectation2.fulfill()
        }

        wait(for: [expectation1, expectation2], timeout: 3)
    }
}
