/**
 * Worker definitions for the mining tycoon game
 */
export interface WorkerDef {
    id: string;
    name: string;
    tier: number;
    hireCost: number;
    wagePerMinute: number;
    efficiency: number;
    skillBonus: {
        extraction?: number;
        processing?: number;
        transport?: number;
    };
    unlockRequirement: {
        cash?: number;
        depth?: number;
        prestige?: number;
        machineId?: string;
    } | null;
    description: string;
}
export declare const WORKERS: Record<string, WorkerDef>;
export declare function getWorkerById(id: string): WorkerDef | undefined;
export declare function getAvailableWorkers(cash: number, depth: number): WorkerDef[];
//# sourceMappingURL=workers.d.ts.map