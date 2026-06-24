// components/WheelGame.ets
import { router } from '@kit.ArkUI';
import { GameMode, DifficultyType, GameRecord, DifficultyConfig } from '../model/GameData';
import { StorageUtil } from '../utils/StorageUtil';

interface RingItem {
  value: number;
  angle: number;
}

@Component
export struct WheelGame {
  private settings: RenderingContextSettings = new RenderingContextSettings(true);
  private context: CanvasRenderingContext2D = new CanvasRenderingContext2D(this.settings);

  @State numbers: number[] = [];
  @State currentTarget: number = 1;
  @State elapsed: number = 0;
  @State isFinished: boolean = false;
  @State isRunning: boolean = false;
  @State timerId: number = -1;
  @State rotation: number = 0;
  @State speed: number = 0;
  @State ringCount: number = 1;

  private config: DifficultyConfig = { type: DifficultyType.NUMBER, numberCount: 25, useRandomColor: false, speedLevel: 3 };
  private startTime: number = 0;
  private canvasWidth: number = 380;
  private canvasHeight: number = 380;
  private centerX: number = 190;
  private centerY: number = 190;
  private maxRadius: number = 170;
  private rotateIntervalId: number = -1;

  private ring1Items: RingItem[] = [];
  private ring2Items: RingItem[] = [];
  private ring3Items: RingItem[] = [];

  private ring1Angle: number = 0;
  private ring2Angle: number = 0;
  private ring3Angle: number = 0;

  private speed1: number = 0.015;
  private speed2: number = 0.010;
  private speed3: number = 0.006;

  aboutToAppear() {
    this.initGame();
    this.startRotation();
  }

  aboutToDisappear() {
    if (this.timerId !== -1) {
      clearInterval(this.timerId);
    }
    if (this.rotateIntervalId !== -1) {
      clearInterval(this.rotateIntervalId);
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

    this.currentTarget = 1;
    this.elapsed = 0;
    this.isFinished = false;
    this.isRunning = true;
    this.startTime = Date.now();

    this.maxRadius = Math.min(this.canvasWidth, this.canvasHeight) * 0.44;

    const totalRings = total >= 30 ? 3 : 1;
    const perRing = Math.ceil(total / 3);

    this.ring1Items = [];
    this.ring2Items = [];
    this.ring3Items = [];

    if (totalRings === 1) {
      for (let i = 0; i < this.numbers.length; i++) {
        const item: RingItem = {
          value: this.numbers[i],
          angle: (i / this.numbers.length) * Math.PI * 2
        };
        this.ring1Items.push(item);
      }
      this.speed1 = 0.012 + this.config.speedLevel * 0.003;
      this.speed2 = 0;
      this.speed3 = 0;
      this.ringCount = 1;
    } else {
      for (let i = 0; i < this.numbers.length; i++) {
        const item: RingItem = { value: this.numbers[i], angle: 0 };
        if (i < perRing) {
          item.angle = (this.ring1Items.length / perRing) * Math.PI * 2;
          this.ring1Items.push(item);
        } else if (i < perRing * 2) {
          item.angle = (this.ring2Items.length / perRing) * Math.PI * 2;
          this.ring2Items.push(item);
        } else {
          const ring3Count = total - perRing * 2;
          if (ring3Count > 0) {
            item.angle = (this.ring3Items.length / ring3Count) * Math.PI * 2;
            this.ring3Items.push(item);
          }
        }
      }
      this.speed1 = 0.015 + this.config.speedLevel * 0.003;
      this.speed2 = 0.010 + this.config.speedLevel * 0.002;
      this.speed3 = 0.006 + this.config.speedLevel * 0.001;
      this.ringCount = 3;
    }

    this.ring1Angle = Math.random() * Math.PI * 2;
    this.ring2Angle = Math.random() * Math.PI * 2;
    this.ring3Angle = Math.random() * Math.PI * 2;

    if (this.timerId !== -1) clearInterval(this.timerId);
    this.timerId = setInterval(() => {
      if (this.isRunning && !this.isFinished) {
        this.elapsed = Date.now() - this.startTime;
      }
    }, 50);
  }

  startRotation() {
    if (this.rotateIntervalId !== -1) {
      clearInterval(this.rotateIntervalId);
    }
    this.rotateIntervalId = setInterval(() => {
      if (!this.isFinished && this.isRunning) {
        this.ring1Angle += this.speed1;
        this.ring2Angle += this.speed2;
        this.ring3Angle += this.speed3;
        this.drawWheel();
      }
    }, 30);
  }

  drawWheel() {
    const ctx = this.context;
    const cx = this.centerX;
    const cy = this.centerY;

    ctx.clearRect(0, 0, this.canvasWidth, this.canvasHeight);

    ctx.fillStyle = '#1A1A2E';
    ctx.fillRect(0, 0, this.canvasWidth, this.canvasHeight);

    const r1 = this.maxRadius * 0.95;
    const r2 = this.maxRadius * 0.70;
    const r3 = this.maxRadius * 0.40;

    this.drawRing(ctx, cx, cy, r1, this.ring1Items, '#4A90D9', this.ring1Angle, 1);
    this.drawRing(ctx, cx, cy, r2, this.ring2Items, '#E67E22', this.ring2Angle, 2);
    this.drawRing(ctx, cx, cy, r3, this.ring3Items, '#27AE60', this.ring3Angle, 3);

    ctx.beginPath();
    ctx.arc(cx, cy, 30, 0, Math.PI * 2);
    ctx.fillStyle = '#FFFFFF';
    ctx.fill();
    ctx.strokeStyle = '#2C3E50';
    ctx.lineWidth = 3;
    ctx.stroke();

    ctx.fillStyle = '#2C3E50';
    ctx.font = 'bold 26px Arial';
    ctx.textAlign = 'center';
    ctx.textBaseline = 'middle';
    ctx.fillText(this.currentTarget > this.config.numberCount ? '✓' : this.currentTarget.toString(), cx, cy);

    ctx.beginPath();
    ctx.moveTo(cx, 5);
    ctx.lineTo(cx - 14, 25);
    ctx.lineTo(cx + 14, 25);
    ctx.closePath();
    ctx.fillStyle = '#FF6B6B';
    ctx.fill();

    ctx.beginPath();
    ctx.arc(cx, cy, this.maxRadius, 0, Math.PI * 2);
    ctx.strokeStyle = 'rgba(255,255,255,0.15)';
    ctx.lineWidth = 1.5;
    ctx.stroke();

    if (this.ringCount > 1) {
      ctx.fillStyle = 'rgba(255,255,255,0.3)';
      ctx.font = '12px Arial';
      ctx.textAlign = 'center';
      ctx.textBaseline = 'bottom';
      ctx.fillText(this.ringCount + '环转盘', cx, this.canvasHeight - 5);
    }
  }

  drawRing(ctx: CanvasRenderingContext2D, cx: number, cy: number, radius: number,
    items: RingItem[], color: string, offsetAngle: number, ring: number) {
    if (items.length === 0) return;
    const count = items.length;
    const sliceAngle = (Math.PI * 2) / count;

    for (let i = 0; i < count; i++) {
      const item = items[i];
      const startAngle = item.angle + offsetAngle - sliceAngle / 2;
      const endAngle = item.angle + offsetAngle + sliceAngle / 2;

      ctx.beginPath();
      ctx.moveTo(cx, cy);
      ctx.arc(cx, cy, radius, startAngle, endAngle);
      ctx.closePath();

      if (this.config.useRandomColor) {
        const colors = ['#FF6B6B', '#4ECDC4', '#45B7D1', '#FFA07A', '#98D8C8',
          '#F7DC6F', '#BB8FCE', '#85C1E9', '#F8C471', '#82E0AA'];
        ctx.fillStyle = colors[i % colors.length];
      } else {
        ctx.fillStyle = i % 2 === 0 ? color : this.lightenColor(color, 30);
      }
      ctx.fill();

      ctx.strokeStyle = 'rgba(255,255,255,0.3)';
      ctx.lineWidth = 1.5;
      ctx.stroke();

      const midAngle = item.angle + offsetAngle;
      const textRadius = radius * 0.92;
      const tx = cx + Math.cos(midAngle) * textRadius;
      const ty = cy + Math.sin(midAngle) * textRadius;

      ctx.fillStyle = '#FFFFFF';
      let fontSize = 38;
      if (ring === 1) fontSize = 38;
      else if (ring === 2) fontSize = 32;
      else if (ring === 3) fontSize = 26;
      ctx.font = 'bold ' + fontSize + 'px Arial';
      ctx.textAlign = 'center';
      ctx.textBaseline = 'middle';
      ctx.fillText(item.value.toString(), tx, ty);
    }

    ctx.beginPath();
    ctx.arc(cx, cy, radius, 0, Math.PI * 2);
    ctx.strokeStyle = 'rgba(255,255,255,0.15)';
    ctx.lineWidth = 1;
    ctx.stroke();
  }

  lightenColor(color: string, percent: number): string {
    const num = parseInt(color.replace('#', ''), 16);
    const amt = Math.round(2.55 * percent);
    const R = Math.min(255, (num >> 16) + amt);
    const G = Math.min(255, ((num >> 8) & 0x00FF) + amt);
    const B = Math.min(255, (num & 0x0000FF) + amt);
    return '#' + (0x1000000 + R * 0x10000 + G * 0x100 + B).toString(16).slice(1);
  }

  handleCanvasClick(event: ClickEvent) {
    if (this.isFinished || !this.isRunning) return;

    const clickX = event.x;
    const clickY = event.y;

    const dx = clickX - this.centerX;
    const dy = clickY - this.centerY;
    const dist = Math.sqrt(dx * dx + dy * dy);

    const r1 = this.maxRadius * 0.95;
    const r2 = this.maxRadius * 0.70;
    const r3 = this.maxRadius * 0.40;

    let items: RingItem[] = [];
    let angleOffset = 0;

    if (dist > r2 && dist <= r1) {
      items = this.ring1Items;
      angleOffset = this.ring1Angle;
    } else if (dist > r3 && dist <= r2) {
      items = this.ring2Items;
      angleOffset = this.ring2Angle;
    } else if (dist <= r3) {
      items = this.ring3Items;
      angleOffset = this.ring3Angle;
    } else {
      return;
    }

    if (items.length === 0) return;

    let angle = Math.atan2(dy, dx);
    let minDiff = Math.PI;
    let selectedItem: RingItem | null = null;

    for (let i = 0; i < items.length; i++) {
      const item = items[i];
      let diff = angle - (item.angle + angleOffset);
      while (diff > Math.PI) diff -= Math.PI * 2;
      while (diff < -Math.PI) diff += Math.PI * 2;
      if (Math.abs(diff) < minDiff) {
        minDiff = Math.abs(diff);
        selectedItem = item;
      }
    }

    if (!selectedItem) return;

    if (selectedItem.value === this.currentTarget) {
      const index = items.indexOf(selectedItem);
      if (index !== -1) {
        items.splice(index, 1);
      }
      this.currentTarget++;
      this.drawWheel();

      if (this.currentTarget > this.config.numberCount) {
        this.isFinished = true;
        this.isRunning = false;
        if (this.timerId !== -1) {
          clearInterval(this.timerId);
        }
        if (this.rotateIntervalId !== -1) {
          clearInterval(this.rotateIntervalId);
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
      GameMode.WHEEL,
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
        mode: '转盘模式'
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

        Blank()

        if (this.config.speedLevel > 0) {
          Text('⚡速度 ' + this.config.speedLevel + '/5')
            .fontSize(14)
            .fontColor('#9B59B6')
        }
        if (this.ringCount > 1) {
          Text('🔄 ' + this.ringCount + '环')
            .fontSize(14)
            .fontColor('#F39C12')
            .margin({ left: 8 })
        }
      }
      .width('95%')
      .margin({ bottom: 8 })

      Canvas(this.context)
        .width(this.canvasWidth)
        .height(this.canvasHeight)
        .backgroundColor('#1A1A2E')
        .borderRadius(16)
        .onClick((event: ClickEvent) => {
          this.handleCanvasClick(event);
        })

      Text('点击转盘上的数字，按顺序 1→2→3→...→' + this.config.numberCount)
        .fontSize(13)
        .fontColor('#95A5A6')
        .margin({ top: 8 })
    }
    .width('100%')
    .height('100%')
    .justifyContent(FlexAlign.Start)
  }
}