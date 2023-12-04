//
//  HandskNN+ImageConstraint.swift
//  PicSee
//
//  Created by Sai Raghu Varma Kallepalli on 27/11/23.
//

import CoreML

/// - Tag: ImageConstraintProperty
extension HandskNN {
    /// Returns the image constraint for the model's "drawing" input feature.
    var imageConstraint: MLImageConstraint {
        let description = model.modelDescription
        
        let inputName = "image"
        let imageInputDescription = description.inputDescriptionsByName[inputName]!
        
        return imageInputDescription.imageConstraint!
    }
}
