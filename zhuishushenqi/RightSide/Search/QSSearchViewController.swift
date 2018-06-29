//
//  QSSearchViewController.swift
//  zhuishushenqi
//
//  Created Nory Cao on 2017/4/10.
//  Copyright © 2017年 QS. All rights reserved.
//
//  Template generated by Juanpe Catalán @JuanpeCMiOS
//

import UIKit
import RxCocoa
import RxSwift

class QSSearchViewController: BaseViewController{

	var presenter: QSSearchPresenterProtocol?
    
    var hotWords = [String]() {
        didSet{
            tableView.reloadData()
        }
    }
    var searchList:[[String]] = []
    var searchWords:String = ""
    var books = [Book]()
    var headerView:QSSearchHeaderView!
    var historyHeader:QSHistoryHeaderView!
    var resultTableView:QSSearchResultTable!
    var autoCompleteTable:QSSearchAutoCompleteTable!

    lazy var tableView:UITableView = {
        let tableView = UITableView(frame: CGRect(x: 0, y: kNavgationBarHeight + 56, width: ScreenWidth, height: ScreenHeight - (kNavgationBarHeight + 56)), style: .grouped)
        tableView.dataSource = self
        tableView.delegate = self
        tableView.estimatedSectionHeaderHeight = 80
        tableView.sectionHeaderHeight = UITableViewAutomaticDimension
        tableView.sectionFooterHeight = 10
        tableView.rowHeight = 44
        tableView.backgroundColor = UIColor.white
        tableView.qs_registerCellNib(QSHistoryCell.self)
        return tableView
    }()
    
    lazy var searchController:UISearchController = {
        let searchVC:UISearchController = UISearchController(searchResultsController: nil)
        searchVC.searchBar.placeholder = "输入书名或作者名"
        searchVC.searchResultsUpdater = self
        searchVC.delegate = self
        searchVC.searchBar.delegate = self
//        [UIColor colorWithRed:0.84 green:0.84 blue:0.86 alpha:1.00]
        //        searchVC.obscuresBackgroundDuringPresentation = true
        searchVC.hidesNavigationBarDuringPresentation = true
        searchVC.searchBar.sizeToFit()
        searchVC.searchBar.backgroundColor = UIColor(red: 0.84, green: 0.84, blue: 0.86, alpha: 1.0)
        searchVC.searchBar.barTintColor = UIColor.white
        searchVC.searchBar.layer.borderColor = UIColor.white.cgColor
        return searchVC
    }()

	override func viewDidLoad() {
        super.viewDidLoad()
        initSubview()
        self.presenter?.viewDidLoad()
        
        self.searchController.searchBar.addObserverBlock(forKeyPath: "frame") { (item1, item2, item3) in
            QSLog("item1:\(item1) \nitem2:\(item2) \nitem3:\(item3)")
        }
        
    }
    
    func initSubview(){
        let bgView = UIView()
        bgView.backgroundColor = UIColor(red: 0.94, green: 0.94, blue: 0.96, alpha: 1.0)
        bgView.frame = CGRect(x: 0, y: kNavgationBarHeight, width: self.view.bounds.width, height: 56)
//        bgView.addSubview(self.searchController.searchBar)
        view.addSubview(bgView)
        
        self.view.addSubview(self.searchController.view)
        
        self.headerView = QSSearchHeaderView(frame: CGRect(x: 0, y: 0, width: self.view.bounds.width, height: 121))
        self.headerView.change = {
            self.presenter?.didClickChangeBtn()
        }
        self.headerView.hotwordClick = { (hotword:String) in
            self.presenter?.didSelectHotWord(hotword: hotword)
        }
        
        self.historyHeader = QSHistoryHeaderView(frame: CGRect(x: 0, y: 0, width: self.view.bounds.width, height: 60))
        self.historyHeader.clear = {
            self.presenter?.didClickClearBtn()
        }
        showHistory()
        self.title = "搜索"
        resultTableView = QSSearchResultTable(frame: getFrame(type: .history))
        resultTableView.selectRow = { (indexPath) in
            self.presenter?.didSelectResultRow(indexPath: indexPath)
        }
        autoCompleteTable = QSSearchAutoCompleteTable(frame: getFrame(type: .searching))
        autoCompleteTable.selectRow = { (indexPath) in
            self.presenter?.didSelectAutoCompleteRow(indexPath: indexPath)
        }
    }
}

extension QSSearchViewController:UITableViewDataSource,UITableViewDelegate{
    //MARK: - tableView
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return searchList[section].count
    }
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return searchList.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell:QSHistoryCell? = tableView.qs_dequeueReusableCell(QSHistoryCell.self)
        cell?.backgroundColor = UIColor.white
        cell?.selectionStyle = .none
        cell?.titleLabel.text = searchList[indexPath.section][indexPath.row]
        return cell!
    }
    
    func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        self.headerView.hotwords = self.hotWords
        let headers:[UIView] = [self.headerView,self.historyHeader]
        return headers[section]
    }
    
    func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        let height:[CGFloat] = [141,40]
        return height[section]
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        self.presenter?.didSelectHistoryRow(indexPath: indexPath)
    }
}

extension QSSearchViewController:QSSearchViewProtocol{
    func showNoHotwordsView(){
        
    }
    
    func showHotwordsData(hotwords:[String]){
        self.hotWords = hotwords
        self.tableView.reloadData()
    }
    
    func showNoHistoryView(){
        
    }
    
    func showSearchListData(searchList:[[String]]){
        self.searchList = searchList
        self.tableView.reloadData()
    }
    
    func showBooks(books: [Book],key:String) {
        self.books = books
        self.resultTableView.books = self.books
        showResultTable(key:key)
    }
    
    func showAutoComplete(keywords: [String]) {
        self.autoCompleteTable.books = keywords
        showAutoComplete()
    }
}
