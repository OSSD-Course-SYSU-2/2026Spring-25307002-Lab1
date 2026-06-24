// components/GridGame.ets
import { router } from '@kit.ArkUI';
import { GameMode, DifficultyType, GameRecord, DifficultyConfig } from '../model/GameData';
import { StorageUtil } from '../utils/StorageUtil';

@Component
export struct GridGame {
  @State numbers: number[] = [];
  @State clicked: boolean[] = [];
  @State currentTarget: number = 1;
  @State elapsed: number = 0;
  @State isFinished: boolean = false;
  @State isRunning: boolean = false;
  @State timerId: number = -1;

  private config: DifficultyConfig = { type: DifficultyType.NUMBER, numberCount: 25, useRandomColor: false, speedLevel: 3 };
  private startTime: number = 0;

  aboutToAppear() {
    this.initGame();
  }

  aboutToDisappear() {
    if (this.timerId !== -1) {
      clearInterval(this.timerId);
    }
  }

  initGame() {
    const total = this.config.numberCount;
    this.numbers = [];
    for (let i = 1; i <= total; i++) {
      this.numbers.push(i);
    }
    for (let i = this.numbers.length - 1; i > 0; i--) {
      const j = Math.floor(Math.random() * (i + 1));
      let temp = this.numbers[i];
      this.numbers[i] = this.numbers[j];
      this.numbers[j] = temp;
    }
    this.clicked = new Array(total).fill(false);
    this.currentTarget = 1;
    this.elapsed = 0;
    this.isFinished = false;
    this.isRunning = true;
    this.startTime = Date.now();

    if (this.timerId !== -1) clearInterval(this.timerId);
    this.timerId = setInterval(() => {
      if (this.isRunning && !this.isFinished) {
        this.elapsed = Date.now() - this.startTime;
      }
    }, 50);
  }

  getColor(index: number): string {
    if (this.clicked[index]) return '#E8F5E9';
    if (this.config.useRandomColor) {
      const colors = ['#FF6B6B', '#4ECDC4', '#45B7D1', '#FFA07A', '#98D8C8',
        '#F7DC6F', '#BB8FCE', '#85C1E9', '#F8C471', '#82E0AA'];
      return colors[index % colors.length];
    }
    return '#4A90D9';
  }

  getTextColor(index: number): string {
    if (this.clicked[index]) return '#27AE60';
    return '#FFFFFF';
  }

  getGridTemplate(): string {
    const total = this.config.numberCount;
    const cols = Math.ceil(Math.sqrt(total));
    let template = '';
    for (let i = 0; i < cols; i++) template += '1fr ';
    return template;
  }

  getRows(): number {
    const total = this.config.numberCount;
    const cols = Math.ceil(Math.sqrt(total));
    return Math.ceil(total / cols);
  }

  handleClick(index: number) {
    if (this.isFinished || !this.isRunning) return;
    if (this.clicked[index]) return;

    const num = this.numbers[index];
    if (num === this.currentTarget) {
      this.clicked[index] = true;
      this.currentTarget++;

      if (this.currentTarget > this.config.numberCount) {
        this.isFinished = true;
        this.isRunning = false;
        if (this.timerId !== -1) {
          clearInterval(this.timerId);
        }
        const finalTime = Date.now() - this.startTime;
        this.elapsed = finalTime;
        this.saveRecord(finalTime);
        this.showResult(true);
      }
    }
  }

  async saveRecord(time: number) {
    const record = new GameRecord(
      GameMode.GRID,
      this.config.type,
      this.config.numberCount,
      this.config.useRandomColor,
      this.config.speedLevel,
      time,
      new Date().toLocaleString(),
      false
    );
    await StorageUtil.saveRecord(record);
  }

  showResult(isWin: boolean) {
    const timeStr = (this.elapsed / 1000).toFixed(2);
    router.pushUrl({
      url: 'pages/ResultPage',
      params: {
        isWin: isWin,
        time: this.elapsed,
        timeStr: timeStr,
        score: this.currentTarget - 1,
        total: this.config.numberCount,
        mode: '基础方格'
      }
    });
  }

  build() {
    Column() {
      Row() {
        Text('⏱ ' + (this.elapsed / 1000).toFixed(2) + 's')
          .fontSize(20)
          .fontWeight(FontWeight.Bold)
          .fontColor('#2C3E50')

        Blank()

        Text('进度：' + (this.currentTarget - 1) + '/' + this.config.numberCount)
          .fontSize(16)
          .fontColor('#7F8C8D')
      }
      .width('95%')
      .margin({ bottom: 10 })

      Grid() {
        ForEach(this.numbers, (num: number, index: number) => {
          GridItem() {
            Column() {
              if (!this.clicked[index]) {
                Text(num.toString())
                  .fontSize(22)
                  .fontWeight(FontWeight.Bold)
                  .fontColor(this.getTextColor(index))
              } else {
                Text('✓')
                  .fontSize(28)
                  .fontWeight(FontWeight.Bold)
                  .fontColor('#27AE60')
              }
            }
            .width('100%')
            .height('100%')
            .borderRadius(12)
            .backgroundColor(this.getColor(index))
            .justifyContent(FlexAlign.Center)
            .alignItems(HorizontalAlign.Center)
            .shadow({ radius: 4, color: '#00000020' })
            .onClick(() => {
              this.handleClick(index);
            })
          }
        }, (num: number, index: number) => index.toString())
      }
      .columnsTemplate(this.getGridTemplate())
      .rowsTemplate('1fr '.repeat(this.getRows()))
      .width('92%')
      .height('70%')
      .backgroundColor('#F0F4F8')
      .borderRadius(16)
      .padding(8)
    }
    .width('100%')
    .height('100%')
    .justifyContent(FlexAlign.Start)
  }
}