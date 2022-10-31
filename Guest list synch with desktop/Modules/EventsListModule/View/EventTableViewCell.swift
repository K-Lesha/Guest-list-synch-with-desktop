//
//  EventTableViewCell.swift
//  Guest list synch with desktop
//
//  Created by Алексей Коваленко on 25.10.2022.
//

import UIKit

protocol EventTableViewCellProtocol {
    //Methods
    func showGuestListForEvent()
}

class EventTableViewCell: UITableViewCell {
    
    //MARK: - OUTLETS
    internal var eventNameLabel: UILabel!
    internal var venueLabel: UILabel!
    internal var eventDateAndTimeLabel: UILabel!
    internal var totalGuestsLabel: UILabel!
    internal var guestsAmountLabel: UILabel!
    
    
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
        //setup@contenView
        contentView.backgroundColor = .white
        
        //setup@eventNameLabel
        eventNameLabel = UILabel()
        contentView.addSubview(eventNameLabel)
        eventNameLabel.textColor = .black
        eventNameLabel.numberOfLines = 0
        eventNameLabel.font = UIFont(name: Appearance.buttomsFont.fontName, size: 40)
        //constraints@eventNameLabel
        eventNameLabel.translatesAutoresizingMaskIntoConstraints = false
        eventNameLabel.topAnchor.constraint(equalTo: self.contentView.topAnchor, constant: 5).isActive = true
        eventNameLabel.leftAnchor.constraint(equalTo: self.contentView.leftAnchor, constant: 5).isActive = true
        eventNameLabel.widthAnchor.constraint(equalTo: self.contentView.widthAnchor, constant: -80).isActive = true
        eventNameLabel.heightAnchor.constraint(equalToConstant: 50).isActive = true
        
        //setup@venueLabel
        venueLabel = UILabel()
        contentView.addSubview(venueLabel)
        venueLabel.textColor = .darkGray
        venueLabel.numberOfLines = 1
        venueLabel.font = UIFont(name: Appearance.buttomsFont.fontName, size: 15)
        //constraints@venueLabel
        venueLabel.translatesAutoresizingMaskIntoConstraints = false
        venueLabel.topAnchor.constraint(equalTo: self.eventNameLabel.bottomAnchor, constant: 5).isActive = true
        venueLabel.leftAnchor.constraint(equalTo: self.eventNameLabel.leftAnchor, constant: 0).isActive = true
        venueLabel.widthAnchor.constraint(equalTo: self.eventNameLabel.widthAnchor, constant: 0).isActive = true
        venueLabel.heightAnchor.constraint(equalToConstant: 15).isActive = true

        //setup@eventDateAndTimeLabel
        eventDateAndTimeLabel = UILabel()
        contentView.addSubview(eventDateAndTimeLabel)
        eventDateAndTimeLabel.textColor = .darkGray
        eventDateAndTimeLabel.numberOfLines = 1
        eventDateAndTimeLabel.font = UIFont(name: Appearance.buttomsFont.fontName, size: 15)
        //constraints@eventDateAndTimeLabel
        eventDateAndTimeLabel.translatesAutoresizingMaskIntoConstraints = false
        eventDateAndTimeLabel.topAnchor.constraint(equalTo: self.venueLabel.bottomAnchor, constant: 5).isActive = true
        eventDateAndTimeLabel.leftAnchor.constraint(equalTo: self.venueLabel.leftAnchor, constant: 0).isActive = true
        eventDateAndTimeLabel.widthAnchor.constraint(equalTo: self.venueLabel.widthAnchor, constant: 0).isActive = true
        eventDateAndTimeLabel.heightAnchor.constraint(equalToConstant: 15).isActive = true
        contentView.bottomAnchor.constraint(equalTo: eventDateAndTimeLabel.bottomAnchor, constant: 5).isActive = true
        
        //setup@guestsAmountLabel
        guestsAmountLabel = UILabel()
        contentView.addSubview(guestsAmountLabel)
        guestsAmountLabel.textColor = .black
        guestsAmountLabel.numberOfLines = 3
        guestsAmountLabel.font = UIFont(name: Appearance.buttomsFont.fontName, size: 30)
        //constraints@guestsAmountLabel
        guestsAmountLabel.translatesAutoresizingMaskIntoConstraints = false
        guestsAmountLabel.topAnchor.constraint(equalTo: self.eventNameLabel.topAnchor, constant: 0).isActive = true
        guestsAmountLabel.leftAnchor.constraint(equalTo: self.venueLabel.rightAnchor, constant: 10).isActive = true
        guestsAmountLabel.widthAnchor.constraint(equalToConstant: 70).isActive = true
        guestsAmountLabel.heightAnchor.constraint(equalTo: eventNameLabel.heightAnchor, constant: -20).isActive = true
        
        //setup@totalGuestsLabel
        totalGuestsLabel = UILabel()
        contentView.addSubview(totalGuestsLabel)
        totalGuestsLabel.textColor = .black
        totalGuestsLabel.text = "guests"
        totalGuestsLabel.numberOfLines = 1
        totalGuestsLabel.font = UIFont(name: Appearance.buttomsFont.fontName, size: 15)
        //constraints@totalGuestsLabel
        totalGuestsLabel.translatesAutoresizingMaskIntoConstraints = false
        totalGuestsLabel.topAnchor.constraint(equalTo: self.guestsAmountLabel.bottomAnchor, constant: 3).isActive = true
        totalGuestsLabel.leftAnchor.constraint(equalTo: self.guestsAmountLabel.leftAnchor, constant: 0).isActive = true
        totalGuestsLabel.widthAnchor.constraint(equalTo: guestsAmountLabel.widthAnchor).isActive = true
        totalGuestsLabel.heightAnchor.constraint(equalTo: venueLabel.heightAnchor, constant: 5).isActive = true
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
    }
}
