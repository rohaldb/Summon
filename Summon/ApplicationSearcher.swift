import Cocoa

struct App {
  var appUrl: String
  var appIcon: NSImage?
  var modDate: Date
}

class ApplicationSearcher: NSObject {

    public func getAllApplications() -> [Application] {
        let fileManager = FileManager()
        
        guard let applicationsFolderUrl = try? FileManager.default.url(for: .applicationDirectory, in: .localDomainMask, appropriateFor: nil, create: false) else { return [] }
        
        let applicationUrls = try! fileManager.contentsOfDirectory(at: applicationsFolderUrl , includingPropertiesForKeys: [], options: [FileManager.DirectoryEnumerationOptions.skipsPackageDescendants, FileManager.DirectoryEnumerationOptions.skipsSubdirectoryDescendants])
        
        guard let systemApplicationsFolderUrl = try? FileManager.default.url(for: .applicationDirectory, in: .systemDomainMask, appropriateFor: nil, create: false) else { return [] }
        
        let utilitiesFolderUrl = NSURL.init(string: "\(systemApplicationsFolderUrl.path)/Utilities")! as URL
        
        guard let utilitiesUrls = try? fileManager.contentsOfDirectory(at: utilitiesFolderUrl, includingPropertiesForKeys: [], options: [FileManager.DirectoryEnumerationOptions.skipsPackageDescendants, FileManager.DirectoryEnumerationOptions.skipsSubdirectoryDescendants]) else { return [] }
    
        let urls = applicationUrls + utilitiesUrls
        
        var applications = [Application]()
    
        for url in urls {
            if fileManager.isExecutableFile(atPath: url.path) {
                let name = url.deletingPathExtension().lastPathComponent
                let icon = NSWorkspace.shared.icon(forFile: url.path)
                applications.append(Application(name: name, url: url, icon: icon))
            }
        }
        
        return applications
    }
    
}

struct Application {
    var name: String
    var url: URL
    var icon: NSImage
}
