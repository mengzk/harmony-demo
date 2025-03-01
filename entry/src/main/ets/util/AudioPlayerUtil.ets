/**
 * Author: Meng
 * Date: 2024/11/29
 * Modify: 2024/11/29
 * Desc:
 */

import { audio } from '@kit.AudioKit';
import { media } from '@kit.MediaKit';
import { BusinessError } from '@kit.BasicServicesKit';

let avPlayer: media.AVPlayer|null = null;

export async function audioPlayer(url: string) {
  if(!url) {
    return;
  }
  if(avPlayer) {
    await avPlayer.release();
  }
  avPlayer = await media.createAVPlayer();
  if (avPlayer) {
    setPlayerCallback(avPlayer);
    avPlayer.url = url;
  }
}

export function playerAction(action: string, time?:number) {
  if(avPlayer) {
    switch (action) {
      case 'pause':
        avPlayer.pause();
        break;
      case 'resume':
        avPlayer.reset();
        break;
      case 'stop':
        avPlayer.stop();
        break;
      case 'seek':
        // avPlayer.seek(avPlayer.duration); //seek到音频末尾
        avPlayer.seek(time);
        break;
      default:
        break;
    }
  }
}

// 注册avplayer回调函数
function setPlayerCallback(avPlayer: media.AVPlayer) {
  // seek操作结果回调函数
  avPlayer.on('seekDone', (seekDoneTime: number) => {
    console.info(`---> AVPlayer seek time ${seekDoneTime}`);
  })
  // error回调监听函数,当avPlayer在操作过程中出现错误时调用 reset接口触发重置流程
  avPlayer.on('error', (err: BusinessError) => {
    console.warn(`---> avPlayer err ${err.code}, ${err.message}`);
    avPlayer?.reset(); // 调用reset重置资源，触发idle状态
  })
  // 状态机变化回调函数
  avPlayer.on('stateChange', async (state: string, reason: media.StateChangeReason) => {
    switch (state) {
      case 'idle': // 成功调用reset接口后触发该状态机上报
        console.info('AVPlayer state idle called.');
        avPlayer.release(); // 调用release接口销毁实例对象
        break;
      case 'initialized': // avplayer 设置播放源后触发该状态上报
        console.info('AVPlayer state initialized called.');
        avPlayer.audioRendererInfo = {
          usage: audio.StreamUsage.STREAM_USAGE_MUSIC,
          rendererFlags: 0
        }
        avPlayer.prepare();
        break;
      case 'prepared': // prepare调用成功后上报该状态机
        console.info('AVPlayer state prepared called.');
        avPlayer.play(); // 调用播放接口开始播放
        break;
      case 'playing': // play成功调用后触发该状态机上报
        console.info('AVPlayer state playing called.');
        break;
      case 'paused': // pause成功调用后触发该状态机上报
        console.info('AVPlayer state paused called.');
        break;
      case 'completed': // 播放结束后触发该状态机上报
        console.info('AVPlayer state completed called.');
        avPlayer.stop(); //调用播放结束接口
        break;
      case 'stopped': // stop接口成功调用后触发该状态机上报
        console.info('AVPlayer state stopped called.');
        avPlayer.reset(); // 调用reset接口初始化avplayer状态
        break;
      case 'released':
        console.info('AVPlayer state released called.');
        break;
      default:
        console.info('AVPlayer state unknown called.');
        break;
    }
  })
}