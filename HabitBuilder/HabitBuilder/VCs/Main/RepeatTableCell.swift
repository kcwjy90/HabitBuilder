
import UIKit

//:MARK Cells
class RepeatTableCell: UITableViewCell {
    
    lazy var backView: UIView = {
        let v = UIView()
        return v
    }()
    
    lazy var cellTitle: UILabel = {
        let v = UILabel()
        return v
    }()
    
    
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier )
        
        addSubview(backView)
        backView.addSubview(cellTitle)
        
        backView.snp.makeConstraints{ (make) in
            make.edges.equalTo(self)
        }
        
        cellTitle.snp.makeConstraints{ (make) in
            make.top.equalTo(backView).offset(10)
            make.left.equalTo(backView).offset(10)
        }
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
}


