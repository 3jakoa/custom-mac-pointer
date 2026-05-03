import AppKit

enum BurekLibrary {
    static func loadBundledBureks() -> [CursorArtwork] {
        let directories = candidateDirectories()
        let supportedExtensions = Set(["png", "jpg", "jpeg", "heic", "tif", "tiff", "webp"])
        let fileManager = FileManager.default

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
                return CursorArtwork(name: displayName(for: fileName), image: image)
            }
    }

    private static func displayName(for fileName: String) -> String {
        let names = [
            "17458495290": "Zlati burek",
            "6_b1": "Klasični burek",
            "A92499-BUREK-MALI-MOTANI-S-MESOM": "Mali motani mesni",
            "AA71374D-250B-4B72-B3DB-ABCBAD234174_grande": "Hrustljavi zavitek",
            "burek-jabolcni": "Jabolčni burek",
            "burek-motani-s-mesom-250g": "Motani mesni",
            "burek-motani-sir-spinat-150g": "Sir in špinača",
            "burek-pecjak-jabolcni": "Pečjak jabolčni",
            "burek-with-pumpkin-filling-150-gr": "Bučni burek",
            "mesni": "Mesni burek",
            "mesni-1": "Mesni klasik",
            "pizza-burek": "Pizza burek",
            "pngtree-burek-meat-closeup-fat-png-image_14672347": "Mesni close-up",
            "puno-mesnoga": "Puno mesnoga",
            "sirni": "Sirni burek",
            "sirni-1": "Sirni klasik"
        ]

        if let displayName = names[fileName] {
            return displayName
        }

        return fileName
            .replacingOccurrences(of: "-", with: " ")
            .replacingOccurrences(of: "_", with: " ")
            .capitalized
    }

    private static func candidateDirectories() -> [URL] {
        var directories: [URL] = []

        if let url = Bundle.module.url(forResource: "Bureks", withExtension: nil) {
            directories.append(url)
        }

        if let resourceURL = Bundle.module.resourceURL {
            directories.append(contentsOf: resourceDirectories(in: resourceURL))
        }

        if let resourceURL = Bundle.main.resourceURL {
            directories.append(contentsOf: resourceDirectories(in: resourceURL))
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
