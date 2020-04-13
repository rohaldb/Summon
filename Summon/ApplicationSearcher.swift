import Cocoa

struct App {
  var appUrl: String
  var appIcon: NSImage?
  var modDate: Date
}

class ApplicationSearcher: NSObject {

    public func getAllApplications() -> [NSMetadataItem] {
        let fileManager = FileManager()
        
        guard let applicationsFolderUrl = try? FileManager.default.url(for: .applicationDirectory, in: .localDomainMask, appropriateFor: nil, create: false) else { return [] }
        
        let applicationUrls = try! fileManager.contentsOfDirectory(at: applicationsFolderUrl , includingPropertiesForKeys: [], options: [FileManager.DirectoryEnumerationOptions.skipsPackageDescendants, FileManager.DirectoryEnumerationOptions.skipsSubdirectoryDescendants])
        
        guard let systemApplicationsFolderUrl = try? FileManager.default.url(for: .applicationDirectory, in: .systemDomainMask, appropriateFor: nil, create: false) else { return [] }
        
        let utilitiesFolderUrl = NSURL.init(string: "\(systemApplicationsFolderUrl.path)/Utilities") as! URL
        
        guard let utilitiesUrls = try? fileManager.contentsOfDirectory(at: utilitiesFolderUrl, includingPropertiesForKeys: [], options: [FileManager.DirectoryEnumerationOptions.skipsPackageDescendants, FileManager.DirectoryEnumerationOptions.skipsSubdirectoryDescendants]) else { return [] }
    
        let urls = applicationUrls + utilitiesUrls
        
        var applications = [NSMetadataItem]()
    
        for url in urls {
            print(url.path, fileManager.isExecutableFile(atPath: url.path))
            if fileManager.isExecutableFile(atPath: url.path) {
                guard let mdi = NSMetadataItem(url: url) else { continue }
                applications.append(mdi)
            }
        }
        
        for app in applications {
            print(app.value(forAttribute: kMDItemDisplayName as String))
        }
        return applications
    }
    
}
