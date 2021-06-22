import Foundation
import UniformTypeIdentifiers
import os

public extension FileManager
{
    // MARK: - Constants & Variables
    
    /// The prefix to be used in the file creation/search methods.
    static var s_FileNamePrefix: String = Bundle.main.bundleIdentifier! + "-"
    
    static var s_LoggerCategory: String = "FileManager"
    static let s_Logger: Logger = .init(subsystem: Bundle.main.bundleIdentifier!, category: FileManager.s_LoggerCategory)
}

public extension FileManager
{
    // MARK: - Methods
    
    /// - Returns: The directory URL for given search path.
    static func getDirectoryUrlIn(directory: FileManager.SearchPathDirectory, domainMask: FileManager.SearchPathDomainMask) -> URL?
    {
        guard let directoryUrl = FileManager.default.urls(for: directory, in: domainMask).first
        else
        {
            s_Logger.error("Failed to get the URL with search path directory '\(directory.rawValue, privacy: .public)', and domain mask '\(domainMask.rawValue, privacy: .public)'")
            
            return nil
        }
        
        return directoryUrl
    }
    
    /// Creates an URL with given file name, in directory. If the file name isn't provided, it will create a file name.
    /// - Parameters:
    ///   - fileName: The name of the file that the URL should point at.
    ///   - contentType: The content type of the file the URL should point at.
    ///   - directory: The directory in which the file should be.
    ///   - domainMask: Domain constants specifying base locations to use when you search for significant directories.
    /// - Returns: An URL that points at the file with given file name. This method doesn't create the actual file.
    static func createFileUrl(fileName: String? = nil, contentType: UTType? = nil, directory: FileManager.SearchPathDirectory = .cachesDirectory, domainMask: FileManager.SearchPathDomainMask = .userDomainMask) -> URL?
    {
        if let directoryUrl = getDirectoryUrlIn(directory: directory, domainMask: domainMask)
        {
            var fileUrl: URL?
            
            if let fileName = fileName
            {
                fileUrl = directoryUrl.appendingPathComponent(fileName)
            }
            
            // Creating a file name when it's not provided.
            else
            {
                let fileName = s_FileNamePrefix + UUID().uuidString
                
                fileUrl = directoryUrl.appendingPathComponent(fileName)
            }
            
            // Appending the content type extension if provided.
            if let contentType = contentType
            {
                fileUrl = fileUrl!.appendingPathExtension(for: contentType)
            }
            
            return fileUrl
        }
        
        return nil
    }
    
    /// Creates a file with given file name, in directory. If the file name isn't provided, it will create a file name.
    /// - Parameters:
    ///   - fileName: The name of the file to be created.
    ///   - contentType: The content type of the file.
    ///   - data: The data that the file may contain when it's created.
    ///   - directory: The directory in which the file is located.
    ///   - domainMask: Domain constants specifying base locations to use when you search for significant directories.
    ///   - attributes: A dictionary containing the attributes to associate with the new file. You can use these attributes to set the owner and group numbers, file permissions, and modification date. For a list of keys, see FileAttributeKey. If you specify nil for attributes, the file is created with a set of default attributes.
    /// - Returns: An URL that points to the newly created file.
    static func createFile(fileName: String? = nil, contentType: UTType? = nil, data: Data? = nil, directory: FileManager.SearchPathDirectory = .cachesDirectory, domainMask: FileManager.SearchPathDomainMask = .userDomainMask, attributes: [FileAttributeKey : Any]? = nil) -> URL?
    {
        if let fileUrl = createFileUrl(fileName: fileName, contentType: contentType, directory: directory, domainMask: domainMask)
        {
            if !FileManager.default.fileExists(atPath: fileUrl.path)
            {
                if FileManager.default.createFile(atPath: fileUrl.path, contents: data, attributes: attributes)
                {
                    return fileUrl
                }
                
                s_Logger.error("Failed to create file with \(data ?? Data()).")
            }
            else
            {
                s_Logger.debug("File with name '\(fileName ?? "")' already exists.")
            }
        }
        
        return nil
    }
    
    /// Searches a file with given file name and location options.
    /// - Parameters:
    ///   - fileName: The name of the file to be searched.
    ///   - directory: The location of significant directories.
    ///   - domainMask: Domain constants specifying base locations to use when you search for significant directories.
    /// - Returns: If the file exists, will return an URL the points to that file.
    static func searchFile(fileName: String, directory: FileManager.SearchPathDirectory = .allLibrariesDirectory, domainMask: FileManager.SearchPathDomainMask = .allDomainsMask) -> URL?
    {
        if let directoryUrl = getDirectoryUrlIn(directory: directory, domainMask: domainMask)
        {
            let fileUrl = directoryUrl.appendingPathComponent(fileName)
            
            if FileManager.default.fileExists(atPath: fileUrl.path)
            {
                return fileUrl
            }
            else
            {
                s_Logger.debug("File with name '\(fileName)' doesn't exists.")
            }
        }
        
        return nil
    }
    
    /// Searches Cache directory for the file that was downloaded from the given external URL.
    /// - Parameter externalUrl: The external URL the file was downloaded from.
    /// - Returns: The URL to the file in Cache.
    ///
    /// The search is made with the file name composed from the file name prefix and the SHA1 hash of the external URL.
    ///
    static func searchCache(externalUrl: URL) -> URL?
    {
        var fileName: String?
        
        if let sha1HashString = externalUrl.absoluteString.sha1HashString
        {
            fileName = s_FileNamePrefix + sha1HashString
            
            return searchFile(fileName: fileName!, directory: .cachesDirectory, domainMask: .userDomainMask)
        }
        
        return nil
    }
    
    /// Copies a file from a given file URL to a new location with given options. If a new file name for the copy isn't provided, the copy will use the same file name as the original, if it doesn't already exists.
    /// - Parameters:
    ///   - fileUrl: The URL to the file to be copied.
    ///   - newFileName: A new given file name for the copy.
    ///   - contentType: The content type of the file copy.
    ///   - directory: The location of significant directories.
    ///   - domainMask: Domain constants specifying base locations to use when you search for significant directories.
    /// - Throws: If the copy fails, will throw an error.
    /// - Returns: The URL that points to the copy of the file.
    static func copyFile(fileUrl: URL, newFileName: String? = nil, contentType: UTType? = nil, directory: FileManager.SearchPathDirectory = .cachesDirectory, domainMask: FileManager.SearchPathDomainMask = .userDomainMask) -> URL?
    {
        var newFileUrl: URL?
        
        // The file to copy should exist first.
        if FileManager.default.fileExists(atPath: fileUrl.path)
        {
            if let newFileName = newFileName
            {
                if let fileUrl = createFileUrl(fileName: newFileName, contentType: contentType, directory: directory, domainMask: domainMask)
                {
                    newFileUrl = fileUrl
                }
                else
                {
                    let oldFileName = fileUrl.lastPathComponent
                    
                    if let fileUrl = createFileUrl(fileName: oldFileName, contentType: contentType, directory: directory, domainMask: domainMask)
                    {
                        newFileUrl = fileUrl
                    }
                }
            }
            
            // When a new file name isn't provided, the copy will also have the same file name as in the initial URL.
            else
            {
                let oldFileName = fileUrl.lastPathComponent
                
                if let fileUrl = createFileUrl(fileName: oldFileName, contentType: contentType, directory: directory, domainMask: domainMask)
                {
                    newFileUrl = fileUrl
                }
            }
            
            if let newFileUrl = newFileUrl, !FileManager.default.fileExists(atPath: newFileUrl.path)
            {
                do
                {
                    try FileManager.default.copyItem(at: fileUrl, to: newFileUrl)
                }
                catch
                {
                    s_Logger.error("File at '\(fileUrl.absoluteString)' copy failed with error: \(error.localizedDescription)")
                }
            }
            else
            {
                s_Logger.debug("File couldn't be copied because a file with the same name already exists at '\(newFileUrl?.absoluteString ?? "")'.")
            }
        }
        else
        {
            s_Logger.debug("File at '\(fileUrl.absoluteString)' cannot be copied because it doesn't exists.")
        }
        
        return newFileUrl
    }
    
    /// Moves a file from a given file URL to a new location with given options. If a new file name for the file at new location isn't provided, the new location file will use the same file name as the original, if it doesn't already exists.
    /// - Parameters:
    ///   - fileUrl: The URL to the file to be moved.
    ///   - newFileName: A new given file name for the moved file.
    ///   - contentType: The content type of the moved file.
    ///   - directory: The location of significant directories.
    ///   - domainMask: Domain constants specifying base locations to use when you search for significant directories.
    /// - Throws: If the move fails, will throw an error.
    /// - Returns: The URL that points to the file at the new location.
    static func moveFile(fileUrl: URL, newFileName: String? = nil, contentType: UTType? = nil, directory: FileManager.SearchPathDirectory = .cachesDirectory, domainMask: FileManager.SearchPathDomainMask = .userDomainMask) -> URL?
    {
        var newFileUrl: URL?
        
        if FileManager.default.fileExists(atPath: fileUrl.path)
        {
            if let newFileName = newFileName
            {
                if let fileUrl = createFileUrl(fileName: newFileName, contentType: contentType, directory: directory, domainMask: domainMask)
                {
                    newFileUrl = fileUrl
                }
                else
                {
                    let oldFileName = fileUrl.lastPathComponent
                    
                    if let fileUrl = createFileUrl(fileName: oldFileName, contentType: contentType, directory: directory, domainMask: domainMask)
                    {
                        newFileUrl = fileUrl
                    }
                }
            }
            
            // When a new file name isn't provided, the file to move will also have the same file name as in the initial URL.
            else
            {
                let oldFileName = fileUrl.lastPathComponent
                
                if let fileUrl = createFileUrl(fileName: oldFileName, contentType: contentType, directory: directory, domainMask: domainMask)
                {
                    newFileUrl = fileUrl
                }
            }
            
            if let newFileUrl = newFileUrl, !FileManager.default.fileExists(atPath: newFileUrl.path)
            {
                do
                {
                    try FileManager.default.moveItem(at: fileUrl, to: newFileUrl)
                }
                catch
                {
                    s_Logger.error("File at '\(fileUrl.absoluteString)' move failed with error: \(error.localizedDescription)")
                }
            }
            else
            {
                s_Logger.debug("File couldn't be moved because a file with the same name already exists at '\(newFileUrl?.absoluteString ?? "")'.")
            }
        }
        else
        {
            s_Logger.debug("File at '\(fileUrl.absoluteString)' cannot be moved because it doesn't exists.")
        }
        
        return newFileUrl
    }
    
    /// Moves or copies the file from given URL to Cache directory for an external URL. Searching a cached file for the same external URL will return it.
    /// - Parameters:
    ///   - fileUrl: The file URL that should be moved or copied in Cache directory.
    ///   - url: The external URL where the file was downloaded from.
    ///   - contentType: The content type of the file
    ///   - shouldMove: If true, will move the file from file URL, otherwise will copy it.
    /// - Throws: Throws error if the copy or move fails.
    /// - Returns: Returns the file URL of the cached file, from Cache directory.
    static func cacheFile(fileUrl: URL, externalUrl: URL, contentType: UTType? = nil, shouldMove: Bool = true) -> URL?
    {
        var cachedFileUrl: URL?
        
        if let sha1HashString = externalUrl.absoluteString.sha1HashString
        {
            let cachedFileName = s_FileNamePrefix + sha1HashString
            
            if shouldMove
            {
                // The file will from given file URL will be moved to the Cache directory.
                cachedFileUrl = moveFile(fileUrl: fileUrl, newFileName: cachedFileName, contentType: contentType, directory: .cachesDirectory, domainMask: .userDomainMask)
            }
            else
            {
                cachedFileUrl = copyFile(fileUrl: fileUrl, newFileName: cachedFileName, contentType: contentType, directory: .cachesDirectory, domainMask: .userDomainMask)
            }
        }
        
        return cachedFileUrl
    }
    
    /// Deletes a file at given URL, if exists and is deletable.
    /// - Parameter fileUrl: The URL of the file to be deleted.
    /// - Throws: Throws an error if the file couldn't be removed.
    static func deleteFile(fileUrl: URL)
    {
        if FileManager.default.fileExists(atPath: fileUrl.path) && FileManager.default.isDeletableFile(atPath: fileUrl.path)
        {
            do
            {
                try FileManager.default.removeItem(atPath: fileUrl.path)
            }
            catch
            {
                s_Logger.error("File at '\(fileUrl.absoluteString)' delete failed with error: \(error.localizedDescription)")
            }
        }
        else
        {
            s_Logger.debug("File at '\(fileUrl.absoluteString)' cannot be deleted because it doesn't exists or is not deletable.")
        }
    }
}

