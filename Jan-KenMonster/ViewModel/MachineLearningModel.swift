//
//  MachineLearningModel.swift
//  Jan-KenMonster
//
//  Created by tandyys on 23/05/24.
//

import Foundation
import CoreML

var mlModel = try! best(configuration: .init()).model
let model = try! best(configuration: MLModelConfiguration())

//var detector = try! VNCoreMLModel(for: mlModel)

//class yoloModel: MLModel {
//    var model: MLModel
//    init(configuration: MLModelConfiguration = MLModelConfiguration()) throws {
//            let bundle = Bundle(for: best.self)
//            self.model = try MLModel(contentsOf: bundle.url(forResource: "best", withExtension: "mlpackage")!, configuration: configuration)
//        }
//
//}
