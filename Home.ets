/*
 * Copyright (c) 2023 Huawei Device Co., Ltd.
 * Licensed under the Apache License, Version 2.0 (the "License");
 * you may not use this file except in compliance with the License.
 * You may obtain a copy of the License at
 *
 *     http://www.apache.org/licenses/LICENSE-2.0
 *
 * Unless required by applicable law or agreed to in writing, software
 * distributed under the License is distributed on an "AS IS" BASIS,
 * WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
 * See the License for the specific language governing permissions and
 * limitations under the License.
 */

/*
* 最佳实践: 平板开发实践
*/

import { deviceInfo } from '@kit.BasicServicesKit';
import { SearchView } from '@ohos/search';
import { CommonConstants } from '@ohos/commons';
import { FooterTab, FooterTabViewModel } from '../viewmodel/FooterTabViewModel';
import { HomeHeader } from './HomeHeader';
import { HomeContent } from './HomeContent';
import { promptAction } from '@kit.ArkUI';
@Component
export struct Home {
  @State currentBottomIndex: number = 0;
  @State isSearching: boolean = false;
  @StorageLink('scrollHeight') scrollHeight: number = 0;
  @StorageLink('currentTopIndex') currentTopIndex: number = 0;
  @StorageLink('currentWidthBreakpoint') currentWidthBreakpoint: string = 'lg';
  private tabList: FooterTab[] = new FooterTabViewModel().getTabList();
  private scroller: Scroller = new Scroller();
  private sideScroller: Scroller = new Scroller();

  @Builder
  BottomTabBuilder(item: FooterTab, index: number) {
    Column() {
      Image(index !== this.currentBottomIndex ? (this.currentTopIndex === 2 && this.currentBottomIndex === 0 &&
        !this.isSearching ? item.getIconWhite() : item.getIcon()) : item.getIconSelected())
        .width('24vp')
        .height('24vp')
      Text(item.getName())
        .fontSize('10fp')
        .fontWeight(500)
        .fontColor(index === this.currentBottomIndex ? '#ED6F21' : (this.currentTopIndex === 2 &&
          this.currentBottomIndex === 0 && !this.isSearching ? Color.White : Color.Black))
        .margin({ top: '4vp' })
        .opacity(index === this.currentBottomIndex ? 1 : 0.4)
    }
    .padding({ bottom: this.currentWidthBreakpoint !== 'lg' && deviceInfo.deviceType !==
      '2in1' ? '24vp' : 0 })
    .height(this.currentWidthBreakpoint === 'lg' ? '100vp' :
      '100%')
    .width('100%')
    .justifyContent(FlexAlign.Center)
  }
  @Builder
  StatItem(number: string, label: string, unit: string) {
    Column() {
      Text(number)
        .fontSize(22)
        .fontWeight(FontWeight.Bold)
        .fontColor('#007AFF')
      Text(label)
        .fontSize(12)
        .fontColor('#666')
      Text(unit)
        .fontSize(10)
        .fontColor('#999')
    }
  }
  @Builder
  SettingItem(icon: string, title: string, subtitle: string) {
    Row() {
      Text(icon)
        .fontSize(24)
        .margin({ right: 12 })

      Column() {
        Text(title)
          .fontSize(16)
          .fontWeight(500)
        Text(subtitle)
          .fontSize(12)
          .fontColor('#999')
      }
      .alignItems(HorizontalAlign.Start)

      Blank()

      Text('›')
        .fontSize(20)
        .fontColor('#CCC')
    }
    .width('100%')
    .height(60)
    .padding({ left: 16, right: 16 })
    .onClick(() => {
      promptAction.showToast({ message: `${title}功能开发中`, duration: 1500 });
    })
  }
  build() {
    // [Start tabs_barposition]
    Tabs({
      barPosition: this.currentWidthBreakpoint === 'lg' ? BarPosition.Start : BarPosition.End
    }) {
      // [StartExclude tabs_barposition]
      // [Start tab_content]
      TabContent() {
        if (this.currentTopIndex === 2) {
          // The immersive design of the home page is displayed when the top tab is switched to 2.
          Stack() {
            Scroll(this.sideScroller) {
              Column() {
                HomeContent()
                  .visibility(!this.isSearching ? Visibility.Visible : Visibility.None)

                SearchView({ isSearching: $isSearching })
                  .visibility(!this.isSearching ? Visibility.None : Visibility.Visible)
              }
              .width('100%')
            }
            .scrollBar(BarState.Off)
            .height('100%')
            // Obtains the sliding offset on the y axis during sliding.
            .onScrollFrameBegin((offset: number) => {
              this.scrollHeight = this.sideScroller.currentOffset().yOffset;
              return { offsetRemain: offset }
            })

            HomeHeader({ isSearching: $isSearching })
              .visibility(!this.isSearching ? Visibility.Visible : Visibility.None)
              .padding({ left: this.currentWidthBreakpoint === 'lg' ? '96vp' : 0 })
          }
          .height('100%')
          .width('100%')
          .alignContent(Alignment.Top)
        } else {
          // Non-immersive design for the home page.
          Column() {
            HomeHeader({ isSearching: $isSearching })
              .visibility(!this.isSearching ? Visibility.Visible : Visibility.None)

            Scroll(this.scroller) {
              Column() {
                HomeContent()
                  .visibility(!this.isSearching ? Visibility.Visible : Visibility.None)

                SearchView({ isSearching: $isSearching })
                  .visibility(!this.isSearching ? Visibility.None : Visibility.Visible)
              }
              .width('100%')
            }
            .layoutWeight(1)
            .scrollBar(BarState.Off)
          }
          .height('100%')
          .width('100%')
        }
      }
      .tabBar(this.BottomTabBuilder(this.tabList[0], 0))
      // [End tab_content]

      TabContent() {
        Column()
      }
      .tabBar(this.BottomTabBuilder(this.tabList[1], 1))

      TabContent() {
        Column()
      }
      .tabBar(this.BottomTabBuilder(this.tabList[2], 2))

      TabContent() {
        Column(){
          // 个人信息卡片
          Column() {
            Circle({ width: 70, height: 70 })
              .fill('#007AFF')
              .margin({ top: 20 })

            Text('视频爱好者')
              .fontSize(18)
              .fontWeight(FontWeight.Bold)
              .margin({ top: 10 })

            Text('热爱生活，热爱视频')
              .fontSize(13)
              .fontColor('#999')
              .margin({ top: 4 })

            Button('编辑资料')
              .width(100)
              .height(32)
              .fontSize(13)
              .backgroundColor('#007AFF')
              .borderRadius(16)
              .margin({ top: 12, bottom: 16 })
              .onClick(() => {
                promptAction.showToast({ message: '功能开发中', duration: 1500 });
              })
          }
          .width('100%')
          .backgroundColor('#F8F9FA')
          .borderRadius(16)
          .margin({ top: 20, left: 16, right: 16 })

          // 统计卡片
          Row() {
            this.StatItem('128', '播放时长', '小时')
            this.StatItem('56', '点赞', '个')
            this.StatItem('23', '粉丝', '人')
          }
          .width('100%')
          .backgroundColor('#FFFFFF')
          .borderRadius(16)
          .padding({ top: 16, bottom: 16 })
          .margin({ top: 12, left: 16, right: 16 })
          .justifyContent(FlexAlign.SpaceAround)

          Blank().layoutWeight(1)
        }
        .width('100%')
        .height('100%')
        .backgroundColor('#F5F5F5')
      }
      .tabBar(this.BottomTabBuilder(this.tabList[3], 3))
      // [EndExclude tabs_barposition]
    }
    // Change the position and size of the tab at the bottom.
    .barWidth(this.currentWidthBreakpoint === 'lg' ? '96vp' : '100%')
    .barHeight(this.currentWidthBreakpoint === 'lg' ? '100%' : (deviceInfo.deviceType === '2in1' ? '56vp' : '76vp'))
    .barMode(this.currentWidthBreakpoint === 'lg' ? BarMode.Scrollable : BarMode.Fixed,
      { nonScrollableLayoutStyle: LayoutStyle.ALWAYS_CENTER })
    .vertical(this.currentWidthBreakpoint === 'lg')
    // [End tabs_barposition]
    .barOverlap(this.currentWidthBreakpoint === 'lg' && this.currentTopIndex === 2 ? true : false)
    .barBackgroundBlurStyle(BlurStyle.NONE)
    .barBackgroundColor(this.currentTopIndex === 2 && this.currentBottomIndex === 0 ?
      (this.currentWidthBreakpoint === 'lg' ? '#0DFFFFFF' : '#222A3E') : '#F1F3F5')
    .onChange((index: number) => {
      this.currentBottomIndex = index;
    })
    .scrollable(false)
    .expandSafeArea([SafeAreaType.SYSTEM], [SafeAreaEdge.TOP, SafeAreaEdge.BOTTOM])
    .height('100%')
    .width('100%')
  }
}