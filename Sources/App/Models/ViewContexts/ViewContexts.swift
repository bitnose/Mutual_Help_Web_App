//
//  ViewContexts.swift
//  App
//
//  Created by Sötnos on 06/07/2019.
//

import Foundation
import Vapor

// This file contains context data to the views.

/// MARK: - Declaration of the New Data Types

/*
 View context for the "landing.leaf"
 - countries : Array of all future countries
 */

struct CountryContext : Encodable {
    let countries : Future<[Country]>
}

