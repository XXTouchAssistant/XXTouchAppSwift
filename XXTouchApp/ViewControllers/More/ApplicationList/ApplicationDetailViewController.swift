//
//  ApplicationDetailViewController.swift
//  XXTouchApp
//
//  Created by mcy on 16/6/21.
//  Copyright © 2016年 mcy. All rights reserved.
//

import UIKit

class ApplicationDetailViewController: UIViewController {
  private enum Section: Int, Countable {
    case AppName
    case AppPackageName
    case AppBundlePath
    case AppDataPath
    case ClearAppData
  }
  
  private let model: ApplicationListModel
  private let tableView = UITableView(frame: CGRectZero, style: .Grouped)
  
  private lazy var appNameCell: ApplicationDetailCell = {
    let appNameCell = ApplicationDetailCell()
    appNameCell.contentView.tag = 0
    return appNameCell
  }()
  
  private lazy var appPackageNameCell: ApplicationDetailCell = {
    let appPackageNameCell = ApplicationDetailCell()
    appPackageNameCell.contentView.tag = 1
    return appPackageNameCell
  }()
  
  private lazy var appBundlePathCell: ApplicationDetailCell = {
    let appBundlePathCell = ApplicationDetailCell()
    appBundlePathCell.contentView.tag = 2
    return appBundlePathCell
  }()
  
  private lazy var appDataPathCell: ApplicationDetailCell = {
    let appDataPathCell = ApplicationDetailCell()
    appDataPathCell.contentView.tag = 3
    return appDataPathCell
  }()
  
  private lazy var headerTitleList: [String] = {
    let headerTitleList = [
      "应用名称",
      "应用包名",
      "应用包路径",
      "应用数据路径"
    ]
    return headerTitleList
  }()
  
  private var clearAppDataCell: CustomButtonCell = {
    let clearAppDataCell = CustomButtonCell(buttonTitle: "清理应用数据", titleColor: UIColor.whiteColor())
    clearAppDataCell.backgroundColor = ThemeManager.Theme.redBackgroundColor
    return clearAppDataCell
  }()
  
  
  override func viewDidLayoutSubviews() {
    appBundlePathCell.scrollView.contentSize.width = appBundlePathCell.titleLabel.mj_textWith()+Sizer.valueForDevice(phone: 40, pad: 45)
    appDataPathCell.scrollView.contentSize.width = appDataPathCell.titleLabel.mj_textWith()+Sizer.valueForDevice(phone: 40, pad: 45)
  }
  
  override func viewDidLoad() {
    super.viewDidLoad()
    setupUI()
    makeConstriants()
    setupAction()
  }
  
  init(model: ApplicationListModel) {
    self.model = model
    super.init(nibName: nil, bundle: nil)
  }
  
  required init?(coder aDecoder: NSCoder) {
    fatalError("init(coder:) has not been implemented")
  }
  
  private func setupUI() {
    view.backgroundColor = UIColor.whiteColor()
    navigationItem.title = "应用详情"
    
    tableView.delegate  = self
    tableView.dataSource = self
    
    view.addSubview(tableView)
  }
  
  private func makeConstriants() {
    tableView.snp_makeConstraints { (make) in
      make.edges.equalTo(view)
    }
  }
  
  private func setupAction() {
    appNameCell.tap.addTarget(self, action: #selector(pasteboard(_:)))
    appPackageNameCell.tap.addTarget(self, action: #selector(pasteboard(_:)))
    appDataPathCell.tap.addTarget(self, action: #selector(pasteboard(_:)))
    appBundlePathCell.tap.addTarget(self, action: #selector(pasteboard(_:)))
  }
  
  @objc private func pasteboard(tap: UITapGestureRecognizer) {
    let indexPath = NSIndexPath(forRow: 0, inSection: tap.view!.tag)
    tableView.selectRowAtIndexPath(indexPath, animated: false, scrollPosition: .None)
    switch Section(rawValue: indexPath.section)! {
    case .AppName: UIPasteboard.generalPasteboard().string = model.name
    case .AppPackageName: UIPasteboard.generalPasteboard().string = model.packageName
    case .AppBundlePath: UIPasteboard.generalPasteboard().string = model.bundlePath
    case .AppDataPath: UIPasteboard.generalPasteboard().string = model.dataPath
    default: return
    }
    self.view.showHUD(.Success, text: Constants.Text.copy) { (_) in
      self.tableView.deselectRowAtIndexPath(indexPath, animated: true)
    }
  }
}

extension ApplicationDetailViewController: UITableViewDelegate, UITableViewDataSource {
  func numberOfSectionsInTableView(tableView: UITableView) -> Int {
    return Section.count
  }
  
  func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
    return 1
  }
  
  func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
    switch Section(rawValue: indexPath.section)! {
    case .AppName:
      appNameCell.bind(model.name)
      return appNameCell
    case .AppPackageName:
      appPackageNameCell.bind(model.packageName)
      return appPackageNameCell
    case .AppBundlePath:
      appBundlePathCell.bind(model.bundlePath)
      return appBundlePathCell
    case .AppDataPath:
      appDataPathCell.bind(model.dataPath)
      return appDataPathCell
    case .ClearAppData: return clearAppDataCell
    }
  }
  
  func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
    switch Section(rawValue: indexPath.section)! {
    case .ClearAppData:
      self.alertShowTwoButton(message: "是否确定要清理？", cancelHandler: { [weak self] (_) in
        guard let `self` = self else { return }
        self.tableView.deselectRowAtIndexPath(indexPath, animated: true)
        }, otherHandler: { [weak self] (_) in
          guard let `self` = self else { return }
          self.tableView.deselectRowAtIndexPath(indexPath, animated: true)
          self.clearAppData()
        })
    default: break
    }
  }
  
  func tableView(tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
    return Sizer.valueForDevice(phone: 30, pad: 40)
  }
  
  func tableView(tableView: UITableView, heightForFooterInSection section: Int) -> CGFloat {
    return 0.01
  }
  
  func tableView(tableView: UITableView, heightForRowAtIndexPath indexPath: NSIndexPath) -> CGFloat {
    return Sizer.valueForDevice(phone: 45, pad: 55)
  }
  
  func tableView(tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
    if UIDevice.isPad {
      return nil
    } else {
      switch Section(rawValue: section)! {
      case .ClearAppData: return nil
      default: return headerTitleList[section]
      }
    }
  }
  
  func tableView(tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
    if UIDevice.isPad {
      switch Section(rawValue: section)! {
      case .ClearAppData: return nil
      default: return CustomHeaderOrFooter(title: headerTitleList[section], textColor: UIColor.grayColor(), font: UIFont.systemFontOfSize(17), alignment: .Left)
      }
    } else {
      return nil
    }
  }
}

extension ApplicationDetailViewController {
  func clearAppData() {
    self.view.showHUD(text: "正在清除")
    Service.clearAppData(bid: model.packageName) { [weak self] (data, _, error) in
      guard let `self` = self else { return }
      if let data = data where JSON(data: data) != nil {
        let json = JSON(data: data)
        switch json["code"].intValue {
        case 0: self.view.showHUD(.Success, text: "清除成功")
        default:
          self.alertShowOneButton(message: json["message"].stringValue)
          self.view.dismissHUD()
          return
        }
      }
      if error != nil {
        self.view.dismissHUD()
        self.alertShowOneButton(message: Constants.Error.networkFailure)
      }
    }
  }
}
