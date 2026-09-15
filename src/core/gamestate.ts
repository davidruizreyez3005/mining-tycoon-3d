/**
 * Game state management system
 * Centralized state with clear transitions
 */

export type GameStateType = 
  | 'BOOT'
  | 'MENU'
  | 'LOADING'
  | 'PLAYING'
  | 'PAUSED'
  | 'UPGRADING'
  | 'PROCESSING'
  | 'OFFLINE_REWARD'
  | 'PRESTIGE'
  | 'ERROR';

export interface GameState {
  currentState: GameStateType;
  previousState: GameStateType | null;
  canTransitionTo: (target: GameStateType) => boolean;
  transitionTo: (target: GameStateType) => boolean;
}

const VALID_TRANSITIONS: Record<GameStateType, GameStateType[]> = {
  BOOT: ['LOADING', 'ERROR'],
  MENU: ['LOADING', 'ERROR'],
  LOADING: ['PLAYING', 'MENU', 'ERROR'],
  PLAYING: ['PAUSED', 'UPGRADING', 'PROCESSING', 'OFFLINE_REWARD', 'PRESTIGE', 'MENU', 'ERROR'],
  PAUSED: ['PLAYING', 'MENU', 'ERROR'],
  UPGRADING: ['PLAYING', 'PAUSED', 'ERROR'],
  PROCESSING: ['PLAYING', 'PAUSED', 'ERROR'],
  OFFLINE_REWARD: ['PLAYING', 'ERROR'],
  PRESTIGE: ['PLAYING', 'ERROR'],
  ERROR: ['BOOT', 'MENU']
};

export function createGameState(): GameState {
  let currentState: GameStateType = 'BOOT';
  let previousState: GameStateType | null = null;

  return {
    get currentState() {
      return currentState;
    },
    get previousState() {
      return previousState;
    },
    canTransitionTo(target) {
      const validTargets = VALID_TRANSITIONS[currentState];
      return validTargets.includes(target);
    },
    transitionTo(target) {
      if (!this.canTransitionTo(target)) {
        console.warn(`Invalid state transition: ${currentState} -> ${target}`);
        return false;
      }
      previousState = currentState;
      currentState = target;
      console.log(`State transition: ${previousState} -> ${currentState}`);
      return true;
    }
  };
}
