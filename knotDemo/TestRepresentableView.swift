//
//  TestRepresentableView.swift
//  knotDemo
//
//  Created by P on 2022/5/17.
//

import UIKit
import SwiftUI

struct TestRepresentableView : UIViewControllerRepresentable {
    func updateUIViewController(_ uiViewController: UIViewControllerType, context: Context) {
        
    }
    func makeUIViewController(context: Context) -> some UIViewController {
        let testVC = bad_vc()
        
        return testVC
    }
}
