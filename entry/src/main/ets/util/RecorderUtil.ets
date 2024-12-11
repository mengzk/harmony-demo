/**
 * Author: Meng
 * Date: 2024/11/29
 * Modify: 2024/11/29
 * Desc:
 */
import { common } from '@kit.AbilityKit';
import { media } from '@kit.MediaKit';
import { BusinessError } from '@kit.BasicServicesKit';
import { fileIo as fs } from '@kit.CoreFileKit';

import { applyPermissions, AUDIO } from './PermissionUtil';

let recorderConfig: media.AVRecorderConfig = {
  audioSourceType: media.AudioSourceType.AUDIO_SOURCE_TYPE_MIC, // 音频输入源，这里设置为麦克风
  profile: {
    audioBitrate: 100000, // 音频比特率
    audioChannels: 2, // 音频声道数
    audioCodec: media.CodecMimeType.AUDIO_AAC, // 音频编码格式，当前支持ACC，MP3，G711MU
    audioSampleRate: 48000, // 音频采样率
    fileFormat: media.ContainerFormatType.CFT_MPEG_4A, // 封装格式，当前支持MP4，M4A，MP3，WAV
  },
  url: 'fd://0', // 音频文件fd
}

type onCall = (ms: number) => void;

let avRecorder: media.AVRecorder | null = null;
let audioFilePath: string = ''; // 音频路径
let startTime = 0;
let recorderLength = 0;
let timeWait = 0;
let callback: onCall | undefined;

export function initAudio(context: common.Context) {
  applyPermissions(AUDIO, context as common.UIAbilityContext).then(res => {
    const canUse = res.some(e => e == -1);
    if (!canUse) {

    } else {

    }
  });
}

async function createRecorder() {
  await recorderRelease();
  avRecorder = await media.createAVRecorder();
  await onRecorderStatus();
}

async function onRecorderStatus() {
  if (avRecorder) {
    // 状态上报回调函数
    avRecorder.on('stateChange', (state: media.AVRecorderState, reason: media.StateChangeReason) => {
      console.log(`------> current state is ${state}`);
    });

    // 错误上报回调函数
    avRecorder.on('error', (err: BusinessError) => {
      console.error(`------> recorder failed, code is ${err.code}, message is ${err.message}`);
    });

    let path = getContext().cacheDir;
    audioFilePath = path + `/A${Date.now()}.m4a`;
    let file = fs.openSync(audioFilePath, fs.OpenMode.READ_WRITE | fs.OpenMode.CREATE);
    // 确保该沙箱路径下存在该资源
    recorderConfig.url = `fd://${file.fd}`;

    await avRecorder.prepare(recorderConfig).then(() => {
      console.log('Invoke prepare succeeded.');
    }, (err: BusinessError) => {
      console.warn(`------> recorder prepare failed ${err.code}, ${err.message}`);
    })
  }
}

export async function recorderStart(call?: onCall): Promise<string> {
  await createRecorder();

  if (avRecorder != null) {
    callback = call;
    startTime = Date.now();
    recorderLength = 0;
    return avRecorder.start().then(res => {
      onTimeWait();
      console.log('------> recorderStart start', JSON.stringify(res));
      return audioFilePath;
    }).catch((err: BusinessError) => {
      console.warn(`------> recorderStart catch ${err.code}, ${err.message}`);
      return '';
    });
  }
  return '';
}

export function recorderResume() {
  if (avRecorder != null) {
    if (avRecorder.state == 'paused') {
      startTime = Date.now() - recorderLength;
      avRecorder.resume();
      onTimeWait();
    }
  }
}

export function recorderPause() {
  if (avRecorder != null) {
    if (avRecorder.state == 'started') {
      clearInterval(timeWait);
      recorderLength = Date.now() - startTime;
      avRecorder.pause();
    }
  }
}

export function recorderStop(): Promise<string> {
  if (avRecorder != null) {
    clearInterval(timeWait);
    const state = avRecorder.state;
    if (state == 'started' || state == 'paused') {
      recorderLength = Date.now() - startTime;
      return avRecorder.stop().then((res) => {
        if (recorderLength < 2000) {
          // 时间过短
          return Promise.resolve('');
        }
        return audioFilePath;
      }).catch(() => {
        return '';
      });
    } else {
      return Promise.resolve('');
    }
  }
  return Promise.resolve('');
}

export async function recorderRelease() {
  if (avRecorder != null) {
    const state = avRecorder.state;
    if (state == 'started' || state == 'paused') {
      await avRecorder.stop();
    }
    await avRecorder.reset();
    await avRecorder.release();

    avRecorder = null;

    clearInterval(timeWait);
  }
}

function onTimeWait() {
  clearInterval(timeWait);
  timeWait = setInterval(() => {
    const ms = Date.now() - startTime; // 毫秒
    if(callback) {
      callback(ms);
    }else {
      console.log('------> onTimeWait', ms);
    }
  }, 1000);
}