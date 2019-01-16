//
//  SyncManager.swift
//  OpenBible
//
//  Created by Denis Dobanda on 15.01.19.
//  Copyright © 2019 Denis Dobanda. All rights reserved.
//

import Foundation

enum BonjourServerState {
    case greeting
    case teaching
    case waiting
}

enum BonjourClientGreetingOption: String {
    case firstMeet = "hi, ready to get to know me?"
    case confirm = "yes"
    case ready = "ready to receive"
    case bye = "bye"
    //    case
}

class SyncManager: NSObject {
    
    var service: NetService?
    var delegate: SyncManagerDelegate?
    
    var sharedObjects: [String:String]?
    var selectedObjects: [Bool]?
    
    private var input: InputStream?
    private var output: OutputStream?
    private var state: BonjourServerState?
    
    private var occupiedRunLoop: RunLoop?
    
    func initialize() {
        service!.getInputStream(&input, outputStream: &output)
        input?.delegate = self
        output?.delegate = self
        occupiedRunLoop = RunLoop.current
        input?.schedule(in: RunLoop.current, forMode: .default)
        output?.schedule(in: RunLoop.current, forMode: .default)
        state = .greeting
        input?.open()
        output?.open()
    }

    func closeNetworkCommunication() {
        print("closing")
        send(greeting: .bye)
        input?.close()
        output?.close()
        if let loop = occupiedRunLoop {
            input?.remove(from: loop, forMode: .default)
            output?.remove(from: loop, forMode: .default)
            input = nil
            output = nil
            occupiedRunLoop = nil
        }
    }

    private func parse(data: Data) {
        guard var state = state else {return}
        if let message = String(data: data, encoding: .utf8),
            message == BonjourClientGreetingOption.firstMeet.rawValue {
            self.state = .greeting
            state = .greeting
        }
        switch state {
        case .greeting:
            print("greeted")
            if let string = String(data: data, encoding: .utf8),
                string == BonjourClientGreetingOption.firstMeet.rawValue {
                send(greeting: .confirm)
                self.state = .teaching
            } else {
                print("cannot interptret")
                send(greeting: .bye)
            }
        case .teaching:
            print("teaching")
            // remake
            if let dict = try? NSKeyedUnarchiver.unarchiveTopLevelObjectWithData(data) as? [String:String] {
                sharedObjects = dict
                delegate?.syncManagerDidGetUpdate()
                send(greeting: .confirm)
                self.state = .waiting
            } else {
                print("cannot interptret")
                send(greeting: .bye)
            }
        default: break
        }
    }
    
    private func send(message: String) {
        let p = ([UInt8])(message.utf8)
        output?.write(p, maxLength: p.count)
    }
    
    private func send(greeting: BonjourClientGreetingOption) {
        send(message: greeting.rawValue)
    }
}

extension SyncManager: StreamDelegate {
    func stream(_ aStream: Stream, handle eventCode: Stream.Event) {
//        print("EventCode = \(eventCode)")
        switch (eventCode) {
        case Stream.Event.openCompleted:
            if(aStream == output) {
                print("output:OutPutStream opened")
            } else {
                print("Input = openCompleted")
            }
        case Stream.Event.errorOccurred:
            if(aStream === output) {
                print("output:Error Occurred\n")
            } else {
                print("Input : Error Occurred\n")
            }
        case Stream.Event.endEncountered:
            if(aStream === output) {
                print("output:endEncountered\n")
            } else {
                print("Input = endEncountered\n")
            }
        case Stream.Event.hasSpaceAvailable:
            if(aStream === output) {
//                print("output:hasSpaceAvailable\n")
            } else {
//                print("Input = hasSpaceAvailable\n")
            }
        case Stream.Event.hasBytesAvailable:
            if(aStream === output) {
                print("output:hasBytesAvailable\n")
            } else if aStream === input {
                print("Input:hasBytesAvailable\n")
                var buffer = [UInt8](repeating: 0, count: 4096)
                
                while (self.input!.hasBytesAvailable) {
                    let len = input!.read(&buffer, maxLength: buffer.count)
                    // If read bytes are less than 0 -> error
                    if len < 0 {
                        let error = self.input!.streamError
                        print("Input stream has less than 0 bytes\(error!)")
                        //closeNetworkCommunication()
                    }
                        // If read bytes equal 0 -> close connection
                    else if len == 0 {
                        print("Input stream has 0 bytes")
                        // closeNetworkCommunication()
                    }
                    if(len > 0) {
                        parse(data: Data(bytes: buffer[0..<len]))
                        //here it will check it out for the data sending from the server if it is greater than 0 means if there is a data means it will write
//                        let messageFromServer = NSString(bytes: &buffer, length: buffer.count, encoding: String.Encoding.utf8.rawValue)
//                        if messageFromServer == nil {
//                            print("Network has been closed")
//                            // v1.closeNetworkCommunication()
//                        } else {
//                            print("MessageFromServer = \(messageFromServer!)")
//                        }
                    }
                }
            }
            
        default:
            print("default block")
        }
    }
}
