// pages/ResultPage.ets
import { router } from '@kit.ArkUI';
import { StorageUtil } from '../utils/StorageUtil';

@Entry
@Component
struct ResultPage {
  @State isWin: boolean = false;
  @State timeStr: string = '0.00';
  @State score: number = 0;
  @State total: number = 0;
  @State mode: string = '基础方格';
  @State bestTime: string = '--';

  aboutToAppear() {
    const params = router.getParams() as Record<string, Object>;
    if (params) {
      this.isWin = params['isWin'] as boolean || false;
      this.timeStr = params['timeStr'] as string || '0.00';
      this.score = params['score'] as number || 0;
      this.total = params['total'] as number || 0;
      this.mode = params['mode'] as string || '基础方格';
    }
    this.loadBest();
  }

  async loadBest() {
    const best = await StorageUtil.getBestRecord();
    if (best) {
      this.bestTime = (best.time / 1000).toFixed(2) + '秒';
    }
  }

  goHome() {
    router.replaceUrl({ url: 'pages/HomePage' });
  }

  replay() {
    router.back();
  }

  getStars(): string {
    if (!this.isWin) return '💪';
    const ratio = this.score / this.total;
    if (ratio >= 0.95) return '⭐⭐⭐';
    if (ratio >= 0.8) return '⭐⭐';
    return '⭐';
  }

  build() {
    Column() {
      Text(this.isWin ? '🎉 通关成功！' : '⏰ 时间到！')
        .fontSize(34)
        .fontWeight(FontWeight.Bold)
        .fontColor(this.isWin ? '#27AE60' : '#E74C3C')
        .margin({ top: 30 })

      Text(this.getStars())
        .fontSize(52)
        .margin({ top: 10 })

      Text(this.mode)
        .fontSize(16)
        .fontColor('#95A5A6')
        .backgroundColor('#F0F4F8')
        .padding({ left: 16, right: 16, top: 6, bottom: 6 })
        .borderRadius(20)
        .margin({ top: 8 })

      Column() {
        this.statRow('⏱ 用时', this.timeStr + '秒', this.isWin ? '#27AE60' : '#E74C3C')
        this.statRow('📊 完成', this.score + '/' + this.total, '#2C3E50')
        this.statRow('🏅 最佳成绩', this.bestTime, '#F39C12')
      }
      .width('88%')
      .padding(20)
      .backgroundColor('#F8F9FA')
      .borderRadius(16)
      .margin({ top: 20 })

      Row() {
        Button('🏠 首页')
          .width('40%')
          .height(50)
          .fontSize(16)
          .fontWeight(FontWeight.Medium)
          .backgroundColor('#95A5A6')
          .fontColor(Color.White)
          .borderRadius(25)
          .onClick(() => { this.goHome(); })

        Blank().width('8%')

        Button('🔄 再来一局')
          .width('40%')
          .height(50)
          .fontSize(16)
          .fontWeight(FontWeight.Medium)
          .backgroundColor('#4A90D9')
          .fontColor(Color.White)
          .borderRadius(25)
          .onClick(() => { this.replay(); })
      }
      .width('88%')
      .margin({ top: 30 })

      Blank()
    }
    .width('100%')
    .height('100%')
    .backgroundColor('#FFFFFF')
  }

  @Builder
  statRow(label: string, value: string, color: string) {
    Row() {
      Text(label)
        .fontSize(16)
        .fontColor('#7F8C8D')
      Blank()
      Text(value)
        .fontSize(20)
        .fontWeight(FontWeight.Bold)
        .fontColor(color)
    }
    .width('100%')
    .margin({ bottom: 6 })
  }
}