
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
        backView.snp.makeConstraints{ (make) in
            make.edges.equalTo(self)
        }
        
        backView.addSubview(cellTitle)
        cellTitle.snp.makeConstraints{ (make) in
            make.top.equalTo(backView).offset(10)
            make.left.equalTo(backView).offset(10)
        }
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
 
//    override func awakeFromNib() {
//        super.awakeFromNib()
//        
//        let redView = UIView(frame: bounds)
//        redView.backgroundColor = #colorLiteral(red: 1, green: 0, blue: 0, alpha: 1)
//        self.backgroundView = redView
//
//        let blueView = UIView(frame: bounds)
//        blueView.backgroundColor = #colorLiteral(red: 0, green: 0, blue: 1, alpha: 1)
//        self.selectedBackgroundView = blueView
//    }
}


