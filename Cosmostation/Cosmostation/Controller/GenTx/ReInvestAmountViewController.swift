//
//  ReInvestAmountViewController.swift
//  Cosmostation
//
//  Created by yongjoo on 05/06/2019.
//  Copyright © 2019 wannabit. All rights reserved.
//

import UIKit
import Alamofire

class ReInvestAmountViewController: BaseViewController {

    @IBOutlet weak var cardView: CardView!
    @IBOutlet weak var rewardAmountLabel: UILabel!
    @IBOutlet weak var rewardDenomLabel: UILabel!
    @IBOutlet weak var validatorLabel: UILabel!
    @IBOutlet weak var loadingImg: LoadingImageView!
    
    @IBOutlet weak var controlLayer: UIStackView!
    @IBOutlet weak var cancelBtn: UIButton!
    @IBOutlet weak var nextBtn: UIButton!
    
    var pageHolderVC: StepGenTxViewController!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        pageHolderVC = self.parent as? StepGenTxViewController
        WUtils.setDenomTitle(pageHolderVC.chainType!, rewardDenomLabel)
        
        self.loadingImg.onStartAnimation()
        if (pageHolderVC.chainType! == ChainType.COSMOS_MAIN || pageHolderVC.chainType! == ChainType.KAVA_MAIN || pageHolderVC.chainType! == ChainType.KAVA_TEST ||
                pageHolderVC.chainType! == ChainType.BAND_MAIN || pageHolderVC.chainType! == ChainType.SECRET_MAIN || pageHolderVC.chainType! == ChainType.IOV_MAIN ||
                pageHolderVC.chainType! == ChainType.IOV_TEST || pageHolderVC.chainType! == ChainType.CERTIK_MAIN || pageHolderVC.chainType! == ChainType.CERTIK_TEST) {
            self.onFetchReward(pageHolderVC.mAccount!.account_address, pageHolderVC.mTargetValidator!.operator_address)
        } else if (pageHolderVC.chainType! == ChainType.IRIS_MAIN) {
            self.onFetchIrisReward(pageHolderVC.mAccount!)
        }
    }
    
    @IBAction func onClickCancel(_ sender: Any) {
        cancelBtn.isUserInteractionEnabled = false
        nextBtn.isUserInteractionEnabled = false
        pageHolderVC.onBeforePage()
    }
    
    @IBAction func onClickNext(_ sender: Any) {
        cancelBtn.isUserInteractionEnabled = false
        nextBtn.isUserInteractionEnabled = false
        pageHolderVC.onNextPage()
    }
    
    override func enableUserInteraction() {
        self.cancelBtn.isUserInteractionEnabled = true
        self.nextBtn.isUserInteractionEnabled = true
    }
    
    func updateView() {
        if (pageHolderVC.chainType! == ChainType.COSMOS_MAIN && self.pageHolderVC.mReinvestReward != nil) {
            rewardAmountLabel.attributedText = WUtils.displayAmount2(pageHolderVC.mReinvestReward!.amount, rewardAmountLabel.font, 6, 6)
            validatorLabel.text = pageHolderVC.mTargetValidator?.description.moniker
            self.loadingImg.isHidden = true
            self.controlLayer.isHidden = false
            self.cardView.isHidden = false
            
        } else if (pageHolderVC.chainType! == ChainType.IRIS_MAIN) {
            rewardAmountLabel.attributedText = WUtils.displayAmount2(pageHolderVC.mReinvestReward!.amount, rewardAmountLabel.font, 18, 18)
            validatorLabel.text = pageHolderVC.mTargetValidator?.description.moniker
            self.loadingImg.isHidden = true
            self.controlLayer.isHidden = false
            self.cardView.isHidden = false
            
        } else if ((pageHolderVC.chainType! == ChainType.KAVA_MAIN || pageHolderVC.chainType! == ChainType.KAVA_TEST) &&
            self.pageHolderVC.mReinvestReward != nil) {
            rewardAmountLabel.attributedText = WUtils.displayAmount2(pageHolderVC.mReinvestReward!.amount, rewardAmountLabel.font, 6, 6)
            validatorLabel.text = pageHolderVC.mTargetValidator?.description.moniker
            self.loadingImg.isHidden = true
            self.controlLayer.isHidden = false
            self.cardView.isHidden = false
            
        } else if (pageHolderVC.chainType! == ChainType.BAND_MAIN && self.pageHolderVC.mReinvestReward != nil) {
            rewardAmountLabel.attributedText = WUtils.displayAmount2(pageHolderVC.mReinvestReward!.amount, rewardAmountLabel.font, 6, 6)
            validatorLabel.text = pageHolderVC.mTargetValidator?.description.moniker
            self.loadingImg.isHidden = true
            self.controlLayer.isHidden = false
            self.cardView.isHidden = false
            
        } else if (pageHolderVC.chainType! == ChainType.SECRET_MAIN && self.pageHolderVC.mReinvestReward != nil) {
            rewardAmountLabel.attributedText = WUtils.displayAmount2(pageHolderVC.mReinvestReward!.amount, rewardAmountLabel.font, 6, 6)
            validatorLabel.text = pageHolderVC.mTargetValidator?.description.moniker
            self.loadingImg.isHidden = true
            self.controlLayer.isHidden = false
            self.cardView.isHidden = false
            
        } else if ((pageHolderVC.chainType! == ChainType.IOV_MAIN || pageHolderVC.chainType! == ChainType.IOV_TEST) &&
            self.pageHolderVC.mReinvestReward != nil) {
            rewardAmountLabel.attributedText = WUtils.displayAmount2(pageHolderVC.mReinvestReward!.amount, rewardAmountLabel.font, 6, 6)
            validatorLabel.text = pageHolderVC.mTargetValidator?.description.moniker
            self.loadingImg.isHidden = true
            self.controlLayer.isHidden = false
            self.cardView.isHidden = false
            
        } else if ((pageHolderVC.chainType! == ChainType.CERTIK_MAIN || pageHolderVC.chainType! == ChainType.CERTIK_TEST) &&
                    self.pageHolderVC.mReinvestReward != nil) {
            rewardAmountLabel.attributedText = WUtils.displayAmount2(pageHolderVC.mReinvestReward!.amount, rewardAmountLabel.font, 6, 6)
            validatorLabel.text = pageHolderVC.mTargetValidator?.description.moniker
            self.loadingImg.isHidden = true
            self.controlLayer.isHidden = false
            self.cardView.isHidden = false
            
        } else {
            pageHolderVC.onBeforePage()
        }
    }

    func onFetchReward(_ accountAddr: String, _ validatorAddr:String) {
        var url: String?
        if (pageHolderVC.chainType! == ChainType.COSMOS_MAIN) {
            url = COSMOS_URL_REWARD_FROM_VAL + accountAddr + COSMOS_URL_REWARD_FROM_VAL_TAIL + validatorAddr
        } else if (pageHolderVC.chainType! == ChainType.KAVA_MAIN) {
            url = KAVA_REWARD_FROM_VAL + accountAddr + KAVA_REWARD_FROM_VAL_TAIL + validatorAddr
        } else if (pageHolderVC.chainType! == ChainType.KAVA_TEST) {
            url = KAVA_TEST_REWARD_FROM_VAL + accountAddr + KAVA_TEST_REWARD_FROM_VAL_TAIL + validatorAddr
        } else if (pageHolderVC.chainType! == ChainType.BAND_MAIN) {
            url = BAND_REWARD_FROM_VAL + accountAddr + BAND_REWARD_FROM_VAL_TAIL + validatorAddr
        } else if (pageHolderVC.chainType! == ChainType.SECRET_MAIN) {
            url = SECRET_REWARD_FROM_VAL + accountAddr + SECRET_REWARD_FROM_VAL_TAIL + validatorAddr
        } else if (pageHolderVC.chainType! == ChainType.IOV_MAIN) {
            url = IOV_REWARD_FROM_VAL + accountAddr + IOV_REWARD_FROM_VAL_TAIL + validatorAddr
        } else if (pageHolderVC.chainType! == ChainType.IOV_TEST) {
            url = IOV_TEST_REWARD_FROM_VAL + accountAddr + IOV_TEST_REWARD_FROM_VAL_TAIL + validatorAddr
        } else if (pageHolderVC.chainType! == ChainType.CERTIK_MAIN) {
            url = CERTIK_REWARD_FROM_VAL + accountAddr + CERTIK_REWARD_FROM_VAL_TAIL + validatorAddr
        } else if (pageHolderVC.chainType! == ChainType.CERTIK_TEST) {
            url = CERTIK_TEST_REWARD_FROM_VAL + accountAddr + CERTIK_TEST_REWARD_FROM_VAL_TAIL + validatorAddr
        }
        
        let request = Alamofire.request(url!, method: .get, parameters: [:], encoding: URLEncoding.default, headers: [:]);
        request.responseJSON { (response) in
            switch response.result {
            case .success(let res):
                if (self.pageHolderVC.chainType! == ChainType.COSMOS_MAIN) {
                    guard let responseData = res as? NSDictionary,
                        let rawRewards = responseData.object(forKey: "result") as? Array<NSDictionary> else {
                        self.updateView()
                        return;
                    }
                    for rawReward in rawRewards {
                        if let atomReward = rawReward.object(forKey: "denom") as? String, atomReward == COSMOS_MAIN_DENOM {
                            var coin = Coin(rawReward as! [String : Any])
                            coin.amount = NSDecimalNumber.init(string: coin.amount).rounding(accordingToBehavior: WUtils.handler0Down).stringValue
                            self.pageHolderVC.mReinvestReward = coin
                        }
                    }
                    
                } else if (self.pageHolderVC.chainType! == ChainType.KAVA_MAIN || self.pageHolderVC.chainType! == ChainType.KAVA_TEST) {
                    guard let responseData = res as? NSDictionary,
                        let rawRewards = responseData.object(forKey: "result") as? Array<NSDictionary> else {
                        self.updateView()
                        return;
                    }
                    for rawReward in rawRewards {
                        if let kavaReward = rawReward.object(forKey: "denom") as? String, kavaReward == KAVA_MAIN_DENOM {
                            var coin = Coin(rawReward as! [String : Any])
                            coin.amount = NSDecimalNumber.init(string: coin.amount).rounding(accordingToBehavior: WUtils.handler0Down).stringValue
                            self.pageHolderVC.mReinvestReward = coin
                        }
                    }
                    
                } else if (self.pageHolderVC.chainType! == ChainType.BAND_MAIN) {
                    guard let responseData = res as? NSDictionary,
                        let rawRewards = responseData.object(forKey: "result") as? Array<NSDictionary> else {
                        self.updateView()
                        return;
                    }
                    for rawReward in rawRewards {
                        if let bandReward = rawReward.object(forKey: "denom") as? String, bandReward == BAND_MAIN_DENOM {
                            var coin = Coin(rawReward as! [String : Any])
                            coin.amount = NSDecimalNumber.init(string: coin.amount).rounding(accordingToBehavior: WUtils.handler0Down).stringValue
                            self.pageHolderVC.mReinvestReward = coin
                        }
                    }
                    
                } else if (self.pageHolderVC.chainType! == ChainType.SECRET_MAIN) {
                    guard let responseData = res as? NSDictionary,
                        let rawRewards = responseData.object(forKey: "result") as? Array<NSDictionary> else {
                        self.updateView()
                        return;
                    }
                    for rawReward in rawRewards {
                        if let secretReward = rawReward.object(forKey: "denom") as? String, secretReward == SECRET_MAIN_DENOM {
                            var coin = Coin(rawReward as! [String : Any])
                            coin.amount = NSDecimalNumber.init(string: coin.amount).rounding(accordingToBehavior: WUtils.handler0Down).stringValue
                            self.pageHolderVC.mReinvestReward = coin
                        }
                    }
                    
                } else if (self.pageHolderVC.chainType! == ChainType.IOV_MAIN) {
                    guard let responseData = res as? NSDictionary,
                        let rawRewards = responseData.object(forKey: "result") as? Array<NSDictionary> else {
                        self.updateView()
                        return;
                    }
                    for rawReward in rawRewards {
                        if let iovReward = rawReward.object(forKey: "denom") as? String, iovReward == IOV_MAIN_DENOM {
                            var coin = Coin(rawReward as! [String : Any])
                            coin.amount = NSDecimalNumber.init(string: coin.amount).rounding(accordingToBehavior: WUtils.handler0Down).stringValue
                            self.pageHolderVC.mReinvestReward = coin
                        }
                    }
                    
                } else if (self.pageHolderVC.chainType! == ChainType.IOV_TEST) {
                    guard let responseData = res as? NSDictionary,
                        let rawRewards = responseData.object(forKey: "result") as? Array<NSDictionary> else {
                        self.updateView()
                        return;
                    }
                    for rawReward in rawRewards {
                        if let iovReward = rawReward.object(forKey: "denom") as? String, iovReward == IOV_TEST_DENOM {
                            var coin = Coin(rawReward as! [String : Any])
                            coin.amount = NSDecimalNumber.init(string: coin.amount).rounding(accordingToBehavior: WUtils.handler0Down).stringValue
                            self.pageHolderVC.mReinvestReward = coin
                        }
                    }
                    
                } else if (self.pageHolderVC.chainType! == ChainType.CERTIK_MAIN || self.pageHolderVC.chainType! == ChainType.CERTIK_TEST) {
                    guard let responseData = res as? NSDictionary,
                        let rawRewards = responseData.object(forKey: "result") as? Array<NSDictionary> else {
                        self.updateView()
                        return;
                    }
                    for rawReward in rawRewards {
                        if let certikReward = rawReward.object(forKey: "denom") as? String, certikReward == CERTIK_MAIN_DENOM {
                            var coin = Coin(rawReward as! [String : Any])
                            coin.amount = NSDecimalNumber.init(string: coin.amount).rounding(accordingToBehavior: WUtils.handler0Down).stringValue
                            self.pageHolderVC.mReinvestReward = coin
                        }
                    }
                    
                }
                
            case .failure(let error):
                if(SHOW_LOG) { print("onFetchEachReward ", error) }
            }
            self.updateView()
        }
    }
    
    func onFetchIrisReward(_ account: Account) {
        let url = IRIS_LCD_URL_REWARD + account.account_address + IRIS_LCD_URL_REWARD_TAIL
        let request = Alamofire.request(url, method: .get, parameters: [:], encoding: URLEncoding.default, headers: [:]);
        request.responseJSON { (response) in
            switch response.result {
            case .success(let res):
                print("res ", res)
                guard let irisRewards = res as? NSDictionary else {
                    self.updateView()
                    return
                }
                let rewards = IrisRewards(irisRewards as! [String : Any])
                self.pageHolderVC.mReinvestReward = rewards.getPerValRewardCoin(valOp: self.pageHolderVC.mTargetValidator!.operator_address)
                
            case .failure(let error):
                if(SHOW_LOG) { print("onFetchIrisReward ", error) }
            }
            self.updateView()
        }
        
    }
    
}
