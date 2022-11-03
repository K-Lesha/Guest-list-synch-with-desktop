//
//  GuestTableViewCell.swift
//  Guest list synch with desktop
//
//  Created by Алексей Коваленко on 02.11.2022.
//

import UIKit

protocol GuestTableViewCellProtocol {
    var presenter: GuestlistPresenterProtocol! {get set}
}

class GuestTableViewCell: UITableViewCell, GuestTableViewCellProtocol {

    var presenter: GuestlistPresenterProtocol!
    
    var guestEntity: GuestEntity! {
        didSet {
            self.guestNameAndSurnameLabel.text = guestEntity.guestName + " " + guestEntity.guestSurname
        }
    }
    
    //MARK: - OUTLETS
    internal var guestNameAndSurnameLabel: UILabel!
//    internal var accessLevelLabel: UILabel!
//    internal var guestImageView: UIImageView!
//    internal var checkGuestsInButton: UIButton!

    //MARK: - INIT
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        setupViews()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    //MARK: - METHODS
    func setupViews() {
        //setup@eventNameLabel
        guestNameAndSurnameLabel = UILabel()
        contentView.addSubview(guestNameAndSurnameLabel)
        guestNameAndSurnameLabel.textColor = .black
        guestNameAndSurnameLabel.numberOfLines = 1
        guestNameAndSurnameLabel.font = Appearance.titlesFont
        //constraints@eventNameLabel
        guestNameAndSurnameLabel.translatesAutoresizingMaskIntoConstraints = false
        guestNameAndSurnameLabel.topAnchor.constraint(equalTo: self.contentView.topAnchor, constant: 5).isActive = true
        guestNameAndSurnameLabel.leftAnchor.constraint(equalTo: self.contentView.leftAnchor, constant: 5).isActive = true
        guestNameAndSurnameLabel.widthAnchor.constraint(equalTo: self.contentView.widthAnchor, constant: -100).isActive = true
        guestNameAndSurnameLabel.heightAnchor.constraint(equalToConstant: 50).isActive = true
        
        
        
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

    }

}
