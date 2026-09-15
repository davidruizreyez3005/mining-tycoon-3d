"use strict";
/**
 * Worker definitions for the mining tycoon game
 */
Object.defineProperty(exports, "__esModule", { value: true });
exports.WORKERS = void 0;
exports.getWorkerById = getWorkerById;
exports.getAvailableWorkers = getAvailableWorkers;
exports.WORKERS = {
    novice_miner: {
        id: 'novice_miner',
        name: 'Novice Miner',
        tier: 1,
        hireCost: 100,
        wagePerMinute: 1,
        efficiency: 0.8,
        skillBonus: { extraction: 0 },
        unlockRequirement: null,
        description: 'Basic worker for simple mining tasks'
    },
    miner: {
        id: 'miner',
        name: 'Miner',
        tier: 2,
        hireCost: 500,
        wagePerMinute: 5,
        efficiency: 1.0,
        skillBonus: { extraction: 0.1 },
        unlockRequirement: { cash: 400 },
        description: 'Experienced miner with better efficiency'
    },
    skilled_miner: {
        id: 'skilled_miner',
        name: 'Skilled Miner',
        tier: 3,
        hireCost: 2000,
        wagePerMinute: 15,
        efficiency: 1.2,
        skillBonus: { extraction: 0.2 },
        unlockRequirement: { cash: 1500, depth: 15 },
        description: 'Highly skilled extraction specialist'
    },
    engineer: {
        id: 'engineer',
        name: 'Mining Engineer',
        tier: 3,
        hireCost: 3000,
        wagePerMinute: 20,
        efficiency: 1.1,
        skillBonus: { processing: 0.25 },
        unlockRequirement: { cash: 2500, machineId: 'crusher_t1' },
        description: 'Specialist in ore processing operations'
    },
    foreman: {
        id: 'foreman',
        name: 'Mine Foreman',
        tier: 4,
        hireCost: 10000,
        wagePerMinute: 50,
        efficiency: 1.3,
        skillBonus: { extraction: 0.15, processing: 0.15, transport: 0.15 },
        unlockRequirement: { cash: 8000, depth: 30 },
        description: 'Supervisor who boosts all operations'
    },
    master_driller: {
        id: 'master_driller',
        name: 'Master Driller',
        tier: 5,
        hireCost: 50000,
        wagePerMinute: 200,
        efficiency: 1.5,
        skillBonus: { extraction: 0.4 },
        unlockRequirement: { cash: 40000, depth: 50 },
        description: 'Legendary driller with unmatched expertise'
    }
};
function getWorkerById(id) {
    return exports.WORKERS[id];
}
function getAvailableWorkers(cash, depth) {
    return Object.values(exports.WORKERS).filter(w => {
        if (!w.unlockRequirement)
            return true;
        if (w.unlockRequirement.cash && cash < w.unlockRequirement.cash) {
            return false;
        }
        if (w.unlockRequirement.depth && depth < w.unlockRequirement.depth) {
            return false;
        }
        return true;
    });
}
//# sourceMappingURL=workers.js.map