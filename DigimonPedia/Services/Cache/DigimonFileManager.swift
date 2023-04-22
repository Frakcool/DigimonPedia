//
//  DigimonFileManager.swift
//  DigimonPedia
//
//  Created by Jesus Sanchez on 21/04/23.
//

import Foundation

class DigimonFileManager: PersistentCacheManager {
    static let shared = DigimonFileManager()

    private init() {
        
    }
    
    func saveImage(_ imageData: NSData, name: String) {
        guard let path = getFilePath(name: name) else {
            return
        }

        do {
            try imageData.write(to: path)
        } catch {
            print("Error saving file to cache")
        }
    }

    func readImage(named name: String) -> NSData? {
        guard let path = getFilePath(name: name) else {
            return nil
        }

        return NSData(contentsOf: path) ?? nil
    }

    func deleteImage(named name: String) {
        guard let path = getFilePath(name: name) else {
            return
        }

        do {
            try FileManager.default.removeItem(at: path)
        } catch {
            print("Cannot delete file from cache")
        }
    }

    func purgeCache() {
        guard let filesPath = getFilesPath() else {
            print("Cannot get files path")
            return
        }

        do {
            print("About to purge files directory")
            let files = try FileManager.default.contentsOfDirectory(atPath: filesPath.path())
            for file in files {
                deleteImage(named: file)
            }
        } catch {
            print("Error getting files path: \(error)")
        }
    }

    private func extractDigimonName(imageURLString: String) -> String? {
        return imageURLString.components(separatedBy: "/").last
    }

    private func getFilePath(name: String) -> URL? {
        guard let fileName = extractDigimonName(imageURLString: name) else {
            return nil
        }

        return getFilesPath()?.appendingPathComponent(fileName, isDirectory: false)
    }

    private func getFilesPath() -> URL? {
        return FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first
    }
}
