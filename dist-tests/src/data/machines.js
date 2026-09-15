"use strict";
/**
 * Machine definitions for the mining tycoon game
 * Data-driven architecture - add new machines without modifying gameplay systems
 */
Object.defineProperty(exports, "__esModule", { value: true });
exports.MACHINES = void 0;
exports.getMachineById = getMachineById;
exports.getMachinesByType = getMachinesByType;
exports.getAvailableMachines = getAvailableMachines;
exports.calculateMachineUpgradeCost = calculateMachineUpgradeCost;
exports.MACHINES = {
    // Extractors
    pickaxe: {
        id: 'pickaxe',
        name: 'Pickaxe',
        type: 'extractor',
        tier: 1,
        baseCost: 0, // Starting equipment
        upgradeCostMultiplier: 2,
        productionRate: 10,
        powerConsumption: 0,
        workerSlots: 1,
        unlockRequirement: null,
        description: 'Basic manual mining tool'
    },
    small_drill: {
        id: 'small_drill',
        name: 'Small Drill',
        type: 'extractor',
        tier: 2,
        baseCost: 500,
        upgradeCostMultiplier: 2.5,
        productionRate: 30,
        powerConsumption: 5,
        workerSlots: 1,
        unlockRequirement: { cash: 500 },
        description: 'Powered drill for faster extraction'
    },
    powered_drill: {
        id: 'powered_drill',
        name: 'Powered Drill',
        type: 'extractor',
        tier: 3,
        baseCost: 2500,
        upgradeCostMultiplier: 3,
        productionRate: 75,
        powerConsumption: 15,
        workerSlots: 2,
        unlockRequirement: { cash: 2000, depth: 10 },
        description: 'Industrial drill with high extraction rate'
    },
    excavator: {
        id: 'excavator',
        name: 'Excavator',
        type: 'extractor',
        tier: 4,
        baseCost: 10000,
        upgradeCostMultiplier: 3.5,
        productionRate: 150,
        powerConsumption: 40,
        workerSlots: 3,
        unlockRequirement: { cash: 8000, depth: 25 },
        description: 'Heavy-duty excavator for大规模 mining'
    },
    advanced_drilling_rig: {
        id: 'advanced_drilling_rig',
        name: 'Advanced Drilling Rig',
        type: 'extractor',
        tier: 5,
        baseCost: 50000,
        upgradeCostMultiplier: 4,
        productionRate: 350,
        powerConsumption: 100,
        workerSlots: 5,
        unlockRequirement: { cash: 40000, depth: 50 },
        description: 'Automated drilling system with maximum efficiency'
    },
    // Processors
    crusher_t1: {
        id: 'crusher_t1',
        name: 'Ore Crusher T1',
        type: 'processor',
        tier: 1,
        baseCost: 1000,
        upgradeCostMultiplier: 2.5,
        productionRate: 50,
        powerConsumption: 10,
        workerSlots: 1,
        unlockRequirement: { cash: 800 },
        description: 'Basic ore processing machine'
    },
    crusher_t2: {
        id: 'crusher_t2',
        name: 'Ore Crusher T2',
        type: 'processor',
        tier: 2,
        baseCost: 5000,
        upgradeCostMultiplier: 3,
        productionRate: 120,
        powerConsumption: 25,
        workerSlots: 2,
        unlockRequirement: { cash: 4000, machineId: 'crusher_t1' },
        description: 'Advanced ore processor for rare materials'
    },
    crusher_t3: {
        id: 'crusher_t3',
        name: 'Ore Crusher T3',
        type: 'processor',
        tier: 3,
        baseCost: 25000,
        upgradeCostMultiplier: 3.5,
        productionRate: 250,
        powerConsumption: 60,
        workerSlots: 3,
        unlockRequirement: { cash: 20000, machineId: 'crusher_t2' },
        description: 'Industrial crusher for precious resources'
    },
    crusher_t4: {
        id: 'crusher_t4',
        name: 'Ore Crusher T4',
        type: 'processor',
        tier: 4,
        baseCost: 100000,
        upgradeCostMultiplier: 4,
        productionRate: 500,
        powerConsumption: 150,
        workerSlots: 5,
        unlockRequirement: { cash: 80000, machineId: 'crusher_t3' },
        description: 'Ultimate processing facility for legendary materials'
    },
    // Transport
    hand_cart: {
        id: 'hand_cart',
        name: 'Hand Cart',
        type: 'transport',
        tier: 1,
        baseCost: 200,
        upgradeCostMultiplier: 2,
        productionRate: 20,
        powerConsumption: 0,
        workerSlots: 1,
        unlockRequirement: { cash: 150 },
        description: 'Manual transport cart'
    },
    ore_cart: {
        id: 'ore_cart',
        name: 'Ore Cart',
        type: 'transport',
        tier: 2,
        baseCost: 1500,
        upgradeCostMultiplier: 2.5,
        productionRate: 60,
        powerConsumption: 5,
        workerSlots: 1,
        unlockRequirement: { cash: 1200 },
        description: 'Rail-based ore transport'
    },
    conveyor_belt: {
        id: 'conveyor_belt',
        name: 'Conveyor Belt',
        type: 'transport',
        tier: 3,
        baseCost: 8000,
        upgradeCostMultiplier: 3,
        productionRate: 150,
        powerConsumption: 20,
        workerSlots: 0,
        unlockRequirement: { cash: 6000, depth: 20 },
        description: 'Automated conveyor system'
    },
    industrial_conveyor: {
        id: 'industrial_conveyor',
        name: 'Industrial Conveyor',
        type: 'transport',
        tier: 4,
        baseCost: 40000,
        upgradeCostMultiplier: 3.5,
        productionRate: 350,
        powerConsumption: 50,
        workerSlots: 0,
        unlockRequirement: { cash: 30000, machineId: 'conveyor_belt' },
        description: 'High-speed industrial conveyor network'
    },
    // Storage
    basic_storage: {
        id: 'basic_storage',
        name: 'Basic Storage',
        type: 'storage',
        tier: 1,
        baseCost: 300,
        upgradeCostMultiplier: 2,
        productionRate: 0,
        powerConsumption: 0,
        workerSlots: 0,
        unlockRequirement: { cash: 200 },
        description: 'Simple storage container (Capacity: 100)'
    },
    large_storage: {
        id: 'large_storage',
        name: 'Large Storage',
        type: 'storage',
        tier: 2,
        baseCost: 2000,
        upgradeCostMultiplier: 2.5,
        productionRate: 0,
        powerConsumption: 0,
        workerSlots: 0,
        unlockRequirement: { cash: 1500 },
        description: 'Expanded storage facility (Capacity: 500)'
    },
    industrial_silo: {
        id: 'industrial_silo',
        name: 'Industrial Silo',
        type: 'storage',
        tier: 3,
        baseCost: 15000,
        upgradeCostMultiplier: 3,
        productionRate: 0,
        powerConsumption: 5,
        workerSlots: 0,
        unlockRequirement: { cash: 12000, depth: 30 },
        description: 'Massive storage silo (Capacity: 2000)'
    }
};
function getMachineById(id) {
    return exports.MACHINES[id];
}
function getMachinesByType(type) {
    return Object.values(exports.MACHINES).filter(m => m.type === type);
}
function getAvailableMachines(cash, depth, ownedMachines) {
    return Object.values(exports.MACHINES).filter(m => {
        if (!m.unlockRequirement)
            return true;
        if (m.unlockRequirement.cash && cash < m.unlockRequirement.cash) {
            return false;
        }
        if (m.unlockRequirement.depth && depth < m.unlockRequirement.depth) {
            return false;
        }
        if (m.unlockRequirement.machineId && !ownedMachines.includes(m.unlockRequirement.machineId)) {
            return false;
        }
        return true;
    });
}
function calculateMachineUpgradeCost(machineId, currentLevel) {
    const machine = getMachineById(machineId);
    if (!machine)
        return 0;
    return Math.floor(machine.baseCost * Math.pow(machine.upgradeCostMultiplier, currentLevel));
}
//# sourceMappingURL=machines.js.map