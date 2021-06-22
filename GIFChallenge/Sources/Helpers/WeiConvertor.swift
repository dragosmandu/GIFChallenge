import Foundation

class WeiConvertor
{
    private static let skMaxZeroDecimalCounter: Int = 18
    
    static func toWeiWith(egld: String) -> String
    {
        var intVal: String = "" // Integer
        var decVal: String = "" // Decimals
        var wei: String = ""
        
        if egld.contains(".")
        {
            let split = egld.split(separator: ".")
            
            if let first = split.first, first != "0"
            {
                intVal = String(first)
            }
            
            if let last = split.last
            {
                decVal = String(last)
            }
        }
        else
        {
            intVal = egld
        }
        
        wei = intVal
        
        // Adding all decimals if needed.
        while(decVal.count < skMaxZeroDecimalCounter)
        {
            decVal.append("0")
        }
        
        // If there's no integer value, first 0's occurrences should be stripped.
        if wei == ""
        {
            var removedCounter: Int = 0 // Number of 0's removed.
            
            for (i, char) in decVal.enumerated()
            {
                if char != "0" { break }
                
                if let index = decVal.index(decVal.startIndex, offsetBy: i - removedCounter, limitedBy: decVal.endIndex)
                {
                    decVal.remove(at: index)
                    removedCounter += 1
                }
            }
        }
        
        wei += decVal
        
        return wei
    }
    
    static func toEgldWith(wei: String) -> String
    {
        var intVal: String = "" // Integer
        var decVal: String = "." // Decimals
        var wei = wei
        
        if wei.count > skMaxZeroDecimalCounter
        {
            // Getting all the integer values.
            while(wei.count > skMaxZeroDecimalCounter)
            {
                intVal.append(wei.removeFirst())
            }
        }
        else
        {
            while(wei.count < skMaxZeroDecimalCounter)
            {
                wei = "0" + wei
            }
        }
        
        decVal.append(wei)
        
        if intVal == ""
        {
            intVal.append("0")
        }
        
        var egld = intVal + decVal
        
        while(["0", "."].contains(egld.last))
        {
            egld.removeLast()
        }
        
        if egld == "" { egld = "0" }
        
        return egld
    }
}
