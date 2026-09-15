/**
 * Game state management system
 * Centralized state with clear transitions
 */
export type GameStateType = 'BOOT' | 'MENU' | 'LOADING' | 'PLAYING' | 'PAUSED' | 'UPGRADING' | 'PROCESSING' | 'OFFLINE_REWARD' | 'PRESTIGE' | 'ERROR';
export interface GameState {
    currentState: GameStateType;
    previousState: GameStateType | null;
    canTransitionTo: (target: GameStateType) => boolean;
    transitionTo: (target: GameStateType) => boolean;
}
export declare function createGameState(): GameState;
//# sourceMappingURL=gamestate.d.ts.map