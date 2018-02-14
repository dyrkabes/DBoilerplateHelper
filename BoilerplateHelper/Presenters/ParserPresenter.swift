//
//  ParserPresenter.swift
//  BoilerplateHelper
//
//  Created by Stepanov Pavel on 14/02/2018.
//  Copyright © 2018 Stepanov Pavel. All rights reserved.
//

import Foundation

// TODO: for swifty json

struct ParserPresenter {
//    fileprivate
    var mode: OutputFormat = .keys
    fileprivate var cleanParameters = ParserCleanParameters.initial
    fileprivate var jsonRepetitionCount = 5
    
    let stringHelper = StringHelper()
    
    mutating func attemptToChangeMode(withId id: Int) throws {
        guard let buttonOutputFormat = OutputFormat(rawValue: id) else {
            throw ParserError.unknownMode
        }
        mode = buttonOutputFormat
    }
    
    mutating func changeParserCleanParameters(shouldRemoveCases: Bool, shouldCleanCaseValues: Bool, shouldCleanComments: Bool) {
        self.cleanParameters = ParserCleanParameters(shouldRemoveCases: shouldRemoveCases,
                                                     shouldCleanCaseValues: shouldCleanCaseValues,
                                                     shouldCleanComments: shouldCleanComments)
    }
    
    mutating func changeJSONRepetitionCount(_ newCount: Int) {
        jsonRepetitionCount = newCount
    }
    
    func getOutputString(_ input: String) -> String {
        let lines: [String] = stringHelper.parseInputString(input, withMode: mode, cleanParameters: cleanParameters)
        var output: String = ""
        
        switch mode {
        case .keys:
            output = "private enum Keys {\n"
                + lines
                    .map { "    static let \($0) = \"\($0)\"" }
                    .joined(separator: "\n")
                + "\n}\n"
            
        case .vars:
            output = "<#class#> <#classname#>: <#Type#> {\n"
                + lines.map { "    var " + $0 + ": <#type#> = <#value#>" }.joined(separator: "\n")
                + "\n}\n"
        case .realmVars:
            output = "<#class#> <#classname#>: Object {\n"
                + lines.map { "    @objc dynamic var " + $0 + ": <#type#> = <#value#>" }.joined(separator: "\n")
                + "\n}\n"
            
        case .initVars:
            // init
            output = "init(<#properties#>) {\n"
                + lines.map { "    self.\($0) = <#value#>" }.joined(separator: "\n")
                + "\n}\n"
            
        case .initJSON:
            // init from json using SwiftyJson
            output = "init(json: JSON) {\n"
                + lines.map { "    self.\($0) = json[Keys.\($0)] ?? <#defaultValue#>" }.joined(separator: "\n")
                + "\n}\n"
            
        case .stubJSONData:
            var resultString = ""
            resultString += "[\n"

            for i in 0..<jsonRepetitionCount {
                resultString += "{\n"

                resultString += lines.map { "    \"\($0)\": <#value#>"}.joined(separator: ",\n")


                if i < jsonRepetitionCount - 1 {
                    resultString += "\n},\n"
                } else {
                    resultString += "\n}\n"
                }
            }

            resultString += "]"

            output = resultString
            
        case .cases:
            output = "switch <#variable#> {\n"
                + lines.map { "    case .\($0):\n<#\($0) code#>" }.joined(separator: "\n")
                + "\n}\n"
            
        }
        
        return output
    }
}


struct StringHelper {
    func parseInputString(_ input: String, withMode mode: OutputFormat, cleanParameters: ParserCleanParameters) -> [String] {
        var output = input
            .components(separatedBy: CharacterSet.controlCharacters)
        
        if cleanParameters.shouldCleanComments {
            output = output.flatMap {
                // regular expression!
                
                if $0.replacingOccurrences(of: "    ", with: "").prefix(2) == "//" {
                    return nil
                }
                return $0
            }
        }
        
        if mode == .cases{
            if cleanParameters.shouldRemoveCases {
                output = output.map { $0.replacingOccurrences(of: "case ", with: "")}
            }
            
            if cleanParameters.shouldCleanCaseValues {
                output = output.map {
                    guard let index = $0.index(of: "=") else { return $0 }
                    return String($0.prefix(upTo: index))
                }
            }
        }
        
        
        //        if shouldCamelCaseButton.state == .on {
        //            output = output.map {
        ////                $0.replacingOccurrences(of: "_", with: " ").capitalized
        //
        ////                var indices = $0.map { $ }
        //            }
        //        }
        
        return output.map { $0.replacingOccurrences(of: " ", with: "") }.filter { $0 != "" }
    }
}

enum ParserError: Error {
    case unknownMode
}

// MARK: - LocalizedError
extension ParserError: LocalizedError {
    public var errorDescription: String? {
        switch self {
        case .unknownMode:
            return "Unknown mode button tapped"
        }
    }
}
