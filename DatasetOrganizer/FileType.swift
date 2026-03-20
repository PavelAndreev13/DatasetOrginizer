import Foundation

enum FileType: String, CaseIterable, Identifiable {

    // MARK: - Audio
    case wav
    case mp3
    case aac
    case flac
    case ogg
    case m4a
    case aiff
    case opus
    case wma
    case amr

    // MARK: - Video
    case mov
    case mp4
    case avi
    case mkv
    case wmv
    case flv
    case webm
    case m4v
    case mpeg
    case ts

    // MARK: - Image
    case jpeg
    case jpg
    case png
    case gif
    case bmp
    case tiff
    case tif
    case webp
    case heic
    case heif
    case svg
    case ico
    case raw

    // MARK: - Text & Data
    case txt
    case json

    var id: Self { self }
}
