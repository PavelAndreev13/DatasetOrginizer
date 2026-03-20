import SwiftUI
import UniformTypeIdentifiers
import AppKit

@MainActor
@Observable
class OrganizerViewModel {
    var statusMessage = "Ready to work. Select folders."
    var sourceURL: URL?
    var destURL: URL?
    var targetExtension: FileType = .wav
    
    var isProcessing = false
    var progress: Double = 0.0
    var totalFiles: Double = 0.0
    var copyMode: Bool = false
    
    func selectSourceFolder() {
        if let url = selectFolder() {
            sourceURL = url
        }
    }
    
    func selectDestinationFolder() {
        if let url = selectFolder() {
            destURL = url
        }
    }
    
    private func selectFolder() -> URL? {
        let panel = NSOpenPanel()
        panel.canChooseFiles = false
        panel.canChooseDirectories = true
        panel.allowsMultipleSelection = false
        if panel.runModal() == .OK {
            return panel.url
        }
        return nil
    }
    
    func organizeDataset() {
        guard let source = sourceURL, let destination = destURL else {
            statusMessage = "Select both folders first!"
            return
        }

        isProcessing = true
        statusMessage = "Analyzing files..."
        progress = 0.0

        let cleanExtension = targetExtension.rawValue
        let isCopy = copyMode

        let startTime = Date()
        let minimumDuration: TimeInterval = 1.5

        Task.detached(priority: .userInitiated) {
            let fileManager = FileManager.default

            // Step 1: Analyze files
            guard let enumerator = fileManager.enumerator(at: source, includingPropertiesForKeys: [.isRegularFileKey]) else {
                await MainActor.run {
                    self.statusMessage = "Folder read error"
                    self.isProcessing = false
                }
                return
            }

            var matchingURLs: [URL] = []
            for case let fileURL as URL in enumerator {
                if fileURL.pathExtension.lowercased() == cleanExtension {
                    matchingURLs.append(fileURL)
                }
            }

            let total = Double(matchingURLs.count)
            await MainActor.run { self.totalFiles = total }

            if total == 0 {
                let elapsed = Date().timeIntervalSince(startTime)
                let remaining = minimumDuration - elapsed
                if remaining > 0 {
                    try? await Task.sleep(nanoseconds: UInt64(remaining * 1_000_000_000))
                }
                await MainActor.run {
                    self.statusMessage = "No .\(cleanExtension) files found."
                    self.isProcessing = false
                }
                return
            }

            // Step 2: Copy or Move files
            var processedCount = 0

            for fileURL in matchingURLs {
                let nameWithoutExt = fileURL.deletingPathExtension().lastPathComponent
                let parts = nameWithoutExt.split(separator: "_")
                guard let lastPart = parts.last else { continue }

                let className = String(lastPart).lowercased()
                let classFolder = destination.appendingPathComponent(className)

                try? fileManager.createDirectory(at: classFolder, withIntermediateDirectories: true)

                let uniqueId = String(UUID().uuidString.prefix(6)).lowercased()
                let newFileName: String

                if let dashIndex = nameWithoutExt.firstIndex(of: "-") {
                    let suffix = nameWithoutExt[nameWithoutExt.index(after: dashIndex)...]
                    newFileName = "\(uniqueId)-\(suffix).\(cleanExtension)"
                } else {
                    newFileName = "\(uniqueId)_\(nameWithoutExt).\(cleanExtension)"
                }

                let targetURL = classFolder.appendingPathComponent(newFileName)

                do {
                    if isCopy {
                        try fileManager.copyItem(at: fileURL, to: targetURL)
                    } else {
                        try fileManager.moveItem(at: fileURL, to: targetURL)
                    }
                    processedCount += 1
                } catch {
                    print("File operation error: \(error)")
                }

                let count = processedCount
                await MainActor.run {
                    self.progress = Double(count)
                    self.statusMessage = "Processed: \(count) of \(Int(total))"
                }
            }

            // Ensure progress bar is visible for at least 1.5 seconds
            let elapsed = Date().timeIntervalSince(startTime)
            let remaining = minimumDuration - elapsed
            if remaining > 0 {
                try? await Task.sleep(nanoseconds: UInt64(remaining * 1_000_000_000))
            }

            let action = isCopy ? "Copied" : "Moved"
            await MainActor.run {
                self.statusMessage = "Success! \(action) (.\(cleanExtension)): \(processedCount) files"
                self.isProcessing = false
            }
        }
    }
}
