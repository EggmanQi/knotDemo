//
//  testView.swift
//  knotDemo
//
//  Created by P on 2022/5/17.
//

import UIKit
import SwiftUI

struct my_model {
    var id: Int
    var title: String
    
    //WARNING: 覆写了 init, 打个 log
    init(_ id: Int, _ title: String) {
        self.id = id
        self.title = title
        
//        NSLog("----Index: %d", id)
    }
}

private class MY_DATA: NSObject, UITableViewDataSource {
    enum STATE {
        case Loading
        case Loaded
    }
    private var row_num = 0
    private(set) var array = [my_model]()
    private var state: STATE = .Loading {
        didSet {
            state_change?(state)
        }
    }
    private var state_change: ((STATE) -> Void)?

    init(num: Int, tv: UITableView, stateDidChange: ((STATE) -> Void)?) {
        self.row_num = num
        self.state_change = stateDidChange
        super.init()

        tv.register(bad_cell.self, forCellReuseIdentifier: String(describing: bad_cell.self))
        
        //WARNING: cell id 不一致
        tv.register(bade_cell__2.self, forCellReuseIdentifier: String(describing: bade_cell__2.self))
    }
    
    subscript(_ indexPath: IndexPath) -> my_model {
        array[indexPath.row]
    }
    
    //WARNING: 改造为通用方法
    func make_data(startIndex: Int, endIndex: Int) {
        state = .Loading
        
        DispatchQueue.global().asyncAfter(deadline: .now() + 0.5){
            let arr : [my_model] = (startIndex..<endIndex).map {
                my_model.init($0,
                              self.get_magic_value( index:$0 ).description)
            }
            
            if self.array.isEmpty {
                self.array = arr
            }else  {
                self.array.append(contentsOf: arr)
            }
            
            //WARNING: row_num 没有更新
            self.row_num = self.array.count
//            self.array = (0..<self.row_num).map {
//                my_model.init($0, self.get_magic_value( index:$0 ).description)
//                my_model.init(
//                    id: $0,
//                    title: self.get_magic_value( index:$0 ).description
//                )
//            }
            DispatchQueue.main.sync {
                self.state = .Loaded
            }
        }
    }

    
    ///Get a magic value for a specified index
    ///    - Parameter index: An index, should be greater than 0
    ///    - Note:
    ///    f(n)={
    ///    1, n = 1,2,3;
    ///    f(n-1) + f(n-2) + f(n-3), n > 3 }
    ///    - Returns: The magic value
    
    //WARNING: 加载更多会导致 CPU 100%
    // Q : 递归会导致 stack overflow, 会有很多重复计算
    //      A --> 动态规划思路
    // Q : 出现 Int 越界
    //      A --> 使用 &(操作符) 来避免值溢出
    //      Suggest: 极值后 show MAX 并不能再刷新, 要看实际情况
    
    
    private func get_magic_value_fix(index: Int) -> Int {
        if index <= 0 {
            return 0
        }
        if index <= 3 {
            return 1
        }
        
        var w=1, a=1, s=1, d=0
        for _ in 4...index {
            d = w &+ a &+ s
            w=a
            a=s
            s=d
        }
        return d
    }
    
    private func get_magic_value(index: Int) -> Int {
        return get_magic_value_fix(index: index)
//        switch index {
//        case 1:
//            return 1
//        case 2:
//            return 1
//        case 3:
//            return 1
//        default:
//            if index < 0 { return 0 }
//            return get_magic_value(index: index - 3)
//            + get_magic_value(index: index - 2)
//            + get_magic_value(index: index - 1)
//        }
    }
    
    private func update_ui(elems: [my_model]) {
        self.array.append(contentsOf: elems)
        //WARNING: 没有切换回主线程
        DispatchQueue.main.sync {
            self.state = .Loaded
        }
    }
    
    func tableView(_ tableView: UITableView,
                   numberOfRowsInSection section: Int) -> Int {
        array.count + 1
    }
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        //WARNING:
        if indexPath.row == array.count {
            guard let cell = tableView.dequeueReusableCell(withIdentifier: String(describing: bade_cell__2.self),
                                                           for: indexPath)
                    as? bade_cell__2
            else {
                fatalError()
            }
            cell.block = {
                self.make_data(startIndex: self.row_num, endIndex: self.row_num+20)
//                self.state = .Loading
//                DispatchQueue.global().asyncAfter(deadline: .now() + 0.5) {
//                    let s = (self.row_num..<self.row_num+20).map {
//                        my_model.init($0, self.get_magic_value( index:$0 ).description)
////                        my_model(
////                            id: $0,
////                            title:self.get_magic_value(index: $0).description)
//                    }
//
//                    self.update_ui(elems: s)
//                }
            }
            cell.btn.isHidden = self.state == .Loading
            return cell
        }else {
            guard let cell = tableView.dequeueReusableCell(withIdentifier: String(describing:
                                                                                    bad_cell.self), for: indexPath)
                    as? bad_cell
            else {
                fatalError()
            }
            cell.k_label.text = indexPath.row.description
            cell.v_label.text = self[indexPath].title // MARK: 要有越界检查比较安全
            return cell
        }
    }
}
// MARK: - ViewController
class bad_bass_vc: UIViewController {
    override func viewDidLoad() {
        requiredScreenViewTrack()
    }
    
    func requiredScreenViewTrack() {
        // some code
    }
}

final class bad_vc: bad_bass_vc {
    private let tv = UITableView()
    private lazy var ds = MY_DATA(num: 30, tv: tv) { s in
        self.reload(s)
    }
    private let loader: UIActivityIndicatorView = {
        let v = UIActivityIndicatorView()
        v.color = .systemRed
        v.style = .large
        return v
    }()
    
    override func viewDidLoad() {
        
        view.backgroundColor = UIColor.systemFill

        make_ui()
        ds.make_data(startIndex: 0, endIndex: 20)
    }
    
    override func viewSafeAreaInsetsDidChange() {
        super.viewSafeAreaInsetsDidChange()
        var insets = view.safeAreaInsets
        insets.top = 0
        tv.contentInset = insets
    }
    
    func make_ui() {
        
        tv.dataSource = ds
        
        view.addSubview(tv)
        
        NSLog("%@", view)
        
        //WARNING: 布局有问题
        tv.translatesAutoresizingMaskIntoConstraints = false
//        if #available(iOS 11, *) {
            tv.contentInsetAdjustmentBehavior = .never
//        }
        NSLayoutConstraint.activate(
            [tv.leftAnchor.constraint(equalTo: view.leftAnchor),
             tv.trailingAnchor.constraint(equalTo: view.trailingAnchor),
             tv.topAnchor.constraint(equalTo: view.topAnchor),
             tv.bottomAnchor.constraint(equalTo: view.bottomAnchor),])
    }
    
    private func reload(_ s: MY_DATA.STATE) {
        if s == MY_DATA.STATE.Loaded {
            tv.isUserInteractionEnabled = true
            loader.removeFromSuperview()
        } else if s == MY_DATA.STATE.Loading {
            tv.isUserInteractionEnabled = false
            view.addSubview(loader)
            loader.translatesAutoresizingMaskIntoConstraints = false
            NSLayoutConstraint.activate(
                [loader.centerXAnchor.constraint(equalTo:view.centerXAnchor),
                 loader.centerYAnchor.constraint(equalTo: view.centerYAnchor)]
            )
            loader.startAnimating()
        }
        tv.reloadData()
    }
}
// MARK: - Cells
// Maybe I will use this later, maybe
private class my_bass_cell: UITableViewCell {}
private final class bad_cell: my_bass_cell {
    let k_label: UILabel = {
        let label = UILabel()
        label.translatesAutoresizingMaskIntoConstraints = false
        label.font = UIFont.preferredFont(forTextStyle: .title1)
        return label
    }()
    
    let v_label: UILabel = {
        let label = UILabel()
        label.translatesAutoresizingMaskIntoConstraints = false
        label.font = UIFont.preferredFont(forTextStyle: .callout)
        return label
    }()
    
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style,
                   reuseIdentifier: reuseIdentifier)
        make_ui()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    private func make_ui() {
        let views = [k_label, v_label]
        for i in 0..<views.count {
            //WARNING: UI 元素与加载的对象不一致
            contentView.addSubview(views[i])
        }
        
//        contentView.backgroundColor = UIColor.init(
//            red: CGFloat(arc4random()%255)/255.0,
//            green: CGFloat(arc4random()%255)/255.0,
//            blue: CGFloat(arc4random()%255)/255.0,
//            alpha: 0.6)
        
        NSLayoutConstraint.activate([k_label.topAnchor.constraint(equalTo: contentView.topAnchor,
                                                                  constant: 8),
                                     k_label.leftAnchor.constraint(equalTo: contentView.leftAnchor,
                                                                   constant: 16),
                                     k_label.bottomAnchor.constraint(equalTo: contentView.bottomAnchor, constant: -8)])
        NSLayoutConstraint.activate([v_label.leftAnchor.constraint(equalTo: k_label.rightAnchor,
                                                                   constant: 8),
                                     v_label.rightAnchor.constraint(lessThanOrEqualTo: contentView.rightAnchor),
                                     v_label.centerYAnchor.constraint(equalTo: k_label.centerYAnchor)])
    }
}

private final class bade_cell__2: my_bass_cell {
    var block: (() -> Void)?
    
    let btn: UIButton = {
        let b = UIButton()
        b.translatesAutoresizingMaskIntoConstraints = false
        b.setTitle("tap to load more", for: .normal)
        b.setTitleColor(.systemGreen, for: .normal)
        b.addTarget(self, action: #selector(sel), for: .touchUpInside)
        return b
    }()
    
    @objc func sel() {
        block?()
    }
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style,
                   reuseIdentifier: reuseIdentifier)
        make_ui()
    }
    required init?(coder: NSCoder) { fatalError("init(coder:) has not been implemented") }
    private func make_ui() {
        //WARNING: btn 要加载 contentVIew
        contentView.addSubview(btn)
        NSLayoutConstraint.activate([btn.topAnchor.constraint(equalTo: contentView.topAnchor),
                                     btn.leftAnchor.constraint(equalTo: contentView.leftAnchor),
                                     btn.bottomAnchor.constraint(equalTo: contentView.bottomAnchor),
                                     btn.rightAnchor.constraint(equalTo: contentView.rightAnchor)])
    }
}
