//
//  PhotoDetailViewController.swift
//  iOS Test
//
//  Created by MacPro on 16/04/20.
//  Copyright © 2020 Ian Castillo. All rights reserved.
//

import UIKit

class VillainDetailViewController: UIViewController {
    
    var photoObject: Photos?
    // MARK: Outlets
    
    @IBOutlet weak var imageView: UIImageView!
    @IBOutlet weak var label: UILabel!
    
    // MARK: Life Cycle
    

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        self.label.text = self.photoObject?.title
        guard let completeLink = photoObject?.thumbnailUrl else { return }
        self.imageView!.downloaded(from: completeLink)
    }
}
