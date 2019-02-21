//
//  PDFViewController.swift
//  PDFKitDemo
//
//  Created by Sheshnath on 21/02/19.
//  Copyright © 2019 com.zensar. All rights reserved.
//

import UIKit
import AVFoundation
import MobileCoreServices
import PDFKit

class PDFViewController: UIViewController {
    @IBOutlet var nextButton:UIButton!
    @IBOutlet var previousButton:UIButton!
    @IBOutlet weak var pdfView: PDFView!
    @IBOutlet weak var pdfPreviewHeightConst: NSLayoutConstraint!
    
    @IBOutlet weak var btnPreview: UIButton!
    @IBOutlet weak var pdfThumbNailView: PDFThumbnailView!
    override func viewDidLoad() {
        super.viewDidLoad()
        nextButton.isHidden = true
        previousButton.isHidden = true
        btnPreview.isHidden = true
    }
    
    @IBAction func btnPreviewClick(_ sender: Any) {
        
        UIView.animate(withDuration: 1.0) {
            self.pdfPreviewHeightConst.constant = self.btnPreview.isSelected ? 0 : 80
        }
        
        self.btnPreview.isSelected = !self.btnPreview.isSelected
    }
    
    @IBAction func btnImport(_ sender: Any) {
        let documentPicker = UIDocumentPickerViewController(documentTypes: [kUTTypePDF as String], in: .import)
        documentPicker.delegate = self
        documentPicker.allowsMultipleSelection = true
        present(documentPicker, animated: true, completion: nil)
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
    
    @IBAction func btnNextTapped(_ sender: Any) {
        pdfView.goToNextPage(sender)
    }
    
    @IBAction func btnPreviousTapped(_ sender: Any) {
        pdfView.goToPreviousPage(sender)
    }
    
    @IBAction func swipeDetect(_ sender: UISwipeGestureRecognizer) {
        
        switch sender.direction {
        case .left:
            pdfView.goToNextPage(sender)
        case .right:
            pdfView.goToPreviousPage(sender)
        case .up:
            if(btnPreview.isSelected){
                btnPreviewClick(btnPreview)
            }
        case .down:
            if(!btnPreview.isSelected){
                btnPreviewClick(btnPreview)
            }
        default:
            return
        }
        
    }
   
}

extension PDFViewController: UIDocumentPickerDelegate {
    
    func documentPicker(_ controller: UIDocumentPickerViewController, didPickDocumentsAt urls: [URL]) {
        guard let selectedFileURL = urls.first else {
            return
        }
        /////////her to display PDF File
        
        pdfThumbNailView.pdfView = pdfView
        
        pdfView.displayMode = .singlePage
        // Fit content in PDFView.
        
        nextButton.isHidden = false
        previousButton.isHidden = false
        btnPreview.isHidden = false
        
        pdfView.autoScales = true
        pdfView.document = PDFDocument(url: selectedFileURL)
        
        
        let dir = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first!
        let sandboxFileURL = dir.appendingPathComponent(selectedFileURL.lastPathComponent)
        
        ///i need to ensure the file is saved
        if FileManager.default.fileExists(atPath: sandboxFileURL.path) {
            print("Already exists! Do nothing")
        }
        else {
            
            do {
                try FileManager.default.copyItem(at: selectedFileURL, to: sandboxFileURL)
                
                print("Copied file!")
            }
            catch {
                print("Error: \(error)")
            }
        }
    }
}
