// utils/ScreenUtil.ets
import { display } from '@kit.ArkUI';

export class ScreenUtil {
  static getWidth(): number {
    const screen = display.getDefaultDisplaySync();
    return screen.width;
  }

  static getHeight(): number {
    const screen = display.getDefaultDisplaySync();
    return screen.height;
  }

  static isPhone(): boolean {
    return ScreenUtil.getWidth() <= 800;
  }

  static isTablet(): boolean {
    const w = ScreenUtil.getWidth();
    return w > 800 && w <= 1200;
  }

  static isLargeScreen(): boolean {
    return ScreenUtil.getWidth() > 1200;
  }

  static getAdaptiveGridCols(): number {
    const w = ScreenUtil.getWidth();
    if (w > 1200) return 10;
    if (w > 800) return 7;
    return 5;
  }

  static getAdaptiveGridRows(total: number): number {
    const cols = ScreenUtil.getAdaptiveGridCols();
    return Math.ceil(total / cols);
  }

  static getAdaptiveFontSize(baseSize: number): number {
    const w = ScreenUtil.getWidth();
    if (w > 1200) return baseSize * 1.3;
    if (w > 800) return baseSize * 1.1;
    return baseSize;
  }

  static getAdaptiveSize(baseSize: number): number {
    const w = ScreenUtil.getWidth();
    if (w > 1200) return baseSize * 1.4;
    if (w > 800) return baseSize * 1.15;
    return baseSize;
  }

  static isLandscape(): boolean {
    return ScreenUtil.getWidth() > ScreenUtil.getHeight();
  }

  static isPortrait(): boolean {
    return ScreenUtil.getWidth() < ScreenUtil.getHeight();
  }
}