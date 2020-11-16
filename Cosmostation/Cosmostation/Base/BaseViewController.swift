//
//  BaseViewController.swift
//  Cosmostation
//
//  Created by yongjoo on 05/03/2019.
//  Copyright © 2019 wannabit. All rights reserved.
//

import UIKit
import Toast_Swift
import QRCode
import Alamofire
import SafariServices
import SwiftKeychainWrapper

class BaseViewController: UIViewController {
    
    var account:Account?
    var chainType:ChainType?
    var balances = Array<Balance>()
    var waitAlert: UIAlertController?

    override func viewDidLoad() {
        super.viewDidLoad()
    }
    
    override var preferredStatusBarStyle: UIStatusBarStyle {
        return .lightContent
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        self.startAvoidingKeyboard()
    }
    
    override func viewDidDisappear(_ animated: Bool) {
        super.viewDidDisappear(animated)
        self.stopAvoidingKeyboard()
    }
    
    public func showWaittingAlert() {
        waitAlert = UIAlertController(title: "", message: "\n\n\n\n", preferredStyle: .alert)
        let image = LoadingImageView(frame: CGRect(x: 0, y: 0, width: 58, height: 58))
        waitAlert!.view.addSubview(image)
        image.translatesAutoresizingMaskIntoConstraints = false
        waitAlert!.view.addConstraint(NSLayoutConstraint(item: image, attribute: .centerX, relatedBy: .equal, toItem: waitAlert!.view, attribute: .centerX, multiplier: 1, constant: 0))
        waitAlert!.view.addConstraint(NSLayoutConstraint(item: image, attribute: .centerY, relatedBy: .equal, toItem: waitAlert!.view, attribute: .centerY, multiplier: 1, constant: 0))
        waitAlert!.view.addConstraint(NSLayoutConstraint(item: image, attribute: .width, relatedBy: .equal, toItem: nil, attribute: .notAnAttribute, multiplier: 1.0, constant: 58.0))
        waitAlert!.view.addConstraint(NSLayoutConstraint(item: image, attribute: .height, relatedBy: .equal, toItem: nil, attribute: .notAnAttribute, multiplier: 1.0, constant: 58.0))
        WUtils.clearBackgroundColor(of: waitAlert!.view)
        self.present(waitAlert!, animated: true, completion: nil)
        image.onStartAnimation()
        
    }
    
    public func hideWaittingAlert() {
        if (waitAlert != nil) {
            waitAlert?.dismiss(animated: true, completion: nil)
        }
    }
    
    func onStartMainTab() {
//        print("onStartMainTab")
        let mainTabVC = UIStoryboard(name: "MainStoryboard", bundle: nil).instantiateViewController(withIdentifier: "MainTabViewController") as! MainTabViewController
        let appDelegate = UIApplication.shared.delegate as! AppDelegate
        appDelegate.window?.rootViewController = mainTabVC
        self.present(mainTabVC, animated: true, completion: nil)
    }
    
    
    func onStartImportMnemonic() {
//        print("onStartImportMnemonic")
        let restoreVC = UIStoryboard(name: "Init", bundle: nil).instantiateViewController(withIdentifier: "RestoreViewController") as! RestoreViewController
        restoreVC.hidesBottomBarWhenPushed = true
        self.navigationItem.title = ""
        self.navigationController?.pushViewController(restoreVC, animated: true)
    }
    
    func onStartImportAddress() {
//        print("onStartImportAddress")
        let addAddressVC = UIStoryboard(name: "Init", bundle: nil).instantiateViewController(withIdentifier: "AddAddressViewController") as! AddAddressViewController
        addAddressVC.hidesBottomBarWhenPushed = true
        self.navigationItem.title = ""
        self.navigationController?.pushViewController(addAddressVC, animated: true)
    }
    
    func onStartCreate() {
//        print("onStartCreate")
        let createVC = UIStoryboard(name: "Init", bundle: nil).instantiateViewController(withIdentifier: "CreateViewController") as! CreateViewController
        createVC.hidesBottomBarWhenPushed = true
        self.navigationItem.title = ""
        self.navigationController?.pushViewController(createVC, animated: true)
    }
    
    func onStartTxDetail(_ response:[String:Any]) {
        let txDetailVC = TxDetailViewController(nibName: "TxDetailViewController", bundle: nil)
        txDetailVC.mIsGen = true
        txDetailVC.mBroadCaseResult = response
        self.navigationItem.title = ""
        self.navigationController?.interactivePopGestureRecognizer?.isEnabled = false;
        self.navigationController?.pushViewController(txDetailVC, animated: true)
    }
    
    func onDeleteWallet(_ account:Account) {
        self.showWaittingAlert()
        self.onDeleteAlarm(account)
        DispatchQueue.global().async {
            BaseData.instance.deleteAccount(account: account)
            BaseData.instance.deleteBalance(account: account)
            BaseData.instance.deleteBonding(account: account)
            BaseData.instance.deleteUnbonding(account: account)
            
            if (KeychainWrapper.standard.hasValue(forKey: account.account_uuid.sha1())) {
                KeychainWrapper.standard.removeObject(forKey: account.account_uuid.sha1())
            }
            
            if (BaseData.instance.selectAllAccounts().count <= 0) {
                //TODO delete password
            } else {
                BaseData.instance.setRecentAccountId(BaseData.instance.selectAllAccounts()[0].account_id)
            }
            DispatchQueue.main.async(execute: {
                self.hideWaittingAlert()
                self.onShowToast(NSLocalizedString("wallet_delete_complete", comment: ""))
                
                let introVC = UIStoryboard(name: "Init", bundle: nil).instantiateViewController(withIdentifier: "StartNavigation")
                let appDelegate = UIApplication.shared.delegate as! AppDelegate
                appDelegate.window?.rootViewController = introVC
                self.present(introVC, animated: true, completion: nil)
            });
        }
    }
    
    func onShowToast(_ text:String) {
        var style = ToastStyle()
        style.backgroundColor = UIColor.gray
        self.view.makeToast(text, duration: 2.0, position: .bottom, style: style)
    }
    
    func shareAddress(_ address:String, _ nickName:String) {
        var qrCode = QRCode(address)
        qrCode?.backgroundColor = CIColor(rgba: "EEEEEE")
        qrCode?.size = CGSize(width: 200, height: 200)
        
        let alert = UIAlertController(title: nickName, message: "\n\n\n\n\n\n\n\n", preferredStyle: .alert)
        alert.view.subviews.first?.subviews.first?.subviews.first?.backgroundColor = UIColor.init(hexString: "EEEEEE")
        alert.addAction(UIAlertAction(title: NSLocalizedString("share", comment: ""), style: .default, handler:  { [weak alert] (_) in
            let shareTypeAlert = UIAlertController(title: nil, message: nil, preferredStyle: .alert)
            shareTypeAlert.addAction(UIAlertAction(title: NSLocalizedString("share_text", comment: ""), style: .default, handler: { [weak shareTypeAlert] (_) in
                let textToShare = [ address ]
                let activityViewController = UIActivityViewController(activityItems: textToShare, applicationActivities: nil)
                activityViewController.popoverPresentationController?.sourceView = self.view
                self.present(activityViewController, animated: true, completion: nil)
            }))
            shareTypeAlert.addAction(UIAlertAction(title: NSLocalizedString("share_qr", comment: ""), style: .default, handler: { [weak shareTypeAlert] (_) in
                let image = qrCode?.image
                let imageToShare = [ image! ]
                let activityViewController = UIActivityViewController(activityItems: imageToShare, applicationActivities: nil)
                activityViewController.popoverPresentationController?.sourceView = self.view
                self.present(activityViewController, animated: true, completion: nil)
            }))
            self.present(shareTypeAlert, animated: true) {
                let tapGesture = UITapGestureRecognizer(target: self, action: #selector(self.dismissAlertController))
                shareTypeAlert.view.superview?.subviews[0].addGestureRecognizer(tapGesture)
            }
        }))
        
        alert.addAction(UIAlertAction(title: NSLocalizedString("copy", comment: ""), style: .default, handler: { [weak alert] (_) in
            UIPasteboard.general.string = address
            self.onShowToast(NSLocalizedString("address_copied", comment: ""))
        }))
        
        let image = UIImageView(image: qrCode?.image)
        image.contentMode = .scaleAspectFit
        alert.view.addSubview(image)
        image.translatesAutoresizingMaskIntoConstraints = false
        alert.view.addConstraint(NSLayoutConstraint(item: image, attribute: .centerX, relatedBy: .equal, toItem: alert.view, attribute: .centerX, multiplier: 1, constant: 0))
        alert.view.addConstraint(NSLayoutConstraint(item: image, attribute: .centerY, relatedBy: .equal, toItem: alert.view, attribute: .centerY, multiplier: 1, constant: 0))
        alert.view.addConstraint(NSLayoutConstraint(item: image, attribute: .width, relatedBy: .equal, toItem: nil, attribute: .notAnAttribute, multiplier: 1.0, constant: 140.0))
        alert.view.addConstraint(NSLayoutConstraint(item: image, attribute: .height, relatedBy: .equal, toItem: nil, attribute: .notAnAttribute, multiplier: 1.0, constant: 140.0))
        self.present(alert, animated: true) {
            let tapGesture = UITapGestureRecognizer(target: self, action: #selector(self.dismissAlertController))
            alert.view.superview?.subviews[0].addGestureRecognizer(tapGesture)
        }
    }
    
    @objc func dismissAlertController(){
        self.dismiss(animated: true, completion: nil)
    }
    
    func onShowAddMenomicDialog() {
        let alert = UIAlertController(title: NSLocalizedString("alert_title_no_private_key", comment: ""), message: NSLocalizedString("alert_msg_no_private_key", comment: ""), preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: NSLocalizedString("add_mnemonic", comment: ""), style: .default, handler: { [weak alert] (_) in
            self.onStartImportMnemonic()
        }))
        alert.addAction(UIAlertAction(title: NSLocalizedString("cancel", comment: ""), style: .cancel, handler: nil))
        self.present(alert, animated: true, completion: nil)
    }
    
    func onShowSafariWeb(_ url: URL) {
        let safariViewController = SFSafariViewController(url: url)
        safariViewController.modalPresentationStyle = .popover
        present(safariViewController, animated: true, completion: nil)
    }
    
    
    
    
    
}
extension BaseViewController {
    
    func startAvoidingKeyboard() {
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillShow), name: UIWindow.keyboardWillShowNotification, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(self.keyboardWillHide), name: UIWindow.keyboardWillHideNotification, object: nil)
    }
    
    func stopAvoidingKeyboard() {
        NotificationCenter.default.removeObserver(self, name: UIWindow.keyboardWillShowNotification, object: nil)
        NotificationCenter.default.removeObserver(self, name: UIWindow.keyboardWillHideNotification, object: nil)
        
    }
    
    @objc func keyboardWillShow(notification: NSNotification) {
        self._onKeyboardFrameWillChangeNotificationReceived(notification as Notification)
    }
    
    @objc func keyboardWillHide(notification: NSNotification){
        self._onKeyboardFrameWillChangeNotificationReceived(notification as Notification)
    }
    
    @objc private func _onKeyboardFrameWillChangeNotificationReceived(_ notification: Notification) {
        guard let userInfo = notification.userInfo,
            let keyboardFrame = (userInfo[UIResponder.keyboardFrameEndUserInfoKey] as? NSValue)?.cgRectValue else {
                return
        }

        let keyboardFrameInView = view.convert(keyboardFrame, from: nil)
        let safeAreaFrame = view.safeAreaLayoutGuide.layoutFrame.insetBy(dx: 0, dy: -additionalSafeAreaInsets.bottom)
        let intersection = safeAreaFrame.intersection(keyboardFrameInView)

        let animationDuration: TimeInterval = (notification.userInfo?[UIResponder.keyboardAnimationDurationUserInfoKey] as? NSNumber)?.doubleValue ?? 0
        let animationCurveRawNSN = notification.userInfo?[UIResponder.keyboardAnimationCurveUserInfoKey] as? NSNumber
        let animationCurveRaw = animationCurveRawNSN?.uintValue ?? UIView.AnimationOptions.curveEaseInOut.rawValue
        let animationCurve = UIView.AnimationOptions(rawValue: animationCurveRaw)

        UIView.animate(withDuration: animationDuration, delay: 0, options: animationCurve, animations: {
            self.additionalSafeAreaInsets.bottom = intersection.height
            self.view.layoutIfNeeded()
        }, completion: nil)
    }
    
    
    @objc func enableUserInteraction() {
    }
    
    @objc func disableUserInteraction() {
    }
    
    func onToggleAlarm(_ account: Account, completion: @escaping (Bool) -> ()) {
        let param = ["chain_id":WUtils.getChainTypeInt(account.account_base_chain),
                     "device_type":"ios",
                     "address":account.account_address,
                     "alarm_token":BaseData.instance.getFCMToken(),
                     "alarm_status":!account.account_push_alarm] as [String : Any]
        let request = Alamofire.request(CSS_PUSH_UPDATE, method: .post, parameters: param, encoding: JSONEncoding.default, headers: [:])
        request.responseJSON { (response) in
            switch response.result {
            case .success(let res):
                guard let responseData = res as? NSDictionary else {
                    completion(true)
                    return
                }
                let result = responseData.object(forKey: "result") as? Bool ?? false
                if (result) {
                    BaseData.instance.updatePushAlarm(account, !account.account_push_alarm)
                    completion(true)
                }
                completion(false)
                

            case .failure(_):
                completion(false)
            }
        }
    }
    
    func onDeleteAlarm(_ account: Account) {
        let param = ["chain_id":WUtils.getChainTypeInt(account.account_base_chain),
                     "device_type":"ios",
                     "address":account.account_address,
                     "alarm_token":BaseData.instance.getFCMToken(),
                     "alarm_status":false] as [String : Any]
        let request = Alamofire.request(CSS_PUSH_UPDATE, method: .post, parameters: param, encoding: JSONEncoding.default, headers: [:])
        request.responseJSON { (response) in
            switch response.result {
            case .success(let res):
                print("res ", res)

            case .failure(let error):
                print("error ", error)
            }
        }
    }
}
