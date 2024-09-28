//
//  PdfProgressEnum.swift
//  LawAsisstant
//
//  Created by Outcast Traveler on 2024/09/14.
//

import Foundation

enum PdfProgressEnum: String {
    case started = "STARTED"
    case completed = "COMPLETED"
    case pdfProcessed = "PDF_PROCESSED"
    case qaGenerated = "QA_GENERATED"
    case adapterTraining = "ADAPTER_TRAINING"
    case failed = "FAILED"
    
}
