class Drone {
    var droneName: String
    var task: String?
    unowned var assignedModule: StationModule
    weak var missionControlLink: MissionControl?

    init(droneName: String, task: String? = nil, assignedModule: StationModule, missionControlLink: MissionControl? = nil) {
        self.droneName = droneName
        self.task = task
        self.assignedModule = assignedModule
        self.missionControlLink = missionControlLink
    }

    func receiveBag() {
        print("\(droneName) received a bag.")
    }

    func checkAndReportTask() {
        if let task = task {
            print("\(droneName) is currently working on: \(task)")
        } else {
            print("\(droneName) is not currently assigned any task.")
        }
    }
}

class MissionControl {
    weak var spaceStation: OrbitronSpaceStation?

    func connectToSpaceStation(_ spaceStation: OrbitronSpaceStation) {
        self.spaceStation = spaceStation
        print("Connected to OrbitronSpaceStation.")
    }

    func requestControlCenterStatus() {
        guard let controlCenter = spaceStation?.controlCenter else {
            print("No connection to OrbitronSpaceStation or ControlCenter not available.")
            return
        }

        print("Control Center Status:")
        print("Module Name: \(controlCenter.moduleName)")
        print("Is Locked Down: \(controlCenter.isLockedDown)")
    }

    func requestOxygenStatus() {
        guard let lifeSupportSystem = spaceStation?.lifeSupportSystem else {
            print("No connection to OrbitronSpaceStation or LifeSupportSystem not available.")
            return
        }

        print("Life Support System Oxygen Status:")
        lifeSupportSystem.checkOxygenStatus()
    }

    func requestDroneStatus(moduleName: String) {
        guard let spaceStation = spaceStation else {
            print("No connection to OrbitronSpaceStation.")
            return
        }

        if let module = spaceStation.getModuleByName(moduleName) {
            if let drone = module.drone {
                drone.checkAndReportTask()
            } else {
                print("No drone assigned to \(moduleName).")
            }
        } else {
            print("Module \(moduleName) not found in OrbitronSpaceStation.")
        }
    }
}

extension OrbitronSpaceStation {
    func getModuleByName(_ moduleName: String) -> StationModule? {
        switch moduleName {
        case "Control Center":
            return controlCenter
        case "Research Lab":
            return researchLab
        case "Life Support System":
            return lifeSupportSystem
        default:
            return nil
        }
    }
}


class StationModule {
    var moduleName: String
    var drone: Drone?

    init(moduleName: String, drone: Drone? = nil) {
        self.moduleName = moduleName
        self.drone = drone
    }

    func giveDroneABag() {
        if let drone = drone {
            drone.receiveBag()
        } else {
            print("No drone available in \(moduleName).")
        }
    }
}

class ControlCenter: StationModule {
    var isLockedDown: Bool
    var securityCode: String

    init(moduleName: String, drone: Drone? = nil, isLockedDown: Bool, securityCode: String) {
        self.isLockedDown = isLockedDown
        self.securityCode = securityCode
        super.init(moduleName: moduleName, drone: drone)
    }

    func lockdown(password: String) {
        if password == securityCode {
            isLockedDown = true
            print("Control Center is now locked down.")
            printInformationUnderLockdown()
        } else {
            print("Incorrect password. Lockdown failed.")
        }
    }

    private func printInformationUnderLockdown() {
        print("This is sensitive information accessible only under lockdown.")
    }
}

class ResearchLab: StationModule {
    var researchSamples: [String]

    override init(moduleName: String, drone: Drone? = nil) {
        self.researchSamples = []
        super.init(moduleName: moduleName, drone: drone)
    }

    func addResearchSample(_ sample: String) {
        researchSamples.append(sample)
        print("New research sample added: \(sample)")
    }
}

class LifeSupportSystem: StationModule {
    var oxygenLevel: Int

    init(moduleName: String, drone: Drone? = nil, oxygenLevel: Int) {
        self.oxygenLevel = oxygenLevel
        super.init(moduleName: moduleName, drone: drone)
    }

    func checkOxygenStatus() {
        if oxygenLevel >= 21 && oxygenLevel <= 100 {
            print("Oxygen level is within the normal range.")
        } else if oxygenLevel >= 1 && oxygenLevel <= 20 {
            print("Caution: Low oxygen level. Take necessary precautions.")
        } else {
            print("Invalid oxygen level. Please check the sensor.")
        }
    }
}

class OrbitronSpaceStation {
    var controlCenter: ControlCenter
    var researchLab: ResearchLab
    var lifeSupportSystem: LifeSupportSystem
    var drones: [Drone]

    init() {
        
        controlCenter = ControlCenter(moduleName: "Control Center", isLockedDown: false, securityCode: "OrbitronSecure")
        researchLab = ResearchLab(moduleName: "Research Lab")
        lifeSupportSystem = LifeSupportSystem(moduleName: "Life Support System", oxygenLevel: 80)

        let droneControlCenter = Drone(droneName: "ControlCenterDrone", assignedModule: controlCenter)
        let droneResearchLab = Drone(droneName: "ResearchLabDrone", assignedModule: researchLab)
        let droneLifeSupportSystem = Drone(droneName: "LifeSupportDrone", assignedModule: lifeSupportSystem)

        drones = [droneControlCenter, droneResearchLab, droneLifeSupportSystem]

        controlCenter.drone = droneControlCenter
        researchLab.drone = droneResearchLab
        lifeSupportSystem.drone = droneLifeSupportSystem
    }

    func initiateLockdown(password: String) {
        controlCenter.lockdown(password: password)
    }
}

let orbitronStation = OrbitronSpaceStation()

for drone in orbitronStation.drones {
    drone.checkAndReportTask()
}


orbitronStation.initiateLockdown(password: "OrbitronSecure")

let missionControl = MissionControl()

missionControl.connectToSpaceStation(orbitronStation)

missionControl.requestControlCenterStatus()

orbitronStation.controlCenter.drone?.task = "Monitor Communications"
orbitronStation.researchLab.drone?.task = "Analyze Research Samples"
orbitronStation.lifeSupportSystem.drone?.task = "Monitor Oxygen Levels"

for drone in orbitronStation.drones {
    drone.checkAndReportTask()
}

missionControl.requestOxygenStatus()

orbitronStation.initiateLockdown(password: "IncorrectPassword")
orbitronStation.initiateLockdown(password: "OrbitronSecure")



