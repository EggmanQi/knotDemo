##### 代码存在哪些问题的解决和优化

1. 启动后不显示内容
   * 相关 View 的translatesAutoresizingMaskIntoConstraints 没有设定为 false, 手动指定的约束不生效
   * 运行时有警告的对象 translatesAutoresizingMaskIntoConstraints = false
2. 启动后崩溃
   * 原因: UITableView 中注册 cell-id 与使用时的 cell-id 不相同
   * 解决: 修正 bade_cell__2 注册时的 id
   * 一些想法: 我习惯会把注册和获取(dequeueReusableCell)放在 cell 中, 从而把 id 限制为 String(describing: self), 减少使用问题
3. 加载下一页 cpu 100% 占用
   * 原因: 典型的斐波那契数列问题, get_magic_value 的递归调用会产生大量的函数调用栈和重复计算, 从而占用大量线程资源和 CPU 资源
   * 解决: 看 get_magic_value_fix 方法, 通过滚动窗口的方式减少重复计算, 避免递归
4. 加载更多 crash
   * 原因: magic value 数值越界
   * 解决: 使用 & 溢出运算符来做保护计算
   * 建议: 可以考虑 Double 来更准确显示大数, 或检测到极值后就不再增加数据并禁止 load more, 看实际情况
5. bad_cell UI 布局有问题
   * 原因: label 加入的父视图不是 cell.contentView, 与 layout 指定对象不一致
   * 解决: 通过 cell.contentView 来 addSubView
6. bade_cell__2 的 btn 按钮点击无响应
   * 原因: btn 没有加入到 cell.contentView 中
   * 解决: btn 加入到 cell.contentView
7. 点击“tap to load more”, 页面显示数据错乱
   * 原因: row_num 没有在 self.array 更新后更新
   * 解决: 修改了 make_data 方法, 可以传入参数 startIndex 和 endIndex, 并在更新完 self.array 后更新 row_num, bade_cell__2 的 block 中代码替换为 make_data
8. update_ui 中, 修改 .state 的方法没有切换到主线程
   * 解决: 通过 gcd 切换到主线程, 防止 UI 没有在主线程更新导致 crash
9. cellForRowAt 方法中, 通过 self[indexPath] 来取得数据
   * 建议: 语法上看是取 MY_DATA 中的 array, 这种省略写法不太好理解, 同时最好加上越界访问保护
10. 视频中列表范围是覆盖全屏幕, 我在创建项目时选择了 SwiftUI, 通过 UIViewControllerRepresentable 来显示 UIKit 内容, 视图自动适配了 safeArea, 我觉得是个优化点所以没有还原效果
