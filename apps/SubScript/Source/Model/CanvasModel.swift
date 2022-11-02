//
//  CanvasModel.swift
//  SubScript
//
//  Created by Colbyn Wadman on 10/31/22.
//

import Foundation

import struct CoreGraphics.CGPoint

extension SS1.CanvasModel {
    struct SamplePoint {
        var point: CGPoint
        var force: CGFloat? = nil
    }
}


extension SS1 {
    final class CanvasModel: ObservableObject, Codable, Identifiable {
        var id = UUID.init()
        @Published
        var height: CGFloat = 200
        @Published
        var visible: Bool = true
        var pointer: SSRootScenePointer = root_scene_new()
        
        enum CodingKeys: CodingKey {
            case id, height, visible, pointer
        }
        func encode(to encoder: Encoder) throws {
            var container = encoder.container(keyedBy: CodingKeys.self)
            try! container.encode(id, forKey: .id)
            try! container.encode(height, forKey: .height)
            try! container.encode(visible, forKey: .visible)
            try! container.encode(pointer, forKey: .pointer)
        }
        init() {}
        required init(from decoder: Decoder) throws {
            let container = try decoder.container(keyedBy: CodingKeys.self)
            id = try container.decode(UUID.self, forKey: .id)
            height = try container.decode(CGFloat.self, forKey: .height)
            visible = try container.decode(Bool.self, forKey: .visible)
            pointer = try container.decode(SSRootScenePointer.self, forKey: .pointer)
        }
    }
}
