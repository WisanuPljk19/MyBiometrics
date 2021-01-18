//
//  ViewController.swift
//  MyBiometrics
//
//  Created by Wisanu Paunglumjeak on 12/1/2564 BE.
//

import UIKit
import LocalAuthentication

class ViewController: UIViewController {
    
    
    
    lazy var laContext: LAContext  = {
        let context = LAContext()
        context.localizedFallbackTitle = "กลับไปใส่ PIN ดีกว่า"
        context.localizedCancelTitle = "ไม่ชงไม่ใช้มันแล้ว!!"
        return context
    }()

    @IBOutlet var btnVerify: UIButton!
    @IBOutlet var lbResult: UILabel!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupView()
    }
    
    private func setupView(){
        let (hasSupport, message) = hasSupportBiometrics()
        btnVerify.isEnabled = hasSupport
        guard hasSupport else {
            lbResult.text = message
            return
        }
        
        lbResult.text = getDescription(laContext.biometryType)

    }
    
    func getDescription(_ type: LABiometryType) -> String{
        switch type {
        case .faceID:
            return "เตรียมยื่นหน้าเข้ามาใกล้ ๆ"
        case .touchID:
            return "เตรียมเอานิ้วมาแตะเบา ๆ"
        default:
            return "ไม่รองรับอะไรซักอย่าง"
        }
    }

    func hasSupportBiometrics() -> (Bool, String?) {
        var error: NSError?
        if laContext.canEvaluatePolicy(.deviceOwnerAuthenticationWithBiometrics, error: &error) {
            return (true, nil)
        }else{
            guard let error = error else {
                return (false, nil)
            }
            return (false, error.localizedDescription)
        }
    }
    
    @IBAction func callLocalAuthen(_ sender: UIButton){
        
        let reason = "อยากจะรู้จริง ๆ ว่าใช้เจ้าของเครื่องนี้มั้ย ?"
        
        laContext.evaluatePolicy(.deviceOwnerAuthenticationWithBiometrics,
                                 localizedReason: reason) { (success, evaluateError) in
            if success {
                
            }
            
            guard success else{
                self.localAuthenFailure(evaluateError)
                return
            }
            
            self.localAuthenSuccess()
        }
    }
    
    private func localAuthenSuccess(){
        DispatchQueue.main.async() {
            self.lbResult.text = "ผ่านนนน!!!!"
        }
    }
    
    private func localAuthenFailure(_ error: Error?){
        DispatchQueue.main.async() {
            guard let error = error as? LAError else {
                self.lbResult.text = "ไม่ผ่านนนน!!!!"
                return
            }
            switch error {
            case LAError.authenticationFailed:
                self.lbResult.text = "ไม่ผ่านนนน!! ลองใหม่"
            case LAError.userFallback:
                self.lbResult.text = "อยากใช้ PIN หรอ?"
            case LAError.userCancel:
                self.lbResult.text = "ไม่อยากใช้หรอ?"
            case LAError.systemCancel:
                self.lbResult.text = "แอบไปไหนมา"
            default:
                break
            }
            
        }
    }
    

}

