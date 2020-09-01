import Foundation

print("Hello, world!")


let url = URL(fileURLWithPath: "./cache", isDirectory: true)
do {
    try FileManager().createDirectory(at: url, withIntermediateDirectories: true)
} catch {
    print(error.localizedDescription)
    exit(0)
}


let filePath = url.appendingPathComponent("sample.txt", isDirectory: false)

print("🍎 \(filePath.absoluteString)")

let s = "hello"
do {
    try s.write(to: filePath, atomically: true, encoding: .utf8)
} catch {
    print(error.localizedDescription)
}
