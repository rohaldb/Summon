import Cocoa

struct App {
  var appUrl: String
  var appIcon: NSImage?
  var modDate: Date
}

class ApplicationSearcher: NSObject {

    public func getAllApplications() -> [Application] {
        let fileManager = FileManager()
        let urls: [URL]
        
        do {
            //Get contents of /Applications
            let applicationsFolderUrl = try FileManager.default.url(for: .applicationDirectory, in: .localDomainMask, appropriateFor: nil, create: false)
            let applicationUrls = try fileManager.contentsOfDirectory(at: applicationsFolderUrl , includingPropertiesForKeys: [], options: [FileManager.DirectoryEnumerationOptions.skipsPackageDescendants, FileManager.DirectoryEnumerationOptions.skipsSubdirectoryDescendants])
            
            //Get contents of /Applications/Utilities
            let systemApplicationsFolderUrl = try FileManager.default.url(for: .applicationDirectory, in: .systemDomainMask, appropriateFor: nil, create: false)
            let utilitiesFolderUrl = NSURL.init(string: "\(systemApplicationsFolderUrl.path)/Utilities")! as URL
            let utilitiesUrls = try fileManager.contentsOfDirectory(at: utilitiesFolderUrl, includingPropertiesForKeys: [], options: [FileManager.DirectoryEnumerationOptions.skipsPackageDescendants, FileManager.DirectoryEnumerationOptions.skipsSubdirectoryDescendants])
            
            urls = applicationUrls + utilitiesUrls
        } catch {
            urls = []
        }
    
        var applications = [Application]()
        
        for url in urls {
            if shouldIncludeApplication(url: url) {
                let name = url.deletingPathExtension().lastPathComponent
                let icon = NSWorkspace.shared.icon(forFile: url.path)
                applications.append(Application(name: name, url: url, icon: icon))
            }
        }
        
        return applications
    }
    
    private func shouldIncludeApplication(url: URL) -> Bool {
        let isExecutable = FileManager.default.isExecutableFile(atPath: url.path)
        let isApp = url.lastPathComponent.hasSuffix(".app")
        if (isExecutable && isApp) {
            return true
        }
        return false
    }
    
}

struct Application {
    var name: String
    var url: URL
    var icon: NSImage
}
