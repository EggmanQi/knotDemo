## 代码存在哪些问题的解决和优化

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




## 翻译题

功能用例

作为新郎, 想在婚礼主页上添加关于婚礼的详细信息.

目标

* There is an edit button at the top of the Our Wedding section that takes me to an edit view via the expand animation
  1. edit 按钮是否存在, 需要新建的话是 icon or text ?
  2. expand 动画效果要和 UI 对齐, 复杂的效果需要导出 demo 视频来确保理解一致
  3. coding 时要考虑要更新后需要刷新的数据和页面
* I can edit the fields in the Our Wedding section
  1. 不同类型的输入框有默认的 placeholder
  2. 需要补充交互例.
     1. 可以多行的输入框是否会导致页面高度超过一个屏幕? 
     2. 底部点击输入时是要整个页面上移? 还是通过弹窗来输入? 
  3. 两张效果图顶部的 photo 高度似乎不一致, 和 UI 确认不同 size 图片的处理
     1. 是否可以多张图片?
  4. 小屏机上非常可能不够位置放满组件, 整个页面要用 scrollView 来处理, 要和 UI & Android 统一交互和方案
  
* Date / Time pickers are the standard ones
  1. 日期范围要定下
  2. 是否有和其他数据关联的规则? 比如最长只能设定为未来的 3 年?
  
* I cannot add new sections, but any sections I've added from desktop are visible and editable
  1. desktop 指什么?
  2. 我理解是可以点击 edit 的页面, 该页面全部元素可以编辑
     1. 需要和后端沟通数据更新逻辑
     
* There is a "reception is the same as venue" checkbox below the reception venue
  1. 未输入时需要 disable checkbox
  2. 勾选后, 取消勾选, reception Venue 和 reception Address 要显示相同内容
  3. 是否有地图选择器?
  
* If I tap it, the ceremony / reception fields slide up into "Venue Name" and "Venue Address"
  1. 注意两个输入框的数据迁移规则
  2. 是否需要动画效果?
  
* Try to autocomplete the ceremony and reception venue name / address from the local database
  1. 确认数据库规则, 如果使用者可以创建多个 Wedding, 这里是否需要选择页面?
  
* when you hit the cancel button, any changes you've made do not save and I go back to the view page via the fold animation
  1. 是否需要提示用户?
  2. 需要的话, 要确认提示的 UI
* when you hit the done button, changes you've made save
  1. 确认完成后要跳转/回退的页面
  2. 确认数据更新逻辑
  3. 页面更新是否需要动画?
