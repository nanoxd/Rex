//
//  PropertyTests.swift
//  Rex
//
//  Created by Neil Pankey on 5/29/15.
//  Copyright (c) 2015 Neil Pankey. All rights reserved.
//

import Rex
import ReactiveCocoa
import XCTest

final class PropertyTests: XCTestCase {

    func testSignalPropertyValues() {
        let (signal, sink) = Signal<Int, NoError>.pipe()
        var property = SignalProperty(0, signal)

        var latest = -1
        property.producer.start(next: {
            latest = $0
        })

        XCTAssert(latest == 0)

        sendNext(sink, 1)
        XCTAssert(latest == 1)
    }

    func testSignalPropertyLifetime() {
        let (signal, sink) = Signal<Int, NoError>.pipe()
        var property: SignalProperty? = SignalProperty(0, signal)

        var completed = false
        property?.producer.start(completed: {
            completed = true
        })

        property = nil
        XCTAssert(completed)
    }

    func testSignalPropertySink() {
        let (signal, sink) = Signal<Int, NoError>.pipe()

        let property = signal |> propertySink(Collector())
        XCTAssert(property.value.values == [])

        sendNext(sink, 1)
        XCTAssert(property.value.values == [1])

        sendNext(sink, 2)
        sendNext(sink, 3)
        XCTAssert(property.value.values == [1, 2, 3])
    }

    func testProducerPropertySink() {
        let (producer, sink) = SignalProducer<Int, NoError>.buffer()

        let property = producer |> propertySink(Collector<Int>(values: []))
        XCTAssert(property.value.values == [])

        sendNext(sink, 1)
        XCTAssert(property.value.values == [1])

        sendNext(sink, 2)
        sendNext(sink, 3)
        XCTAssert(property.value.values == [1, 2, 3])
    }
}

struct Collector<T>: SinkType {
    typealias Element = T
    var values: [T] = []

    mutating func put(value: T) {
        values.append(value)
    }
}
