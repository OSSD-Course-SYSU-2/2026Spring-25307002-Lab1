// utils/StorageUtil.ets
import { GameRecord } from '../model/GameData';
import { preferences } from '@kit.ArkData';

export class StorageUtil {
  private static pref: preferences.Preferences | null = null;

  static async init(context: Context) {
    try {
      StorageUtil.pref = await preferences.getPreferences(context, 'shulte_game_data');
    } catch (e) {
      console.error('StorageUtil init error:', e);
    }
  }

  static async saveRecord(record: GameRecord): Promise<void> {
    if (!StorageUtil.pref) return;
    try {
      const recordsStr = await StorageUtil.pref.get('records', '[]') as string;
      const records: GameRecord[] = JSON.parse(recordsStr);
      records.push(record);
      await StorageUtil.pref.put('records', JSON.stringify(records));
      await StorageUtil.pref.flush();
    } catch (e) {
      console.error('saveRecord error:', e);
    }
  }

  static async getRecords(): Promise<GameRecord[]> {
    if (!StorageUtil.pref) return [];
    try {
      const recordsStr = await StorageUtil.pref.get('records', '[]') as string;
      return JSON.parse(recordsStr);
    } catch (e) {
      return [];
    }
  }

  static async getBestRecord(): Promise<GameRecord | null> {
    const records = await StorageUtil.getRecords();
    if (records.length === 0) return null;
    return records.reduce((best, current) => current.time < best.time ? current : best);
  }

  static async clearRecords(): Promise<void> {
    if (!StorageUtil.pref) return;
    try {
      await StorageUtil.pref.put('records', '[]');
      await StorageUtil.pref.flush();
    } catch (e) {
      console.error('clearRecords error:', e);
    }
  }
}