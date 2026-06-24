// components/BallGame.ets
import { router } from '@kit.ArkUI';
import { GameMode, DifficultyType, GameRecord, DifficultyConfig } from '../model/GameData';
import { StorageUtil } from '../utils/StorageUtil';

interface Ball {
  id: number;
  x: number;
  y: number;
  vx: number;
  vy: number;
  radius: number;
  color: string;
  isClicked: boolean;
}

@Component
export struct BallGame {
  private settings: RenderingContextSettings = new RenderingContextSettings(true);
  private context: CanvasRenderingContext2D = new CanvasRenderingContext2D(this.settings);

  @State balls: Ball[] = [];
  @State currentTarget: number = 1;
  @State elapsed: number = 0;
  @State isFinished: boolean = false;
  @State isRunning: boolean = false;
  @State timerId: number = -1;
  @State animationId: number = -1;

  private config: DifficultyConfig = { type: DifficultyType.NUMBER, numberCount: 25, useRandomColor: false, speedLevel: 3 };
  private startTime: number = 0;
  private canvasWidth: number = 380;
  private canvasHeight: number = 380;

  aboutToAppear() {
    this.initGame();
    this.startAnimation();
  }

  aboutToDisappear() {
    if (this.timerId !== -1) {
      clearInterval(this.timerId);
    }
    if (this.animationId !== -1) {
      clearTimeout(this.animationId);
    }
  }

  getRandomColor(): string {
    const colors = ['#FF6B6B', '#4ECDC4', '#45B7D1', '#FFA07A', '#98D8C8',
      '#F7DC6F', '#BB8FCE', '#85C1E9', '#F8C471', '#82E0AA',
      '#FF6348', '#7BED9F', '#70A1FF', '#FF4757', '#2ED573'];
    return colors[Math.floor(Math.random() * colors.length)];
  }

  initGame() {
    const total = this.config.numberCount;
    const newBalls: Ball[] = [];

    const speedFactor = 0.5 + this.config.speedLevel * 0.5;

    const cols = Math.ceil(Math.sqrt(total));
    const rows = Math.ceil(total / cols);
    const spacingX = this.canvasWidth / (cols + 1);
    const spacingY = this.canvasHeight / (rows + 1);
    const radius = Math.min(spacingX, spacingY) * 0.45;

    let index = 1;
    for (let row = 0; row < rows; row++) {
      for (let col = 0; col < cols; col++) {
        if (index > total) break;
        const ball: Ball = {
          id: index,
          x: spacingX * (col + 1) + (Math.random() - 0.5) * 15,
          y: spacingY * (row + 1) + (Math.random() - 0.5) * 15,
          vx: (Math.random() - 0.5) * speedFactor * 1.8,
          vy: (Math.random() - 0.5) * speedFactor * 1.8,
          radius: Math.max(radius, 34),
          color: this.getRandomColor(),
          isClicked: false
        };
        newBalls.push(ball);
        index++;
      }
    }

    for (let i = newBalls.length - 1; i > 0; i--) {
      const j = Math.floor(Math.random() * (i + 1));
      let temp = newBalls[i];
      newBalls[i] = newBalls[j];
      newBalls[j] = temp;
      let tempId = newBalls[i].id;
      newBalls[i].id = newBalls[j].id;
      newBalls[j].id = tempId;
    }

    this.balls = newBalls;
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

  startAnimation() {
    const animate = () => {
      if (!this.isRunning || this.isFinished) return;

      const newBalls: Ball[] = [];
      for (let i = 0; i < this.balls.length; i++) {
        const ball = this.balls[i];
        if (ball.isClicked) {
          newBalls.push(ball);
          continue;
        }

        let newX = ball.x + ball.vx;
        let newY = ball.y + ball.vy;
        let newVx = ball.vx;
        let newVy = ball.vy;

        if (newX < ball.radius || newX > this.canvasWidth - ball.radius) {
          newVx = -newVx;
          newX = Math.max(ball.radius, Math.min(this.canvasWidth - ball.radius, newX));
        }
        if (newY < ball.radius || newY > this.canvasHeight - ball.radius) {
          newVy = -newVy;
          newY = Math.max(ball.radius, Math.min(this.canvasHeight - ball.radius, newY));
        }

        const newBall: Ball = {
          id: ball.id,
          x: newX,
          y: newY,
          vx: newVx,
          vy: newVy,
          radius: ball.radius,
          color: ball.color,
          isClicked: ball.isClicked
        };
        newBalls.push(newBall);
      }

      this.balls = newBalls;
      this.drawBalls();

      this.animationId = setTimeout(animate, 16);
    };

    animate();
  }

  drawBalls() {
    const ctx = this.context;
    ctx.clearRect(0, 0, this.canvasWidth, this.canvasHeight);

    ctx.fillStyle = '#1A1A2E';
    ctx.fillRect(0, 0, this.canvasWidth, this.canvasHeight);

    for (let i = 0; i < this.balls.length; i++) {
      const ball = this.balls[i];
      if (ball.isClicked) {
        ctx.beginPath();
        ctx.arc(ball.x, ball.y, ball.radius, 0, Math.PI * 2);
        ctx.fillStyle = '#BDC3C7';
        ctx.fill();
        ctx.fillStyle = '#95A5A6';
        ctx.font = 'bold ' + (ball.radius * 0.5) + 'px Arial';
        ctx.textAlign = 'center';
        ctx.textBaseline = 'middle';
        ctx.fillText('✓', ball.x, ball.y);
      } else {
        ctx.shadowColor = 'rgba(0,0,0,0.3)';
        ctx.shadowBlur = 10;

        ctx.beginPath();
        ctx.arc(ball.x, ball.y, ball.radius, 0, Math.PI * 2);
        ctx.fillStyle = ball.color;
        ctx.fill();

        ctx.shadowBlur = 0;

        ctx.fillStyle = '#FFFFFF';
        ctx.font = 'bold ' + ball.radius + 'px Arial';
        ctx.textAlign = 'center';
        ctx.textBaseline = 'middle';
        ctx.fillText(ball.id.toString(), ball.x, ball.y);
      }
    }

    ctx.fillStyle = '#FFFFFF';
    ctx.font = 'bold 20px Arial';
    ctx.textAlign = 'center';
    ctx.textBaseline = 'bottom';
    ctx.fillText('找数字 ' + this.currentTarget, this.canvasWidth / 2, this.canvasHeight - 10);

    ctx.fillStyle = 'rgba(255,255,255,0.3)';
    ctx.font = '12px Arial';
    ctx.textBaseline = 'top';
    ctx.fillText('速度 ' + this.config.speedLevel + '/5', this.canvasWidth / 2, 10);
  }

  handleCanvasClick(event: ClickEvent) {
    if (this.isFinished || !this.isRunning) return;

    const clickX = event.x;
    const clickY = event.y;

    for (let i = this.balls.length - 1; i >= 0; i--) {
      const ball = this.balls[i];
      if (ball.isClicked) continue;

      const dx = clickX - ball.x;
      const dy = clickY - ball.y;
      const dist = Math.sqrt(dx * dx + dy * dy);

      if (dist <= ball.radius) {
        if (ball.id === this.currentTarget) {
          const newBall: Ball = {
            id: ball.id,
            x: ball.x,
            y: ball.y,
            vx: ball.vx,
            vy: ball.vy,
            radius: ball.radius,
            color: ball.color,
            isClicked: true
          };
          this.balls[i] = newBall;
          this.currentTarget++;
          this.drawBalls();

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
        break;
      }
    }
  }

  async saveRecord(time: number) {
    const record = new GameRecord(
      GameMode.BALL,
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
        mode: '小球运动'
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

      Text('点击小球上的数字，按顺序 1→2→3→...→' + this.config.numberCount)
        .fontSize(13)
        .fontColor('#95A5A6')
        .margin({ top: 8 })
    }
    .width('100%')
    .height('100%')
    .justifyContent(FlexAlign.Start)
  }
}