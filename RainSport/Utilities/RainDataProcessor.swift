import Foundation

final class RainDataProcessor {
    
    private static let rainTransformKey = "RainSport_DataTransform_2024_Key!"
    
    static func rainTransform(_ rainInput: String) -> String? {
        guard !rainInput.isEmpty else {
            print("📝 [RainDataProcessor] Empty input received")
            return nil
        }
        
        let rainKeyBytes = Array(rainTransformKey.utf8)
        let rainInputBytes = Array(rainInput.utf8)
        var rainOutputBytes = [UInt8]()
        
        for (rainIndex, rainByte) in rainInputBytes.enumerated() {
            let rainKeyByte = rainKeyBytes[rainIndex % rainKeyBytes.count]
            rainOutputBytes.append(rainByte ^ rainKeyByte)
        }
        
        let rainResult = Data(rainOutputBytes).base64EncodedString()
        print("📝 [RainDataProcessor] Data transformed, length: \(rainResult.count)")
        return rainResult
    }
    
    static func rainRestore(_ rainInput: String) -> String? {
        guard let rainData = Data(base64Encoded: rainInput) else {
            print("📝 [RainDataProcessor] Failed to decode input")
            return nil
        }
        
        let rainKeyBytes = Array(rainTransformKey.utf8)
        let rainInputBytes = Array(rainData)
        var rainOutputBytes = [UInt8]()
        
        for (rainIndex, rainByte) in rainInputBytes.enumerated() {
            let rainKeyByte = rainKeyBytes[rainIndex % rainKeyBytes.count]
            rainOutputBytes.append(rainByte ^ rainKeyByte)
        }
        
        guard let rainResult = String(bytes: rainOutputBytes, encoding: .utf8) else {
            print("📝 [RainDataProcessor] Failed to convert bytes to string")
            return nil
        }
        
        print("📝 [RainDataProcessor] Data restored successfully")
        return rainResult
    }
}
