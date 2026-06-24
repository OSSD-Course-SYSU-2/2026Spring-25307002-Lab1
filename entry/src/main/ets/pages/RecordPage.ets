// pages/RecordPage.ets
import { router } from '@kit.ArkUI';
import { GameRecord } from '../model/GameData';
import { StorageUtil } from '../utils/StorageUtil';

@Entry
@Component
struct RecordPage {
  @State records: GameRecord[] = [];
  @State bestRecord: GameRecord | null = null;

  aboutToAppear() {
    this.loadRecords();
  }

  async loadRecords() {
    this.records = await StorageUtil.getRecords();
    this.bestRecord = await StorageUtil.getBestRecord();
  }

  getModeLabel(mode: string): string {
    const map: Record<string, string> = {
      '基础方格': '📐',
      '转盘模式': '🎡',
      '小球运动': '⚽'
    };
    return map[mode] || '📐';
  }

  getTypeLabel(type: string): string {
    const map: Record<string, string> = {
      '数字模式': '🔢',
      '颜色模式': '🎨',
      '速度模式': '🚀'
    };
    return map[type] || '🔢';
  }

  goBack() {
    router.back();
  }

  build() {
    Column() {
      Row() {
        Text('← 返回')
          .fontSize(16)
          .fontColor('#4A90D9')
          .onClick(() => { this.goBack(); })

        Blank()

        Text('📊 历史记录')
          .fontSize(20)
          .fontWeight(FontWeight.Bold)
          .fontColor('#2C3E50')

        Blank()

        Text('清空')
          .fontSize(14)
          .fontColor('#E74C3C')
          .onClick(async () => {
            await StorageUtil.clearRecords();
            this.records = [];
            this.bestRecord = null;
          })
      }
      .width('95%')
      .margin({ top: 15, bottom: 10 })

      if (this.bestRecord) {
        Row() {
          Text('🏆 最佳记录：')
            .fontSize(16)
            .fontColor('#2C3E50')
          Text((this.bestRecord.time / 1000).toFixed(2) + '秒')
            .fontSize(20)
            .fontWeight(FontWeight.Bold)
            .fontColor('#F39C12')
          Text(' (' + this.bestRecord.mode + ')')
            .fontSize(14)
            .fontColor('#7F8C8D')
        }
        .width('95%')
        .padding(12)
        .backgroundColor('#FFF8E1')
        .borderRadius(12)
        .margin({ bottom: 10 })
      }

      if (this.records.length === 0) {
        Column() {
          Text('📭')
            .fontSize(60)
            .margin({ top: 60 })
          Text('暂无记录')
            .fontSize(16)
            .fontColor('#95A5A6')
            .margin({ top: 10 })
          Text('快去完成一局游戏吧！')
            .fontSize(14)
            .fontColor('#BDC3C7')
        }
        .width('100%')
        .height('70%')
        .justifyContent(FlexAlign.Center)
      } else {
        List({ space: 6 }) {
          ForEach(this.records, (record: GameRecord) => {
            ListItem() {
              Row() {
                Column() {
                  Row() {
                    Text(this.getModeLabel(record.mode))
                      .fontSize(16)
                    Text(record.mode)
                      .fontSize(14)
                      .fontWeight(FontWeight.Medium)
                      .fontColor('#2C3E50')
                      .margin({ left: 4 })
                  }
                  Row() {
                    Text(this.getTypeLabel(record.difficultyType))
                      .fontSize(12)
                    Text(record.numberCount + '个')
                      .fontSize(12)
                      .fontColor('#7F8C8D')
                      .margin({ left: 4 })
                    if (record.useRandomColor) {
                      Text('🌈')
                        .fontSize(12)
                        .margin({ left: 4 })
                    }
                    if (record.speedLevel > 0 && record.mode !== '基础方格') {
                      Text('⚡' + record.speedLevel)
                        .fontSize(12)
                        .margin({ left: 4 })
                    }
                  }
                  .margin({ top: 2 })
                }
                .alignItems(HorizontalAlign.Start)

                Blank()

                Column() {
                  Text((record.time / 1000).toFixed(2) + '秒')
                    .fontSize(16)
                    .fontWeight(FontWeight.Bold)
                    .fontColor(record.isBest ? '#F39C12' : '#2C3E50')
                  Text(record.date)
                    .fontSize(11)
                    .fontColor('#BDC3C7')
                }
                .alignItems(HorizontalAlign.End)
              }
              .width('100%')
              .padding({ left: 12, right: 12, top: 10, bottom: 10 })
              .backgroundColor(record.isBest ? '#FFF8E1' : '#FFFFFF')
              .borderRadius(10)
              .border(record.isBest ? { width: 2, color: '#F39C12' } : { width: 1, color: '#ECF0F1' })
            }
          }, (record: GameRecord, index: number) => record.date + index.toString())
        }
        .width('95%')
        .padding({ top: 4 })
        .layoutWeight(1)
      }
    }
    .width('100%')
    .height('100%')
    .backgroundColor('#F8F9FA')
  }
}