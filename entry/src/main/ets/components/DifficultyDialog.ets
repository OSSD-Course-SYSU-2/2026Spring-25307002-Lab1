// components/DifficultyDialog.ets
import { DifficultyType, DifficultyConfig, GameMode } from '../model/GameData';

@Component
export struct DifficultyDialog {
  @State selectedType: DifficultyType = DifficultyType.NUMBER;
  @State numberCount: number = 25;
  @State useRandomColor: boolean = false;
  @State speedLevel: number = 3;
  private mode: GameMode = GameMode.GRID;
  private onConfirm: (config: DifficultyConfig) => void = () => {};

  aboutToAppear() {
    if (this.mode === GameMode.WHEEL || this.mode === GameMode.BALL) {
      this.selectedType = DifficultyType.SPEED;
    }
  }

  confirm() {
    this.onConfirm({
      type: this.selectedType,
      numberCount: this.numberCount,
      useRandomColor: this.useRandomColor,
      speedLevel: this.speedLevel
    });
  }

  build() {
    Column() {
      Text('⚙️ 难度设置')
        .fontSize(22)
        .fontWeight(FontWeight.Bold)
        .fontColor('#2C3E50')
        .margin({ top: 10, bottom: 16 })

      Row() {
        this.TypeOption('🔢 数字', DifficultyType.NUMBER)
        this.TypeOption('🎨 颜色', DifficultyType.COLOR)
        if (this.mode !== GameMode.GRID) {
          this.TypeOption('🚀 速度', DifficultyType.SPEED)
        }
      }
      .width('100%')
      .justifyContent(FlexAlign.SpaceEvenly)
      .margin({ bottom: 16 })

      if (this.selectedType === DifficultyType.NUMBER || this.selectedType === DifficultyType.COLOR) {
        Row() {
          Text('数字数量：')
            .fontSize(16)
            .fontColor('#2C3E50')
          Button('-')
            .width(36)
            .height(36)
            .fontSize(20)
            .backgroundColor('#ECF0F1')
            .fontColor('#2C3E50')
            .borderRadius(18)
            .onClick(() => {
              if (this.numberCount > 25) {
                this.numberCount -= 5;
              }
            })
          Text(this.numberCount.toString())
            .fontSize(20)
            .fontWeight(FontWeight.Bold)
            .fontColor('#4A90D9')
            .width(50)
            .textAlign(TextAlign.Center)
          Button('+')
            .width(36)
            .height(36)
            .fontSize(20)
            .backgroundColor('#ECF0F1')
            .fontColor('#2C3E50')
            .borderRadius(18)
            .onClick(() => {
              if (this.numberCount < 64) {
                this.numberCount += 5;
              }
            })
        }
        .width('100%')
        .margin({ bottom: 12 })
      }

      if (this.selectedType === DifficultyType.COLOR) {
        Row() {
          Text('🎨 随机颜色：')
            .fontSize(16)
            .fontColor('#2C3E50')
          Button(this.useRandomColor ? '开 ✅' : '关 ❌')
            .width(60)
            .height(36)
            .fontSize(14)
            .backgroundColor(this.useRandomColor ? '#27AE60' : '#ECF0F1')
            .fontColor(this.useRandomColor ? '#FFFFFF' : '#2C3E50')
            .borderRadius(18)
            .onClick(() => {
              this.useRandomColor = !this.useRandomColor;
            })
        }
        .width('100%')
        .margin({ bottom: 12 })
      }

      if (this.selectedType === DifficultyType.SPEED && this.mode !== GameMode.GRID) {
        Row() {
          Text('速度等级：')
            .fontSize(16)
            .fontColor('#2C3E50')
          Button('-')
            .width(36)
            .height(36)
            .fontSize(20)
            .backgroundColor('#ECF0F1')
            .fontColor('#2C3E50')
            .borderRadius(18)
            .onClick(() => {
              if (this.speedLevel > 1) {
                this.speedLevel--;
              }
            })
          Text(this.speedLevel.toString() + '/5')
            .fontSize(18)
            .fontWeight(FontWeight.Bold)
            .fontColor('#9B59B6')
            .width(50)
            .textAlign(TextAlign.Center)
          Button('+')
            .width(36)
            .height(36)
            .fontSize(20)
            .backgroundColor('#ECF0F1')
            .fontColor('#2C3E50')
            .borderRadius(18)
            .onClick(() => {
              if (this.speedLevel < 5) {
                this.speedLevel++;
              }
            })
        }
        .width('100%')
        .margin({ bottom: 12 })
      }

      Row() {
        Button('取消')
          .width('40%')
          .height(44)
          .fontSize(16)
          .backgroundColor('#ECF0F1')
          .fontColor('#7F8C8D')
          .borderRadius(22)
          .onClick(() => {})

        Blank().width('8%')

        Button('开始 🚀')
          .width('40%')
          .height(44)
          .fontSize(16)
          .fontWeight(FontWeight.Medium)
          .backgroundColor('#4A90D9')
          .fontColor(Color.White)
          .borderRadius(22)
          .onClick(() => {
            this.confirm();
          })
      }
      .width('100%')
      .margin({ top: 8 })
    }
    .width('90%')
    .padding(20)
    .backgroundColor('#FFFFFF')
    .borderRadius(16)
    .shadow({ radius: 24, color: '#00000030' })
  }

  @Builder
  TypeOption(label: string, type: DifficultyType) {
    Column() {
      Text(label)
        .fontSize(14)
        .fontWeight(FontWeight.Medium)
        .fontColor(this.selectedType === type ? '#FFFFFF' : '#2C3E50')
    }
    .padding({ left: 12, right: 12 })
    .height(38)
    .borderRadius(19)
    .backgroundColor(this.selectedType === type ? '#4A90D9' : '#F0F4F8')
    .justifyContent(FlexAlign.Center)
    .alignItems(HorizontalAlign.Center)
    .onClick(() => {
      this.selectedType = type;
    })
  }
}