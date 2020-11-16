//
//  SelectPopupViewController.swift
//  Cosmostation
//
//  Created by 정용주 on 2020/04/16.
//  Copyright © 2020 wannabit. All rights reserved.
//

import UIKit

class SelectPopupViewController: BaseViewController, SBCardPopupContent, UITableViewDelegate, UITableViewDataSource {
    
    var popupViewController: SBCardPopupViewController?
    let allowsTapToDismissPopupCard =  true
    let allowsSwipeToDismissPopupCard =  false
    
    @IBOutlet weak var cardView: CardView!
    @IBOutlet weak var popupTitle: UILabel!
    @IBOutlet weak var popupTableview: UITableView!
    
    var type: Int?
    var toChain: ChainType?
    var toChainList = Array<ChainType>()
    var toCoinList = Array<String>()
    var toAccountList = Array<Account>()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        account = BaseData.instance.selectAccountById(id: BaseData.instance.getRecentAccountId())
        chainType = WUtils.getChainType(account!.account_base_chain)
        
        self.popupTableview.delegate = self
        self.popupTableview.dataSource = self
        self.popupTableview.separatorStyle = UITableViewCell.SeparatorStyle.none
        self.popupTableview.register(UINib(nibName: "SelectChainCell", bundle: nil), forCellReuseIdentifier: "SelectChainCell")
        self.popupTableview.register(UINib(nibName: "SelectCoinCell", bundle: nil), forCellReuseIdentifier: "SelectCoinCell")
        self.popupTableview.register(UINib(nibName: "SelectAccountCell", bundle: nil), forCellReuseIdentifier: "SelectAccountCell")
        self.popupTableview.rowHeight = UITableView.automaticDimension
        self.popupTableview.estimatedRowHeight = UITableView.automaticDimension
        
        if (type == SELECT_POPUP_HTLC_TO_CHAIN) {
            self.popupTitle.text = NSLocalizedString("select_destination_chain", comment: "")
            self.toChainList = ChainType.getHtlcSendable(chainType!)
            
        } else if (type == SELECT_POPUP_HTLC_TO_COIN) {
            self.popupTitle.text = NSLocalizedString("str_select_to_send_coin", comment: "")
            self.toCoinList = ChainType.getHtlcSwappableCoin(chainType!)
            
        } else if (type == SELECT_POPUP_HTLC_TO_ACCOUNT) {
            self.popupTitle.text = NSLocalizedString("select_account", comment: "")
            self.toAccountList = BaseData.instance.selectAllAccountsByHtlcClaim(toChain)
            
        } else if (type == SELECT_POPUP_STARNAME_ACCOUNT) {
            self.popupTitle.text = NSLocalizedString("select_account", comment: "")
            self.toAccountList = BaseData.instance.selectAllAccountsByChain(toChain!)
        }
    }
    
    override func viewDidLayoutSubviews() {
        var esHeight: CGFloat = 250
        if (type == SELECT_POPUP_HTLC_TO_CHAIN) {
            esHeight = (CGFloat)((toChainList.count * 55) + 55)
        } else if (type == SELECT_POPUP_HTLC_TO_COIN) {
            esHeight = (CGFloat)((toCoinList.count * 55) + 55)
        } else if (type == SELECT_POPUP_HTLC_TO_ACCOUNT) {
            esHeight = (CGFloat)((toAccountList.count * 55) + 55)
        } else if (type == SELECT_POPUP_STARNAME_ACCOUNT) {
            esHeight = (CGFloat)((toAccountList.count * 55) + 55)
        }
        esHeight = (esHeight > 250) ? 250 : esHeight
        cardView.frame = CGRect(x: cardView.frame.origin.x, y: cardView.frame.origin.y, width: cardView.frame.size.width, height: esHeight)
        cardView.layoutIfNeeded()
    }
    
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if (type == SELECT_POPUP_HTLC_TO_CHAIN) {
            return toChainList.count;
        } else if (type == SELECT_POPUP_HTLC_TO_COIN) {
            return toCoinList.count
        } else if (type == SELECT_POPUP_HTLC_TO_ACCOUNT) {
            return toAccountList.count
        } else if (type == SELECT_POPUP_STARNAME_ACCOUNT) {
            return toAccountList.count
        }
        return 0
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        if (type == SELECT_POPUP_HTLC_TO_CHAIN) {
            let cell:SelectChainCell? = tableView.dequeueReusableCell(withIdentifier:"SelectChainCell") as? SelectChainCell
            let chain = toChainList[indexPath.row]
            WUtils.dpChainInfo(chain, cell!.chainImg, cell!.chainTitle)
            return cell!
            
        } else if (type == SELECT_POPUP_HTLC_TO_COIN) {
            let cell:SelectCoinCell? = tableView.dequeueReusableCell(withIdentifier:"SelectCoinCell") as? SelectCoinCell
            let toSendCoin = toCoinList[indexPath.row]
            if (chainType! == ChainType.BINANCE_MAIN) {
                if (toSendCoin == TOKEN_HTLC_BINANCE_BNB) {
                    cell!.coinImg.image = UIImage(named: "bnbTokenImg")
                    cell!.coinTitle.text = "BNB"
                } else if (toSendCoin == TOKEN_HTLC_BINANCE_BTCB) {
                    cell?.coinImg.af_setImage(withURL: URL(string: TOKEN_IMG_URL + "BTCB.png")!)
                    cell!.coinTitle.text = "BTC"
                } else if (toSendCoin == TOKEN_HTLC_BINANCE_XRPB) {
                    cell?.coinImg.af_setImage(withURL: URL(string: TOKEN_IMG_URL + "XRP.png")!)
                    cell!.coinTitle.text = "XRP"
                } else if (toSendCoin == TOKEN_HTLC_BINANCE_BUSD) {
                    cell?.coinImg.af_setImage(withURL: URL(string: TOKEN_IMG_URL + "BUSD.png")!)
                    cell!.coinTitle.text = "BUSD"
                }
                
            } else if (chainType! == ChainType.BINANCE_TEST) {
                if (toSendCoin == TOKEN_HTLC_BINANCE_TEST_BNB) {
                    cell!.coinImg.image = UIImage(named: "bnbTokenImg")
                    cell!.coinTitle.text = "BNB"
                } else if (toSendCoin == TOKEN_HTLC_BINANCE_TEST_BTC) {
                    cell!.coinImg.image = UIImage(named: "btcTokenImg")
                    cell!.coinTitle.text = "BTC"
                }
                
            } else if (chainType! == ChainType.KAVA_MAIN) {
                if (toSendCoin == TOKEN_HTLC_KAVA_BNB) {
                    cell?.coinImg.af_setImage(withURL: URL(string: KAVA_COIN_IMG_URL + "bnb.png")!)
                    cell!.coinTitle.text = "BNB"
                } else if (toSendCoin == TOKEN_HTLC_KAVA_BTCB) {
                    cell?.coinImg.af_setImage(withURL: URL(string: KAVA_COIN_IMG_URL + "btcb.png")!)
                    cell!.coinTitle.text = "BTC"
                } else if (toSendCoin == TOKEN_HTLC_KAVA_XRPB) {
                    cell?.coinImg.af_setImage(withURL: URL(string: KAVA_COIN_IMG_URL  + "xrpb.png")!)
                    cell!.coinTitle.text = "XRP"
                } else if (toSendCoin == TOKEN_HTLC_KAVA_BUSD) {
                    cell?.coinImg.af_setImage(withURL: URL(string: KAVA_COIN_IMG_URL  + "busd.png")!)
                    cell!.coinTitle.text = "BUSD"
                }
                
            } else if (chainType! == ChainType.KAVA_TEST) {
                if (toSendCoin == TOKEN_HTLC_KAVA_TEST_BNB) {
                    cell!.coinImg.image = UIImage(named: "bnbonKavaImg")
                    cell!.coinTitle.text = "BNB"
                } else if (toSendCoin == TOKEN_HTLC_KAVA_TEST_BTC) {
                    cell!.coinImg.image = UIImage(named: "btconKavaImg")
                    cell!.coinTitle.text = "BTC"
                }
            }
            return cell!
            
        } else if (type == SELECT_POPUP_HTLC_TO_ACCOUNT) {
            let cell:SelectAccountCell? = tableView.dequeueReusableCell(withIdentifier:"SelectAccountCell") as? SelectAccountCell
            let account = toAccountList[indexPath.row]
            cell?.keyStatusImg.image = cell?.keyStatusImg.image?.withRenderingMode(.alwaysTemplate)
            cell?.accountAddress.text = account.account_address
            WUtils.setDenomTitle(toChain!, cell!.accountDenom)
            if (toChain == ChainType.BINANCE_MAIN || toChain == ChainType.BINANCE_TEST) {
                cell?.keyStatusImg.tintColor = COLOR_BNB
                cell!.accountBalance.attributedText = WUtils.displayAmount2(WUtils.getTokenAmount(account.account_balances, BNB_MAIN_DENOM).stringValue, cell!.accountBalance.font, 0, 8)
                
            } else if (toChain == ChainType.KAVA_MAIN || toChain == ChainType.KAVA_TEST) {
                cell?.keyStatusImg.tintColor = COLOR_KAVA
                cell!.accountBalance.attributedText = WUtils.displayAmount2(WUtils.getTokenAmount(account.account_balances, KAVA_MAIN_DENOM).stringValue, cell!.accountBalance.font, 6, 6)
            }
            return cell!
            
        } else if (type == SELECT_POPUP_STARNAME_ACCOUNT) {
            let cell:SelectAccountCell? = tableView.dequeueReusableCell(withIdentifier:"SelectAccountCell") as? SelectAccountCell
            let account = toAccountList[indexPath.row]
            WUtils.setDenomTitle(toChain!, cell!.accountDenom)
            cell?.accountAddress.text = account.account_address
            cell?.accountName.text = account.getDpName()
            cell?.keyStatusImg.image = cell?.keyStatusImg.image?.withRenderingMode(.alwaysTemplate)
            if (account.account_has_private) {
                cell?.keyStatusImg.tintColor = WUtils.getChainColor(toChain)
            } else {
                cell?.keyStatusImg.tintColor = UIColor.init(hexString: "7A7f88")
            }
            cell?.accountBalance.attributedText = WUtils.displayAmount2(account.account_last_total, cell!.accountBalance.font, 0, 6)
            return cell!
            
        } else {
            let cell:SelectAccountCell? = tableView.dequeueReusableCell(withIdentifier:"SelectAccountCell") as? SelectAccountCell
            return cell!
        }
    }
    
     func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        popupViewController?.resultDelegate?.SBCardPopupResponse(type: type!, result: indexPath.row)
        popupViewController?.close()
    }

}
