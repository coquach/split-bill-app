//
//  Mappable.swift
//  
//
//  Created by Dinh Long on 25/9/26.
//

// A type that knows how to turn one raw wire DTO into one clean domain model.
public protocol Mappable {
    associatedtype Input: Decodable
    associatedtype Output

    func map(_ input: Input) throws -> Output
}
