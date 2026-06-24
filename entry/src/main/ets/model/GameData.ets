// model/GameData.ets
export enum GameMode {
  GRID = '基础方格',
  WHEEL = '转盘模式',
  BALL = '小球运动'
}

export enum DifficultyType {
  NUMBER = '数字模式',
  COLOR = '颜色模式',
  SPEED = '速度模式'
}

export interface DifficultyConfig {
  type: DifficultyType;
  numberCount: number;
  useRandomColor: boolean;
  speedLevel: number;
}

export class GameRecord {
  mode: GameMode;
  difficultyType: DifficultyType;
  numberCount: number;
  useRandomColor: boolean;
  speedLevel: number;
  time: number;
  date: string;
  isBest: boolean;

  constructor(
    mode: GameMode,
    difficultyType: DifficultyType,
    numberCount: number,
    useRandomColor: boolean,
    speedLevel: number,
    time: number,
    date: string,
    isBest: boolean
  ) {
    this.mode = mode;
    this.difficultyType = difficultyType;
    this.numberCount = numberCount;
    this.useRandomColor = useRandomColor;
    this.speedLevel = speedLevel;
    this.time = time;
    this.date = date;
    this.isBest = isBest;
  }
}