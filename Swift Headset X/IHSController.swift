//
//  IHSController.swift
//  Swift Headset X
//
//  Created by Florian Heller on 14.11.18.
//  Copyright © 2018 Florian Heller. All rights reserved.
//

import UIKit
import CoreBluetooth

class IHSController: NSObject, IHSDeviceDelegate, IHSSensorsDelegate {

	@IBOutlet weak var statusLabel: UILabel!
	@IBOutlet weak var headingLabel: UILabel!
	@IBOutlet weak var viewController: ViewController! //Required to show the viewcontroller to select the right device if multiple are available
	@IBOutlet weak var connectButton: UIButton!
	var ihsDevice:IHSDevice?
	var btManager: CBCentralManager!
	
	override init() {
		super.init()
		btManager = CBCentralManager(delegate: self, queue: nil)
		
	}
	
	@IBAction func connectHeadset(_ sender: UIButton) {
		if sender.title(for: .normal) == "Connect" {
			if btManager.state == .poweredOn { //Check if BT is available and on, will get warnings otherwise
				ihsDevice = IHSDevice.init(deviceDelegate: self)
				ihsDevice?.sensorsDelegate = self
				ihsDevice?.connect()
			}
		}
		else {
			if let ihs = ihsDevice {
				ihs.disconnect()
				ihs.sensorsDelegate = nil
				ihs.deviceDelegate = nil
			}
		}
	}
	
	
	deinit {
		if let ihs = ihsDevice {
			ihs.disconnect()
			ihs.sensorsDelegate = nil
			ihs.deviceDelegate = nil
		}
	}

	//MARK: IHS Device Delegate Methods
	
	func ihsDevice(_ ihs: IHSDevice!, connectionStateChanged connectionState: IHSDeviceConnectionState) {
		var status = ""
		switch connectionState {
		case .none:
			status = "None"
		case .connecting: //The time from when a connection to a headset has been initiated until it is fully connected.
			status = "Connecting"
		case .connected: //The state when the heaset is connected and ready to use.
			status = "Connected"
			connectButton.setTitle("Disconnect", for: .normal)
		case .connectionFailed:
			status = "Failed"
		case .lingering: //If we have not received data from the headset for a while even though we are still conncted. If this state occurs, it is typically a preliminary state to disconnecting.
			status = "Lingering"
		case .discovering: //The framework is looking for available headsets in the near proximity.
			status = "Discovering"
		case .disconnected: //The headset disconnected. Could be because it was turned off or got out of range.
			status = "Disconnected"
			connectButton.setTitle("Connect", for: .normal)
		case .bluetoothOff: // Bluetooth is turned off. It should be turned on in order to connect.
			status = "Bluetooth is Off"
		default:
			status = ""
		}
		print("IHS Connection state changed to " + status)
		statusLabel.text = status
	}
	
	func ihsDeviceFoundAmbiguousDevices(_ ihs: IHSDevice!) {
		ihsDevice?.showSelection(viewController)
	}
	
	//MARK: IHS Sensor Delegate Methods
	
	func ihsDevice(_ ihs: IHSDevice!, fusedHeadingChanged heading: Float) {
		print("Heading \(heading)")
		headingLabel.text = "\(heading)"
	}
}

//MARK: - Core Bluetooth Central Manager Delegate Methods
extension IHSController: CBCentralManagerDelegate {
	func centralManagerDidUpdateState(_ central: CBCentralManager) {
		switch central.state {
			case .unknown:
				print("central.state is .unknown")
			case .resetting:
				print("central.state is .resetting")
			case .unsupported:
				print("central.state is .unsupported")
			case .unauthorized:
				print("central.state is .unauthorized")
			case .poweredOff:
				print("central.state is .poweredOff")
			case .poweredOn:
				print("central.state is .poweredOn")
		}
	}
}
