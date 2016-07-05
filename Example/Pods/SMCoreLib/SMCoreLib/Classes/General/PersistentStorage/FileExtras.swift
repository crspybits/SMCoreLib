//
//  FileExtras.swift
//  SharedNotes
//
//  Created by Christopher Prince on 5/22/16.
//  Copyright © 2016 Spastic Muffin, LLC. All rights reserved.
//

import Foundation

public class FileExtras {
    public static let defaultDirectoryPath = "LargeImages"
    public static let defaultFileExtension = ".jpg"
    public static let defaultFilePrefix = "img"
    
    // Change these if you want.
    public var directoryPathFromDocuments:String = FileExtras.defaultDirectoryPath
    public var fileExtension:String = FileExtras.defaultFileExtension
    public var filePrefix:String = FileExtras.defaultFilePrefix
    
    public init() {
    }
    
    public func newURLForImage() ->  SMRelativeLocalURL {
        let directoryURL = FileStorage.urlOfItem(self.directoryPathFromDocuments)
        FileStorage.createDirectoryIfNeeded(directoryURL)
        let newFileName = FileStorage.createTempFileNameInDirectory(directoryURL.path, withPrefix: self.filePrefix, andExtension: self.fileExtension)
        return SMRelativeLocalURL(withRelativePath: self.directoryPathFromDocuments + "/" + newFileName, toBaseURLType: .DocumentsDirectory)!
    }
}
