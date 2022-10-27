//
//  EventTableViewCell.swift
//  Guest list synch with desktop
//
//  Created by Алексей Коваленко on 25.10.2022.
//

import UIKit

class EventTableViewCell: UITableViewCell {
    
    var eventNameLabel: UILabel!
    
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        setupViews()

    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func setupViews() {
        //setup@eventNameLabel
        eventNameLabel = UILabel()
        contentView.addSubview(eventNameLabel)
        eventNameLabel.backgroundColor = .clear
        eventNameLabel.font = UIFont(name: Appearance.buttomsFont.fontName, size: 30)
//        Appearance.buttomsFont
        //constraints@eventNameLabel
        eventNameLabel.translatesAutoresizingMaskIntoConstraints = false
        eventNameLabel.centerYAnchor.constraint(equalTo: self.contentView.centerYAnchor).isActive = true
        eventNameLabel.centerXAnchor.constraint(equalTo: self.contentView.centerXAnchor).isActive = true
        eventNameLabel.widthAnchor.constraint(equalTo: self.contentView.widthAnchor).isActive = true
        eventNameLabel.heightAnchor.constraint(equalTo: self.contentView.heightAnchor).isActive = true

    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }

}
