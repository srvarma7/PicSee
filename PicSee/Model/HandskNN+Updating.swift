//
//  HandskNN+Updating.swift
//  PicSee
//
//  Created by Sai Raghu Varma Kallepalli on 27/11/23.
//

import CoreML

extension HandskNN {
    /// Creates an update model from a given model URL and training data.
    ///
    /// - Parameters:
    ///     - url: The location of the model the Update Task will update.
    ///     - trainingData: The training data the Update Task uses to update the model.
    ///     - completionHandler: A closure the Update Task calls when it finishes updating the model.
    /// - Tag: CreateUpdateTask
    static func updateModel(at url: URL,
                            with trainingData: MLBatchProvider,
                            completionHandler: @escaping (MLUpdateContext) -> Void) {
        
        // Create an Update Task.
        guard let updateTask = try? MLUpdateTask(forModelAt: url,
                                                 trainingData: trainingData,
                                                 configuration: nil,
                                                 completionHandler: completionHandler)
        else {
            print("Could't create an MLUpdateTask.")
            return
        }
        
        updateTask.resume()
    }
}
