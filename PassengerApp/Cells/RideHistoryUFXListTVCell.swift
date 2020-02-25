//
//  RideHistoryUFXListTVCell.swift
//  PassengerApp
//
//  Created by ADMIN on 24/10/17.
//  Copyright © 2017 V3Cube. All rights reserved.
//

import UIKit

class RideHistoryUFXListTVCell: UITableViewCell {
    @IBOutlet weak var bookingNoLbl: MyLabel!
    @IBOutlet weak var rideDateLbl: MyLabel!
    @IBOutlet weak var rideTypeLbl: MyLabel!
    @IBOutlet weak var pickUpLocHLbl: MyLabel!
    @IBOutlet weak var pickUpLocVLbl: MyLabel!
    @IBOutlet weak var statusVLbl: MyLabel!
    @IBOutlet weak var statusView: UIView!
    @IBOutlet weak var dataView: UIView!
    @IBOutlet weak var reScheduleBookingBtn: MyButton!
    @IBOutlet weak var cancelBookingBtn: MyButton!
    @IBOutlet weak var statusAreaViewHeight: NSLayoutConstraint!
    @IBOutlet weak var vTypeNameLbl: MyLabel!
    @IBOutlet weak var btnContainerView: UIStackView!
    @IBOutlet weak var rentalPackageNameLbl: MyLabel!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }
    
    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
        
        // Configure the view for the selected state
    }
}
