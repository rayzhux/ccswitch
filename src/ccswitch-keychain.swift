// ccswitch-keychain — minimal Keychain get/set/delete via stdin.
// Token is passed via stdin (never argv) to avoid `ps` exposure.
// Build: swiftc -O ccswitch-keychain.swift -o ccswitch-keychain
import Foundation
import Security

func die(_ msg: String, _ code: Int32 = 1) -> Never {
  FileHandle.standardError.write((msg + "\n").data(using: .utf8)!)
  exit(code)
}

let args = CommandLine.arguments
guard args.count >= 4 else {
  die("usage: ccswitch-keychain {get|set|delete} <service> <account>")
}
let op = args[1], service = args[2], account = args[3]

let base: [String: Any] = [
  kSecClass as String: kSecClassGenericPassword,
  kSecAttrService as String: service,
  kSecAttrAccount as String: account,
]

switch op {
case "get":
  var q = base
  q[kSecReturnData as String] = true
  q[kSecMatchLimit as String] = kSecMatchLimitOne
  var out: CFTypeRef?
  let s = SecItemCopyMatching(q as CFDictionary, &out)
  guard s == errSecSuccess, let d = out as? Data,
        let str = String(data: d, encoding: .utf8) else {
    die("not found (status \(s))", 2)
  }
  FileHandle.standardOutput.write(str.data(using: .utf8)!)

case "set":
  let data = FileHandle.standardInput.readDataToEndOfFile()
  guard !data.isEmpty else { die("empty stdin") }
  SecItemDelete(base as CFDictionary)
  var add = base
  add[kSecValueData as String] = data
  let s = SecItemAdd(add as CFDictionary, nil)
  guard s == errSecSuccess else { die("set failed (status \(s))") }

case "delete":
  let s = SecItemDelete(base as CFDictionary)
  guard s == errSecSuccess || s == errSecItemNotFound else {
    die("delete failed (status \(s))")
  }

default:
  die("unknown op: \(op)")
}
