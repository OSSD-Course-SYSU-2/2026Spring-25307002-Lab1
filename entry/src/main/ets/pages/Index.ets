import { display } from '@kit.ArkUI';

interface RingItem {
  value: number;
  angle: number;
  isClicked: boolean;
}

@Entry
@Component
struct Index {
  private settings: RenderingContextSettings = new RenderingContextSettings(true);
  private context: CanvasRenderingContext2D = new CanvasRenderingContext2D(this.settings);

  @State timeLeft: number = 60;
  @State currentTarget: number = 1;
  @State totalNumbers: number = 40;
  @State isGameOver: boolean = false;
  @State isWin: boolean = false;
  @State timer: number = -1;
  @State bestScore: number = 0;
  @State errorFlash: boolean = false;
  @State refreshKey: number = 0;
  @State canvasSize: number = 400;

  private centerX: number = 200;
  private centerY: number = 200;
  private maxRadius: number = 185;

  private animationId: number = -1;
  private isAnimating: boolean = false;

  private ring1Items: RingItem[] = [];
  private ring2Items: RingItem[] = [];
  private ring3Items: RingItem[] = [];
  private ring4Items: RingItem[] = [];
  private ring5Items: RingItem[] = [];

  private ring1Angle: number = 0;
  private ring2Angle: number = 0;
  private ring3Angle: number = 0;
  private ring4Angle: number = 0;
  private ring5Angle: number = 0;

  private speed1: number = 0.018;
  private speed2: number = 0.015;
  private speed3: number = 0.012;
  private speed4: number = 0.009;
  private speed5: number = 0.006;

  aboutToAppear() {
    this.updateSize();
    this.initGame();
  }

  updateSize() {
    try {
      const screenWidth = display.getDefaultDisplaySync().width;
      const screenHeight = display.getDefaultDisplaySync().height;
      if (screenWidth > 100 && screenHeight > 100) {
        // ✅ 占屏幕宽度的 92%，高度的 80%，取较小值
        const sizeFromWidth = screenWidth * 0.92;
        const sizeFromHeight = screenHeight * 0.80;
        const size = Math.min(sizeFromWidth, sizeFromHeight, 950);
        this.canvasSize = Math.max(size, 320);
      } else {
        this.canvasSize = 400;
      }
    } catch (e) {
      this.canvasSize = 400;
    }
    this.centerX = this.canvasSize / 2;
    this.centerY = this.canvasSize / 2;
    this.maxRadius = this.canvasSize * 0.46;
  }

  aboutToDisappear() {
    if (this.timer !== -1) {
      clearInterval(this.timer);
    }
    if (this.animationId !== -1) {
      clearTimeout(this.animationId);
    }
    this.isAnimating = false;
  }

  initGame() {
    this.updateSize();

    const nums: number[] = [];
    for (let i = 1; i <= this.totalNumbers; i++) {
      nums.push(i);
    }
    for (let i = nums.length - 1; i > 0; i--) {
      const j = Math.floor(Math.random() * (i + 1));
      let temp = nums[i];
      nums[i] = nums[j];
      nums[j] = temp;
    }

    this.ring1Items = [];
    this.ring2Items = [];
    this.ring3Items = [];
    this.ring4Items = [];
    this.ring5Items = [];

    const perRing = 8;

    for (let i = 0; i < perRing; i++) {
      this.ring1Items.push({
        value: nums[i],
        angle: (i / perRing) * Math.PI * 2,
        isClicked: false
      });
      this.ring2Items.push({
        value: nums[perRing + i],
        angle: (i / perRing) * Math.PI * 2,
        isClicked: false
      });
      this.ring3Items.push({
        value: nums[perRing * 2 + i],
        angle: (i / perRing) * Math.PI * 2,
        isClicked: false
      });
      this.ring4Items.push({
        value: nums[perRing * 3 + i],
        angle: (i / perRing) * Math.PI * 2,
        isClicked: false
      });
      this.ring5Items.push({
        value: nums[perRing * 4 + i],
        angle: (i / perRing) * Math.PI * 2,
        isClicked: false
      });
    }

    this.ring1Angle = Math.random() * Math.PI * 2;
    this.ring2Angle = Math.random() * Math.PI * 2;
    this.ring3Angle = Math.random() * Math.PI * 2;
    this.ring4Angle = Math.random() * Math.PI * 2;
    this.ring5Angle = Math.random() * Math.PI * 2;

    this.speed1 = 0.018 + Math.random() * 0.004;
    this.speed2 = 0.015 + Math.random() * 0.003;
    this.speed3 = 0.012 + Math.random() * 0.003;
    this.speed4 = 0.009 + Math.random() * 0.002;
    this.speed5 = 0.006 + Math.random() * 0.002;

    this.currentTarget = 1;
    this.timeLeft = 60;
    this.isGameOver = false;
    this.isWin = false;
    this.errorFlash = false;
    this.refreshKey = 0;

    if (this.timer !== -1) {
      clearInterval(this.timer);
    }

    this.timer = setInterval(() => {
      if (this.isGameOver) return;
      this.timeLeft--;
      if (this.timeLeft <= 0) {
        this.timeLeft = 0;
        this.isGameOver = true;
        this.isAnimating = false;
        this.showResult(false);
        clearInterval(this.timer);
      }
    }, 1000);

    this.isAnimating = true;
    setTimeout(() => {
      this.drawWheels();
    }, 50);
    setTimeout(() => {
      this.drawWheels();
      this.animateLoop();
    }, 150);
  }

  animateLoop() {
    if (!this.isAnimating) return;

    this.ring1Angle += this.speed1;
    this.ring2Angle += this.speed2;
    this.ring3Angle += this.speed3;
    this.ring4Angle += this.speed4;
    this.ring5Angle += this.speed5;

    this.drawWheels();

    this.animationId = setTimeout(() => {
      this.animateLoop();
    }, 30);
  }

  handleCanvasClick(event: ClickEvent) {
    if (this.isGameOver || this.isWin) return;

    const clickX = event.x;
    const clickY = event.y;

    const dx = clickX - this.centerX;
    const dy = clickY - this.centerY;
    const dist = Math.sqrt(dx * dx + dy * dy);

    const r1 = this.maxRadius * 1.0;
    const r2 = this.maxRadius * 0.80;
    const r3 = this.maxRadius * 0.60;
    const r4 = this.maxRadius * 0.40;
    const r5 = this.maxRadius * 0.22;

    let items: RingItem[] = [];
    let angleOffset = 0;

    if (dist > r2 && dist <= r1) {
      items = this.ring1Items;
      angleOffset = this.ring1Angle;
    } else if (dist > r3 && dist <= r2) {
      items = this.ring2Items;
      angleOffset = this.ring2Angle;
    } else if (dist > r4 && dist <= r3) {
      items = this.ring3Items;
      angleOffset = this.ring3Angle;
    } else if (dist > r5 && dist <= r4) {
      items = this.ring4Items;
      angleOffset = this.ring4Angle;
    } else if (dist <= r5) {
      items = this.ring5Items;
      angleOffset = this.ring5Angle;
    } else {
      return;
    }

    let angle = Math.atan2(dy, dx);
    let minDiff = Math.PI;
    let selectedItem: RingItem | null = null;

    for (const item of items) {
      if (item.isClicked) continue;
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
      selectedItem.isClicked = true;
      this.currentTarget++;

      if (this.currentTarget > this.totalNumbers) {
        this.isWin = true;
        this.isGameOver = true;
        this.isAnimating = false;
        if (this.animationId !== -1) {
          clearTimeout(this.animationId);
        }
        clearInterval(this.timer);
        const usedTime = 60 - this.timeLeft;
        if (this.bestScore === 0 || usedTime < this.bestScore) {
          this.bestScore = usedTime;
        }
        setTimeout(() => {
          this.showResult(true);
        }, 300);
      }
    } else {
      this.timeLeft += 3;
      this.errorFlash = true;
      setTimeout(() => {
        this.errorFlash = false;
      }, 400);
    }
  }

  showResult(isWin: boolean) {
    const usedTime = 60 - this.timeLeft;
    const msgs = isWin ? [
      '🎉 太棒了！全部找到！',
      '🧠 专注力超强！',
      '⚡ 速度惊人！',
      '🏆 你是最棒的！'
    ] : [
      '⏰ 时间到！继续加油！',
      '💪 下次一定可以！',
      '🧘 深呼吸，再来一次！'
    ];

    AlertDialog.show({
      title: isWin ? '🎉 通关成功！' : '⏰ 时间到！',
      message: msgs[Math.floor(Math.random() * msgs.length)] +
        '\n\n用时：' + usedTime + '秒' +
        '\n已找：' + (this.currentTarget - 1) + '/' + this.totalNumbers +
        (this.bestScore > 0 ? '\n🏅 最佳成绩：' + this.bestScore + '秒' : ''),
      confirm: {
        value: '再来一局',
        action: () => {
          this.initGame();
        }
      }
    });
  }

  drawWheels() {
    const ctx = this.context;
    const cx = this.centerX;
    const cy = this.centerY;
    const size = this.canvasSize;

    if (size < 50) {
      return;
    }

    ctx.clearRect(0, 0, size, size);

    ctx.fillStyle = '#1A1A2E';
    ctx.fillRect(0, 0, size, size);

    const r1 = this.maxRadius * 0.98;
    const r2 = this.maxRadius * 0.78;
    const r3 = this.maxRadius * 0.58;
    const r4 = this.maxRadius * 0.38;
    const r5 = this.maxRadius * 0.20;

    this.drawRing(ctx, cx, cy, r1, this.ring1Items, '#E74C3C', this.ring1Angle, 1);
    this.drawRing(ctx, cx, cy, r2, this.ring2Items, '#E67E22', this.ring2Angle, 2);
    this.drawRing(ctx, cx, cy, r3, this.ring3Items, '#F1C40F', this.ring3Angle, 3);
    this.drawRing(ctx, cx, cy, r4, this.ring4Items, '#3498DB', this.ring4Angle, 4);
    this.drawRing(ctx, cx, cy, r5, this.ring5Items, '#9B59B6', this.ring5Angle, 5);

    const centerR = r5 * 0.35;
    ctx.shadowColor = '#00000050';
    ctx.shadowBlur = 20;
    ctx.beginPath();
    ctx.arc(cx, cy, centerR, 0, Math.PI * 2);
    ctx.fillStyle = '#FFFFFF';
    ctx.fill();
    ctx.shadowBlur = 0;
    ctx.strokeStyle = '#2C3E50';
    ctx.lineWidth = 3;
    ctx.stroke();

    ctx.fillStyle = '#2C3E50';
    ctx.font = 'bold 30px Arial';
    ctx.textAlign = 'center';
    ctx.textBaseline = 'middle';
    ctx.fillText(this.currentTarget > this.totalNumbers ? '✓' : this.currentTarget.toString(), cx, cy);

    ctx.shadowColor = '#FF6B6B80';
    ctx.shadowBlur = 25;
    ctx.beginPath();
    ctx.moveTo(cx, 6);
    ctx.lineTo(cx - 16, 32);
    ctx.lineTo(cx + 16, 32);
    ctx.closePath();
    ctx.fillStyle = '#FF6B6B';
    ctx.fill();
    ctx.shadowBlur = 0;

    for (const r of [r1, r2, r3, r4, r5]) {
      ctx.beginPath();
      ctx.arc(cx, cy, r, 0, Math.PI * 2);
      ctx.strokeStyle = 'rgba(255,255,255,0.15)';
      ctx.lineWidth = 1;
      ctx.stroke();
    }
  }

  drawRing(ctx: CanvasRenderingContext2D, cx: number, cy: number, radius: number,
    items: RingItem[], color: string, offsetAngle: number, ring: number) {
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

      const colors = [color, this.lightenColor(color, 30)];
      ctx.fillStyle = colors[i % 2];
      ctx.fill();

      ctx.strokeStyle = '#FFFFFF';
      ctx.lineWidth = 1.5;
      ctx.stroke();

      const midAngle = item.angle + offsetAngle;

      let textRadius = radius * 0.92;
      if (ring === 5) {
        textRadius = radius * 0.50;
      }
      const tx = cx + Math.cos(midAngle) * textRadius;
      const ty = cy + Math.sin(midAngle) * textRadius;

      ctx.fillStyle = '#1A1A2E';
      let baseSize = this.canvasSize / 10;
      let fontSize = Math.max(22, Math.min(48, baseSize));
      if (ring === 2) fontSize = fontSize * 0.92;
      else if (ring === 3) fontSize = fontSize * 0.85;
      else if (ring === 4) fontSize = fontSize * 0.77;
      else if (ring === 5) fontSize = fontSize * 0.70;
      ctx.font = 'bold ' + Math.round(fontSize) + 'px Arial';
      ctx.textAlign = 'center';
      ctx.textBaseline = 'middle';
      ctx.fillText(item.value.toString(), tx, ty);
    }

    ctx.beginPath();
    ctx.arc(cx, cy, radius, 0, Math.PI * 2);
    ctx.strokeStyle = '#FFFFFF';
    ctx.lineWidth = 2.5;
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

  build() {
    Column() {
      Row() {
        Text('🎯 专注力转盘')
          .fontSize(24)
          .fontWeight(FontWeight.Bold)
          .fontColor('#2C3E50')

        Blank()

        Text('找: ' + this.currentTarget)
          .fontSize(18)
          .fontWeight(FontWeight.Bold)
          .fontColor('#4A90D9')
      }
      .width('95%')
      .margin({ top: 12, bottom: 5 })

      Row() {
        Text('⏱ ' + this.timeLeft + 's')
          .fontSize(20)
          .fontWeight(FontWeight.Bold)
          .fontColor(this.timeLeft <= 10 ? '#FF6B6B' : '#2C3E50')
          .backgroundColor(this.errorFlash ? '#FF6B6B' : 'transparent')
          .padding({ left: 10, right: 10 })
          .borderRadius(8)

        Blank()

        Text('已找: ' + (this.currentTarget - 1) + '/' + this.totalNumbers)
          .fontSize(16)
          .fontColor('#7F8C8D')

        if (this.bestScore > 0) {
          Text('🏅 ' + this.bestScore + 's')
            .fontSize(16)
            .fontColor('#F39C12')
            .fontWeight(FontWeight.Bold)
            .margin({ left: 10 })
        }
      }
      .width('95%')
      .margin({ bottom: 8 })

      Canvas(this.context)
        .width(this.canvasSize)
        .height(this.canvasSize)
        .backgroundColor('#1A1A2E')
        .borderRadius(16)
        .onClick((event: ClickEvent) => {
          this.handleCanvasClick(event);
        })

      Text('点击转盘上的数字 | 5个转盘不同速度 | 按顺序 1→2→3→...→40')
        .fontSize(13)
        .fontColor('#95A5A6')
        .margin({ top: 8, bottom: 6 })

      Button('重新开始')
        .width('60%')
        .height(42)
        .fontSize(16)
        .fontWeight(FontWeight.Medium)
        .backgroundColor('#4A90D9')
        .fontColor(Color.White)
        .borderRadius(25)
        .onClick(() => {
          if (this.timer !== -1) clearInterval(this.timer);
          this.isAnimating = false;
          if (this.animationId !== -1) {
            clearTimeout(this.animationId);
          }
          this.initGame();
        })
    }
    .width('100%')
    .height('100%')
    .backgroundColor('#FFFFFF')
    .justifyContent(FlexAlign.Start)
  }
}