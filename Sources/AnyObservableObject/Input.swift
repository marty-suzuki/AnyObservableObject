//
//  Input.swift
//  AnyObservableObject
//
//  Created by marty-suzuki on 2022/04/03.
//  Copyright © 2022 marty-suzuki. All rights reserved.
//

import Combine

public protocol InputType: AnyObject {}

extension InputType {
    public func toWrapper() -> InputWrapper<Self> {
        InputWrapper(self)
    }
}

@dynamicMemberLookup
public final class InputWrapper<T: InputType> {
    fileprivate let object: T
    
    public init(_ object: T) {
        self.object = object
    }
    
    public subscript<U>(dynamicMember keyPath: KeyPath<T, PassthroughSubject<U, Never>>) -> (U) -> Void {
        let subject = object[keyPath: keyPath]
        return { subject.send($0) }
    }
    
    public subscript(dynamicMember keyPath: KeyPath<T, PassthroughSubject<Void, Never>>) -> () -> Void {
        let subject = object[keyPath: keyPath]
        return { subject.send() }
    }
}
