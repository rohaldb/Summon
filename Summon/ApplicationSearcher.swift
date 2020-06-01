import Cocoa

struct App {
  var appUrl: String
  var appIcon: NSImage?
  var modDate: Date
}

class ApplicationSearcher: NSObject {

    public func getAllApplications() -> [Application] {

        let localApplicationUrls = getApplicationUrlsAt(directory: .applicationDirectory, domain: .localDomainMask)
        let systemApplicationsUrls = getApplicationUrlsAt(directory: .applicationDirectory, domain: .systemDomainMask)
        let systemUtilitiesUrls = getApplicationUrlsAt(directory: .applicationDirectory, domain: .systemDomainMask, subpath: "/Utilities")
        
        let allApplicationUrls = localApplicationUrls + systemApplicationsUrls + systemUtilitiesUrls
    
        var applications = [Application]()
        
        for url in allApplicationUrls {
            do {
                let resourceKeys : [URLResourceKey] = [.isExecutableKey, .isApplicationKey]
                let resourceValues = try url.resourceValues(forKeys: Set(resourceKeys))
                if resourceValues.isApplication! && resourceValues.isExecutable! {
                    let name = url.deletingPathExtension().lastPathComponent
                    let icon = NSWorkspace.shared.icon(forFile: url.path)
                    applications.append(Application(name: name, url: url, icon: icon))
                }
            } catch {}
        }
        
        return applications
    }
    
    private func getApplicationUrlsAt(directory: FileManager.SearchPathDirectory, domain: FileManager.SearchPathDomainMask, subpath: String = "") -> [URL] {
        let fileManager = FileManager()
        
        do {
            let folderUrl = try FileManager.default.url(for: directory, in: domain, appropriateFor: nil, create: false)
            let folderUrlWithSubpath = NSURL.init(string: folderUrl.path + subpath)! as URL
            
            let applicationUrls = try fileManager.contentsOfDirectory(at: folderUrlWithSubpath, includingPropertiesForKeys: [], options: [FileManager.DirectoryEnumerationOptions.skipsPackageDescendants, FileManager.DirectoryEnumerationOptions.skipsSubdirectoryDescendants])
            
            return applicationUrls
        } catch {
            return []
        }
    }
}


struct Application {
    var name: String
    var url: URL
    var icon: NSImage
}
