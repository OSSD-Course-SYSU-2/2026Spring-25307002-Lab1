// pages/HomePage.ets
import { router } from '@kit.ArkUI';
import { display } from '@kit.ArkUI';
import { StorageUtil } from '../utils/StorageUtil';

@Entry
@Component
struct HomePage {
  @State selectedMode: string = 'grid';
  @State bestTime: string = '--';
  @State screenWidth: number = 0;

  aboutToAppear() {
    const screen = display.getDefaultDisplaySync();
    this.screenWidth = screen.width;
    this.loadBestRecord();
  }

  async loadBestRecord() {
    const best = await StorageUtil.getBestRecord();
    if (best) {
      this.bestTime = (best.time / 1000).toFixed(2) + '秒';
    }
  }

  startGame() {
    router.pushUrl({
      url: 'pages/GamePage',
      params: { mode: this.selectedMode }
    });
  }

  goToRecord() {
    router.pushUrl({ url: 'pages/RecordPage' });
  }

  // 根据屏幕宽度获取字体大小
  getTitleSize(): number {
    return this.screenWidth > 800 ? 42 : 32;
  }

  getSubTitleSize(): number {
    return this.screenWidth > 800 ? 20 : 16;
  }

  getButtonSize(): number {
    return this.screenWidth > 800 ? 24 : 22;
  }

  build() {
    Column() {
      // 标题
      Column() {
        Text('🎯')
          .fontSize(this.screenWidth > 800 ? 64 : 48)
          .margin({ top: this.screenWidth > 800 ? 40 : 20 })
        Text('舒尔特小游戏')
          .fontSize(this.getTitleSize())
          .fontWeight(FontWeight.Bold)
          .fontColor('#2C3E50')
          .margin({ top: 4 })
        Text('专注力训练 · 三模式')
          .fontSize(this.getSubTitleSize())
          .fontColor('#95A5A6')
      }
      .margin({ bottom: this.screenWidth > 800 ? 32 : 24 })

      // 最佳成绩
      Row() {
        Text('🏅 最佳成绩：')
          .fontSize(this.screenWidth > 800 ? 18 : 16)
          .fontColor('#7F8C8D')
        Text(this.bestTime)
          .fontSize(this.screenWidth > 800 ? 22 : 18)
          .fontWeight(FontWeight.Bold)
          .fontColor('#F39C12')
      }
      .margin({ bottom: this.screenWidth > 800 ? 28 : 20 })

      // 模式选择标题
      Text('选择模式')
        .fontSize(this.screenWidth > 800 ? 22 : 18)
        .fontWeight(FontWeight.Medium)
        .fontColor('#2C3E50')
        .alignSelf(ItemAlign.Start)
        .margin({ left: 16, bottom: this.screenWidth > 800 ? 12 : 8 })

      // 模式选择
      Row() {
        this.ModeItem('📐 基础方格', 'grid', '#4A90D9')
        this.ModeItem('🎡 转盘模式', 'wheel', '#E67E22')
        this.ModeItem('⚽ 小球运动', 'ball', '#27AE60')
      }
      .width('96%')
      .justifyContent(FlexAlign.SpaceEvenly)
      .margin({ bottom: this.screenWidth > 800 ? 32 : 24 })

      // 开始按钮
      Button('🚀 开始游戏')
        .width(this.screenWidth > 800 ? '70%' : '88%')
        .height(this.screenWidth > 800 ? 70 : 56)
        .fontSize(this.getButtonSize())
        .fontWeight(FontWeight.Bold)
        .backgroundColor('#4A90D9')
        .fontColor(Color.White)
        .borderRadius(28)
        .shadow({ radius: 16, color: '#4A90D940' })
        .onClick(() => { this.startGame(); })

      // 历史记录按钮
      Button('📊 历史记录')
        .width(this.screenWidth > 800 ? '70%' : '88%')
        .height(this.screenWidth > 800 ? 56 : 48)
        .fontSize(this.screenWidth > 800 ? 18 : 16)
        .backgroundColor('#F8F9FA')
        .fontColor('#2C3E50')
        .borderRadius(24)
        .border({ width: 1, color: '#E8ECF0' })
        .margin({ top: this.screenWidth > 800 ? 16 : 12 })
        .onClick(() => { this.goToRecord(); })

      // 设备信息（调试用）
      Text('📱 ' + (this.screenWidth > 1200 ? '大屏设备' : (this.screenWidth > 800 ? '平板设备' : '手机设备')))
        .fontSize(12)
        .fontColor('#BDC3C7')
        .margin({ top: this.screenWidth > 800 ? 30 : 20 })

      Blank()
    }
    .width('100%')
    .height('100%')
    .backgroundColor('#FFFFFF')
    .justifyContent(FlexAlign.Start)
  }

  @Builder
  ModeItem(label: string, mode: string, color: string) {
    Column() {
      Text(label)
        .fontSize(this.screenWidth > 800 ? 18 : 15)
        .fontWeight(FontWeight.Medium)
        .fontColor(this.selectedMode === mode ? '#FFFFFF' : '#2C3E50')
    }
    .width(this.screenWidth > 800 ? '28%' : '30%')
    .height(this.screenWidth > 800 ? 56 : 48)
    .borderRadius(24)
    .backgroundColor(this.selectedMode === mode ? color : '#F0F4F8')
    .justifyContent(FlexAlign.Center)
    .alignItems(HorizontalAlign.Center)
    .shadow(this.selectedMode === mode ? { radius: 10, color: color + '60' } : { radius: 0 })
    .onClick(() => {
      this.selectedMode = mode;
    })
  }
}