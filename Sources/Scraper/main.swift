import Foundation

let semaphore = DispatchSemaphore(value: 0)

let downloader = CachedHTTPTextDownloader(cacheDirectory: URL(fileURLWithPath: "./cache", isDirectory: true))
downloader.download(url: URL(string: "https://www.conwaylife.com/wiki/$rats")!) {
    if let content = $0 {
        print("🍎 Success!!")
    } else {
        print("🍏 Failed...")
    }
    semaphore.signal()
}

print("⏰ Wait...")
semaphore.wait()
print("⭐ Finsh!")

/*
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
*/
