/**
 * Author: Meng
 * Date: 2024/11/20
 * Modify: 2024/11/20
 * Desc:
 */

import { BusinessError } from '@kit.BasicServicesKit';
import { abilityAccessCtrl, common, Permissions } from '@kit.AbilityKit';
import { notificationManager } from '@kit.NotificationKit';
import type Want from '@ohos.app.ability.Want';
import { AxiosError } from '@ohos/axios';

const defPermissions: Array<Permissions> =
  ['ohos.permission.LOCATION', 'ohos.permission.APPROXIMATELY_LOCATION', 'ohos.permission.READ_MEDIA',
    'ohos.permission.WRITE_MEDIA', 'ohos.permission.MEDIA_LOCATION', 'ohos.permission.CAMERA'];

export const MEDIA: Array<Permissions> = ['ohos.permission.MEDIA_LOCATION'];

export const LOCATION: Array<Permissions> = ['ohos.permission.LOCATION', 'ohos.permission.APPROXIMATELY_LOCATION'];

export const READ_WRITE: Array<Permissions> = ['ohos.permission.READ_MEDIA', 'ohos.permission.WRITE_MEDIA'];

export const CAMERA: Array<Permissions> =
  ['ohos.permission.READ_MEDIA', 'ohos.permission.WRITE_MEDIA', 'ohos.permission.CAMERA'];

export const AUDIO: Array<Permissions> = ['ohos.permission.MICROPHONE', 'ohos.permission.READ_MEDIA', 'ohos.permission.WRITE_MEDIA'];

export function checkPermission(permissions: string): boolean {

  return false
}

export function checkPermissions(permissions: Permissions[]): Promise<Array<number>> {

  let atManager: abilityAccessCtrl.AtManager = abilityAccessCtrl.createAtManager();
  const tokenID = 0;
  return Promise.all(permissions.map((per) => {
    return atManager.checkAccessToken(tokenID, per).then((data: abilityAccessCtrl.GrantStatus) => {
      // console.log(`checkAccessToken success, data->${JSON.stringify(data)}`);
      return data;
    }).catch((err: BusinessError) => {
      console.error(`------> permissions check, err->${JSON.stringify(err)}`);
      return -1;
    })
  }));
}

export function applyPermissions(permissions: Array<Permissions>,
  context: common.UIAbilityContext): Promise<Array<number>> {
  return new Promise((resolve) => {
    let atManager: abilityAccessCtrl.AtManager = abilityAccessCtrl.createAtManager();
    atManager.requestPermissionsFromUser(context, permissions).then((data) => {
      let grantStatus: Array<number> = data.authResults;
      console.log('------> permissions status', grantStatus.join(','))
      resolve(grantStatus);
    }).catch((err: BusinessError) => {
      console.error(`------> permissions catch. Code is ${err.code}, message is ${err.message}`);
      resolve(permissions.map(_ => -1));
    })
  });
}

export function permissionOnSetting(permissions: Array<Permissions>,
  context: common.UIAbilityContext) {
  let atManager: abilityAccessCtrl.AtManager = abilityAccessCtrl.createAtManager();
  atManager.requestPermissionOnSetting(context, permissions)
    .then((data: Array<abilityAccessCtrl.GrantStatus>) => {
      console.info('------> permissions setting data:' + JSON.stringify(data));
      return 0;
    })
    .catch((err: BusinessError) => {
      console.error('------> permissions setting err:' + JSON.stringify(err));
      return -2;
    });
}

export function applyAppPermission(context: common.UIAbilityContext) {
  applyPermissions(defPermissions, context);
}

// 获取是否打开消息通知权限
export function checkMessagePushPermission(context1: common.UIAbilityContext): Promise<boolean> {
  // pushService.getToken((err: BusinessError, data: string) => {
  //   if (err) {
  //     console.log('===token222', JSON.stringify(err))
  //   } else {
  //     console.log('===token111', data)
  //   }
  // });

  return new Promise((resolve, reject) => {
    notificationManager.isNotificationEnabled().then((data: boolean) => {
      resolve(data)
      if (!data) {
        notificationManager.requestEnableNotification(context1).then(() => {
          resolve(true)
        }).catch((err: BusinessError) => {
          if (1600004 == err.code) {
            reject()
          } else {
            reject()
          }
        });
      }
    }).catch((err: BusinessError) => {
      reject()
    });
  })
}

export function openSettingPage(context: common.UIAbilityContext) {
  let wantInfo: Want = {
    bundleName: 'com.huawei.hmos.settings', // 系统设置的包名
    abilityName: 'com.huawei.hmos.settings.MainAbility', // 系统设置的主能力名
    uri: 'application_info_entry', // 指向应用信息的URI
    parameters: {
      pushParams: 'com.bnq.crm_harmony' // 传递你的应用的包名作为参数
    }
  };

  context.startAbility(wantInfo)
    .then(() => {
      console.log('成功打开设置页面');
    })
    .catch((err: AxiosError) => {
      console.error('打开设置页面失败:', err);
    });
}
