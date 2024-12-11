/**
 * Author: Meng
 * Date: 2024/12/05
 * Modify: 2024/12/05
 * Desc:
 */
import { media } from '@kit.MediaKit';
import { BusinessError } from '@kit.BasicServicesKit';
import { audio } from '@kit.AudioKit';

export async function playerMediaLive(url: string) {
  // 创建avPlayer实例对象
  let avPlayer: media.AVPlayer = await media.createAVPlayer();
  // 创建状态机变化回调函数
  setAVPlayerCallback(avPlayer);
  avPlayer.url = url; // 'http://xxx.xxx.xxx.xxx:xx/xx/index.m3u8'; // 播放hls网络直播码流
}

export async function playerMediaVideo(url: string) {
  let avPlayer: media.AVPlayer = await media.createAVPlayer();

  setAVPlayerCallback(avPlayer);

  let mediaSource: media.MediaSource = media.createMediaSourceWithUrl(url,
    { "User-Agent": "User-Agent-Value", "Cookie": "Cookie-Value", "Referer": "Referer-Value" });
  // 设置播放策略，播放片源的尺寸为1920*1080、设置缓冲区大小为20MB
  let playbackStrategy: media.PlaybackStrategy = {
    preferredWidth: 1920,
    preferredHeight: 1080,
    preferredBufferDuration: 20,
    preferredHdr: false
  };
  // 为avPlayer设置媒体来源和播放策略
  avPlayer.setMediaSource(mediaSource, playbackStrategy);
  // avPlayer.url = url;
}


function setAVPlayerCallback(avPlayer: media.AVPlayer) {
  // startRenderFrame首帧渲染回调函数
  avPlayer.on('startRenderFrame', () => {
    console.info(`AVPlayer start render frame`);
  })
  // seek操作结果回调函数
  avPlayer.on('seekDone', (seekDoneTime: number) => {
    console.info(`AVPlayer seek succeeded, seek time is ${seekDoneTime}`);
  })
  // error回调监听函数,当avPlayer在操作过程中出现错误时调用reset接口触发重置流程
  avPlayer.on('error', (err: BusinessError) => {
    console.warn(`Invoke avPlayer failed, code is ${err.code}, message is ${err.message}`);
    avPlayer.reset(); // 调用reset重置资源，触发idle状态
  })
  // 获取流媒体缓冲状态和缓冲进度
  // avPlayer.on('bufferingUpdate', (infoType: media.BufferingInfoType, value: number) => {
  //   console.info(`AVPlayer bufferingUpdate, infoType is ${infoType}, value is ${value}.`);
  // })
  // 状态机变化回调函数
  avPlayer.on('stateChange', async (state: string, reason: media.StateChangeReason) => {
    switch (state) {
      case 'idle': // 成功调用reset接口后触发该状态机上报
        console.info('AVPlayer state idle called.');
        avPlayer.release(); // 调用release接口销毁实例对象
        break;
      case 'initialized': // avplayer 设置播放源后触发该状态上报
        console.info('AVPlayer state initialized called.');
        // avPlayer.surfaceId = surfaceID; // 设置显示画面，当播放的资源为纯音频时无需设置
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
        // avPlayer.seek(avPlayer.duration); //seek到视频末尾
        break;
      case 'paused': // pause成功调用后触发该状态机上报
        console.info('AVPlayer state paused called.');
        // avPlayer.play(); // 再次播放接口开始播放
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