//
//  Output.swift
//  AnyObservableObject
//
//  Created by marty-suzuki on 2022/04/03.
//  Copyright © 2022 marty-suzuki. All rights reserved.
//

import Combine

public protocol OutputType: ObservableObject {}

extension OutputType {
    public func toWrapper() -> OutputWrapper<Self> {
        OutputWrapper(self)
    }
}

@dynamicMemberLookup
public final class OutputWrapper<T: OutputType>: ObservableObject {
    
    public var objectWillChange: T.ObjectWillChangePublisher {
        object.objectWillChange
    }
    
    private let object: T
    
    public init(_ object: T) {
        self.object = object
    }
    
    public subscript<U>(dynamicMember keyPath: KeyPath<T, U>) -> U {
        object[keyPath: keyPath]
    }
    
    public subscript<U>(dynamicMember keyPath: KeyPath<T, PassthroughSubject<U, Never>>) -> AnyPublisher<U, Never> {
        object[keyPath: keyPath].eraseToAnyPublisher()
    }
}
