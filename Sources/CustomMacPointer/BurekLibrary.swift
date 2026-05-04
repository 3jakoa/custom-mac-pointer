import AppKit

enum BurekLibrary {
    static func loadBundledBureks() -> [CursorArtwork] {
        let directories = candidateDirectories()
        let supportedExtensions = Set(["png", "jpg", "jpeg", "heic", "tif", "tiff", "webp"])
        let fileManager = FileManager.default
        let metadata = loadMetadata(in: directories)

        let imageURLs = directories.flatMap { directory -> [URL] in
            guard let urls = try? fileManager.contentsOfDirectory(
                at: directory,
                includingPropertiesForKeys: [.isRegularFileKey],
                options: [.skipsHiddenFiles]
            ) else {
                return []
            }

            return urls.filter { url in
                supportedExtensions.contains(url.pathExtension.lowercased())
            }
        }

        return imageURLs
            .sorted { $0.lastPathComponent.localizedStandardCompare($1.lastPathComponent) == .orderedAscending }
            .compactMap { url in
                guard let image = NSImage(contentsOf: url), image.isValid, image.size.width > 0, image.size.height > 0 else {
                    return nil
                }

                let fileName = url.deletingPathExtension().lastPathComponent
                let displayName = metadata[url.lastPathComponent] ?? displayName(for: fileName)
                return CursorArtwork(name: displayName, image: image)
            }
    }

    private struct MetadataEntry: Decodable {
        let filename: String
        let name: String
        let source: String?
    }

    private static func loadMetadata(in directories: [URL]) -> [String: String] {
        let decoder = JSONDecoder()

        return directories.reduce(into: [:]) { namesByFilename, directory in
            let metadataURL = directory.appendingPathComponent("metadata.json")
            guard let data = try? Data(contentsOf: metadataURL),
                  let entries = try? decoder.decode([MetadataEntry].self, from: data) else {
                return
            }

            for entry in entries {
                namesByFilename[entry.filename] = entry.name
            }
        }
    }

    private static func displayName(for fileName: String) -> String {
        return fileName
            .replacingOccurrences(of: "-", with: " ")
            .replacingOccurrences(of: "_", with: " ")
            .capitalized
    }

    private static func candidateDirectories() -> [URL] {
        var directories: [URL] = []

        if let resourceURL = Bundle.main.resourceURL {
            directories.append(contentsOf: resourceDirectories(in: resourceURL))
        }

        if let executableDirectory = Bundle.main.executableURL?.deletingLastPathComponent() {
            let siblingResourceBundle = executableDirectory
                .appendingPathComponent("CustomMacPointer_CustomMacPointer.bundle", isDirectory: true)
            directories.append(contentsOf: resourceDirectories(in: siblingResourceBundle))
        }

        var seen = Set<URL>()
        return directories.filter { seen.insert($0).inserted }
    }

    private static func resourceDirectories(in resourceURL: URL) -> [URL] {
        let fileManager = FileManager.default
        let namedDirectories = ["Bureks", "Boreks"]
            .map { resourceURL.appendingPathComponent($0, isDirectory: true) }
            .filter { url in
                var isDirectory: ObjCBool = false
                return fileManager.fileExists(atPath: url.path, isDirectory: &isDirectory) && isDirectory.boolValue
            }

        return namedDirectories.isEmpty ? [resourceURL] : namedDirectories
    }
}
