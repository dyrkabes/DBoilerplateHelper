//
//  ParserCleanParameters.swift
//  BoilerplateHelper
//
//  Created by Stepanov Pavel on 14/02/2018.
//  Copyright © 2018 Stepanov Pavel. All rights reserved.
//

import Foundation

struct ParserCleanParameters {
    let shouldRemoveCases: Bool
    let shouldCleanCaseValues: Bool
    let shouldCleanComments: Bool
    
    static let initial = ParserCleanParameters(shouldRemoveCases: true, shouldCleanCaseValues: true, shouldCleanComments: true)
}
