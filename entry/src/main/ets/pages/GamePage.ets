// pages/GamePage.ets
import { router } from '@kit.ArkUI';
import { GameMode, DifficultyConfig, DifficultyType } from '../model/GameData';
import { DifficultyDialog } from '../components/DifficultyDialog';
import { GridGame } from '../components/GridGame';
import { WheelGame } from '../components/WheelGame';
import { BallGame } from '../components/BallGame';

@Entry
@Component
struct GamePage {
  @State mode: string = 'grid';
  @State showDialog: boolean = true;
  @State config: DifficultyConfig = {
    type: DifficultyType.NUMBER,
    numberCount: 25,
    useRandomColor: false,
    speedLevel: 3
  };
  @State gameKey: number = 0;

  aboutToAppear() {
    const params = router.getParams() as Record<string, Object>;
    if (params && params['mode']) {
      this.mode = params['mode'] as string;
    }
  }

  onConfirm(config: DifficultyConfig) {
    this.config = config;
    this.showDialog = false;
    this.gameKey++;
  }

  goBack() {
    router.back();
  }

  restartGame() {
    this.gameKey++;
    this.showDialog = false;
  }

  build() {
    Stack() {
      if (this.showDialog) {
        Column()
          .width('100%')
          .height('100%')
          .backgroundColor('rgba(0,0,0,0.4)')
          .onClick(() => {})

        DifficultyDialog({
          mode: this.mode === 'grid' ? GameMode.GRID : (this.mode === 'wheel' ? GameMode.WHEEL : GameMode.BALL),
          onConfirm: (config: DifficultyConfig) => {
            this.onConfirm(config);
          }
        })
      } else {
        Column() {
          Row() {
            Text('← 返回')
              .fontSize(16)
              .fontColor('#4A90D9')
              .onClick(() => { this.goBack(); })

            Blank()

            Text(this.mode === 'grid' ? '📐 基础方格' : (this.mode === 'wheel' ? '🎡 转盘模式' : '⚽ 小球运动'))
              .fontSize(18)
              .fontWeight(FontWeight.Bold)
              .fontColor('#2C3E50')

            Blank()

            Row() {
              Text('⚙️')
                .fontSize(20)
                .onClick(() => {
                  this.showDialog = true;
                })
              Text('🔄')
                .fontSize(20)
                .margin({ left: 12 })
                .onClick(() => {
                  this.restartGame();
                })
            }
          }
          .width('95%')
          .margin({ top: 12, bottom: 8 })

          if (this.mode === 'grid') {
            GridGame({
              config: this.config
            })
          } else if (this.mode === 'wheel') {
            WheelGame({
              config: this.config
            })
          } else {
            BallGame({
              config: this.config
            })
          }
        }
        .width('100%')
        .height('100%')
        .backgroundColor('#FFFFFF')
      }
    }
    .width('100%')
    .height('100%')
  }
}